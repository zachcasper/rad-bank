extension radius

resource operationsDev 'Applications.Core/environments@2023-10-01-preview' = {
  name: 'operations-dev'
  properties: {
    compute: {
      kind: 'aci'
      // Replace value with your resource group ID
      resourceGroup: '/subscriptions/c95e0456-ea5b-4a22-a0cd-e3767f24725b/resourceGroups/operations-dev'
      identity: {
        kind: 'systemAssigned'
      }
    }
    providers: {
      azure: {
        scope: '/subscriptions/c95e0456-ea5b-4a22-a0cd-e3767f24725b/resourceGroups/operations-dev'
      }
    }
    // Will be replaced by a single line in a future release.
    recipes: {
      'Radius.Data/postgreSqlDatabases': {
        default: {
          templateKind: 'terraform'
          templatePath: 'git::https://github.com/zachcasper/recipes.git//azure/postgresql'
          parameters: {
            resource_group_name: 'operations-dev'
            location: 'eastus'
          }
        }
      }
    }
  }
}


resource operationsTest 'Applications.Core/environments@2023-10-01-preview' = {
  name: 'operations-test'
  properties: {
    compute: {
      kind: 'aci'
      // Replace value with your resource group ID
      resourceGroup: '/subscriptions/c95e0456-ea5b-4a22-a0cd-e3767f24725b/resourceGroups/operations-test'
      identity: {
        kind: 'systemAssigned'
      }
    }
    providers: {
      azure: {
        scope: '/subscriptions/c95e0456-ea5b-4a22-a0cd-e3767f24725b/resourceGroups/operations-test'
      }
    }
    // Will be replaced by a single line in a future release.
    recipes: {
      'Radius.Data/postgreSqlDatabases': {
        default: {
          templateKind: 'terraform'
          templatePath: 'git::https://github.com/zachcasper/recipes.git//azure/postgresql'
          parameters: {
            resource_group_name: 'operations-test'
            location: 'eastus'
          }
        }
      }
    }
  }
}

resource operationsProd 'Applications.Core/environments@2023-10-01-preview' = {
  name: 'operations-prod'
  properties: {
    compute: {
      kind: 'aci'
      // Replace value with your resource group ID
      resourceGroup: '/subscriptions/c95e0456-ea5b-4a22-a0cd-e3767f24725b/resourceGroups/operations-prod'
      identity: {
        kind: 'systemAssigned'
      }
    }
    providers: {
      azure: {
        scope: '/subscriptions/c95e0456-ea5b-4a22-a0cd-e3767f24725b/resourceGroups/operations-prod'
      }
    }
    // Will be replaced by a single line in a future release.
    recipes: {
      'Radius.Data/postgreSqlDatabases': {
        default: {
          templateKind: 'terraform'
          templatePath: 'git::https://github.com/zachcasper/recipes.git//azure/postgresql'
          parameters: {
            resource_group_name: 'operations-prod'
            location: 'eastus'
          }
        }
      }
    }
  }
}
