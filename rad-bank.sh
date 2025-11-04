#!/usr/bin/env bash
set -o errexit
_me=$(basename $0)

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

sub_create()
{
    if (( ${#} == 0 )); then
      sub_help_create 0;
      exit 1;
    fi

    case ${1} in
        aks | eks | kind )
            sub_create_$1 "${@:2}";
        ;;
        * )
            echo "unknown command: $1";
            sub_help_create 1;
            exit 1;
        ;;
    esac
}


sub_create_radius()
{
  echo ------------------------------------------------
  echo Creating Radius "$RADIUS_NAME"
  echo ------------------------------------------------

  echo Installing edge rad CLI
  curl -fsSL "https://raw.githubusercontent.com/radius-project/radius/main/deploy/install.sh" | /bin/bash # -s edge

  echo Installing Radius to Kubernetes cluster $RADIUS_NAME
  rad install kubernetes --kubecontext "$RADIUS_NAME" --skip-contour-install # --set dashboard.enabled=false
  sleep 20

  env_file="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.env"
  if [ -f "$env_file" ]; then
    set -a
    source "$env_file"
    set +a
  else
    echo "Required file $env_file not found"
    exit 1
  fi

  echo Creating Azure and AWS credentials
  rad credential register azure sp --client-id $AZURE_CLIENT_ID  --client-secret $AZURE_CLIENT_SECRET  --tenant-id $AZURE_TENANT_ID
  rad credential register aws access-key --access-key-id $AWS_ACCESS_KEY_ID --secret-access-key $AWS_SECRET_ACCESS_KEY

  echo Creating Azure Resource Group
  az group create --location $AZURE_REGION --resource-group $AZURE_RESOURCE_GROUP_NAME

  echo Creating Workspace 
  rad workspace create kubernetes $RADIUS_NAME --context $RADIUS_NAME --force

  echo Creating Resource Types
  pushd "$SCRIPT_DIR/types" || exit 1
  for file in *.yaml; do rad resource-type create -f "$file"; done
  for file in *.yaml; do rad bicep publish-extension --from-file "$file" --target "${file%.yaml}".tgz; done
  popd

  echo Creating bicepconfig.yaml
cat > bicepconfig.json << EOF
{
  "extensions": {
    $(
      for file in $SCRIPT_DIR/types/*.yaml; do
        if [ -f "$file" ]; then
          basename=$(basename "$file" .yaml)
          echo "      \"$basename\": \"$(pwd)/types/$basename.tgz\","
        fi
      done | sed '$ s/,$//'
          ),
      "radius": "br:biceptypes.azurecr.io/radius:latest"
  }
}
EOF

  echo Creating Resource Groups for Rad Bank
  # Workaround for ACI environments requiring a pre-existing Azure Resource Group the name of the environment
  az group create --location $AZURE_REGION --resource-group operations-dev
  az group create --location $AZURE_REGION --resource-group operations-test
  az group create --location $AZURE_REGION --resource-group operations-prod
  pushd "$SCRIPT_DIR/environments" || exit 1
  find . -name "*.bicep" -type f | while read -r file; do
    name=$(basename "$file" .bicep)
    rad group create "$name"
  done

  echo Creating Environments for Rad Bank
  # Workaround for https://github.com/radius-project/radius/issues/9453
  rad env create dummy -g retail
  find . -name "*.bicep" -type f | while read -r file; do 
    rad deploy "$file" -g "$(basename "$file" .bicep)" -e /planes/radius/local/resourcegroups/retail/providers/Applications.Core/environments/dummy
  done
  rad env delete dummy -g retail -y
  popd

  rad group switch retail
  rad environment switch retail-test

  echo Setting up port forwarding for the Dashboard
  echo Stop via killall kubectl
  kubectl port-forward  --namespace=radius-system svc/dashboard 7007:80 &

}


sub_create_kind()
{
  RADIUS_NAME=$1
  if [ -z "$1" ]; then
    echo "A Radius instance name is not provided."
    sub_help_create
    exit 1
  fi

  echo ------------------------------------------------
  echo Creating Radius on kind cluster $RADIUS_NAME
  echo ------------------------------------------------

  kind delete cluster -n $RADIUS_NAME || echo "Deleting the $RADIUS_NAME kind failed"
  kind create cluster -n $RADIUS_NAME
  kubectx $RADIUS_NAME=kind-$RADIUS_NAME

  sub_create_radius
  
  exit
}


sub_create_aks()
{
  RADIUS_NAME=$1
  if [ -z "$1" ]; then
    echo "A Radius instance name is not provided."
    sub_help_create
    exit 1
  fi

   echo ------------------------------------------------
   echo Creating Radius on AKS cluster "$RADIUS_NAME"
   echo ------------------------------------------------
  
  echo Creating AKS cluster $RADIUS_NAME
  az aks create --resource-group $AZURE_RESOURCE_GROUP_NAME --name $RADIUS_NAME --generate-ssh-key --node-count 1 --node-vm-size Standard_B2as_v2 --os-sku AzureLinux
  az aks get-credentials --resource-group $AZURE_RESOURCE_GROUP_NAME --name $RADIUS_NAME

  sub_create_radius

  exit
}


sub_create_eks()
{
  RADIUS_NAME=$1
  if [ -z "$1" ]; then
    echo "A Radius instance name is not provided."
    sub_help_create
    exit 1
  fi

  echo ------------------------------------------------
  echo Creating Radius on EKS cluster $RADIUS_NAME
  echo ------------------------------------------------


  cat << EOF > eks.yaml
---
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: ${RADIUS_NAME}
  region: ${AWS_REGION}

nodeGroups:
  - name: ng-1
    instanceType: m7i.xlarge
    desiredCapacity: 2
EOF

  eksctl create cluster -f eks.yaml
  rm eks.yaml

  kubectx "$RADIUS_NAME=$(kubectx -c)"

  # Workaround for https://github.com/radius-project/radius/issues/9207
  kubectl patch storageclass gp2 -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

  sub_create_radius

  exit
}


sub_delete()
{
  subcommand=$1
  case $subcommand in
    "" | "-h" | "--help")
      sub_help_delete 0
      ;;
    *)
      shift
      sub_delete_${subcommand} "$@"
      if [ $? = 127 ]; then
        echo "Error: '$subcommand' is not a known command." >&2
        sub_help_delete 1
        exit 1
      fi
      ;;
   esac
}


sub_delete_radius()
{  
  echo ------------------------------------------------
  echo Cleaning up
  echo ------------------------------------------------
  rad workspace delete $RADIUS_NAME -y || true
  rm $SCRIPT_DIR/types/*.tgz
  rm bicepconfig.json
  killall kubectl
  az group delete --resource-group $RADIUS_NAME -y
  az group delete --resource-group operations-dev -y
  az group delete --resource-group operations-test -y
  az group delete --resource-group operations-prod -y
}


sub_delete_kind()
{
  RADIUS_NAME=$1
  if [ -z "$1" ]; then
    echo "A Radius instance name is not provided."
    sub_help_create
    exit 1
  fi

  echo ------------------------------------------------
  echo Deleting Radius $RADIUS_NAME
  echo ------------------------------------------------
  kind delete cluster -n $RADIUS_NAME || echo "Deleting the $RADIUS_NAME kind failed"
  kubectx -d $RADIUS_NAME || true

  sub_delete_radius

  exit
}


sub_delete_aks()
{
  RADIUS_NAME=$1
  if [ -z "$1" ]; then
    echo "A Radius instance name is not provided."
    sub_help_create
    exit 1
  fi

  echo ------------------------------------------------
  echo Deleting Radius $RADIUS_NAME
  echo ------------------------------------------------

  echo Deleting Azure resource group $RADIUS_NAME including AKS cluster
  az group delete -n $RADIUS_NAME -y

  echo Deleting Kubernetes context $RADIUS_NAME
  kubectx -d $RADIUS_NAME || true

  echo Deleting the Azure service principal
  AZURE_CLIENT_ID=$(jq -r .'appId' azure-credentials-$RADIUS_NAME.json)
  export AZURE_CLIENT_ID
  az ad sp delete --id $AZURE_CLIENT_ID
  rm azure-credentials-$RADIUS_NAME.json

  sub_delete_radius

  exit
}


sub_delete_eks()
{
  RADIUS_NAME=$1
  if [ -z "$1" ]; then
    echo "A Radius instance name is not provided."
    sub_help_create
    exit 1
  fi
  
  echo ------------------------------------------------
  echo Deleting Radius $RADIUS_NAME
  echo ------------------------------------------------
  rad workspace delete $RADIUS_NAME -y || true
  eksctl delete cluster --name $RADIUS_NAME
  kubectx -d $RADIUS_NAME || true

  sub_delete_radius

  exit
}


sub_help()
{
   echo
   echo "Create Rad Bank Radius environments"
   echo
   echo "Usage:"
   echo "  ${_me} [command] [RADIUS_NAME]"
   echo 
   echo "Available commands:"
   echo "  create [platform] Create a Kubernetes cluster then deploy Radius"
   echo "  delete [platform] Delete the Kubernetes cluster and Azure resource group (if AKS)"
   echo "  help              Help on a command"
   echo
   echo "Available platforms:"
   echo "  aks"
   echo "  eks"
   echo "  kind"
   echo 
}

sub_help_create()
{
   echo
   echo "Create Radius instance"
   echo
   echo "Usage:"
   echo "  ${_me} create [platform] [RADIUS_NAME]"
   echo 
   echo "Available platforms:"
   echo "  aks"
   echo "  eks"
   echo "  kind"
   echo
}

sub_help_delete()
{
   echo
   echo "Delete Radius instance"
   echo
   echo "Usage:"
   echo "  ${_me} delete [platform] [RADIUS_NAME]"
   echo
   echo "Available platforms:"
   echo "  aks"
   echo "  eks"
   echo "  kind"
   echo
}

main()
{
    if (( ${#} == 0 )); then
        sub_help 0;
    fi

    case ${1} in
        create | delete | help )
            sub_$1 "${@:2}";
        ;;
        * )
            echo "Unknown command: $1";
            sub_help 1;
            exit 1;
        ;;
    esac
}

main "$@";