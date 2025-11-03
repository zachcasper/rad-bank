extension radius

resource commercialDev 'Applications.Core/environments@2023-10-01-preview' = {
  name: 'commercial-dev'
  properties: {
    compute: {
      kind: 'kubernetes'
      namespace: 'commercial-dev'
    }
    providers: {
      azure: {
        scope: '/subscriptions/c95e0456-ea5b-4a22-a0cd-e3767f24725b/resourceGroups/commercial-dev'
      }
    }
    // Will be replaced by a single line in a future release.
    recipes: {
      'Radius.Data/postgreSqlDatabases': {
        default: {
          templateKind: 'terraform'
          templatePath: 'git::https://github.com/zachcasper/recipes.git//azure/postgresql'
          parameters: {
            resource_group_name: 'commercial-dev'
            location: 'eastus'
          }
        }
      }
    }
  }
}

resource commercialTest 'Applications.Core/environments@2023-10-01-preview' = {
  name: 'commercial-test'
  properties: {
    compute: {
      kind: 'kubernetes'
      namespace: 'commercial-test'
    }
    providers: {
      azure: {
        scope: '/subscriptions/c95e0456-ea5b-4a22-a0cd-e3767f24725b/resourceGroups/commercial-test'
      }
    }
    // Will be replaced by a single line in a future release.
    recipes: {
      'Radius.Data/postgreSqlDatabases': {
        default: {
          templateKind: 'terraform'
          templatePath: 'git::https://github.com/zachcasper/recipes.git//azure/postgresql'
          parameters: {
            resource_group_name: 'commercial-test'
            location: 'eastus'
          }
        }
      }
    }
  }
}

resource commercialProd 'Applications.Core/environments@2023-10-01-preview' = {
  name: 'commercial-prod'
  properties: {
    compute: {
      kind: 'kubernetes'
      namespace: 'commercial-prod'
    }
    providers: {
      azure: {
        scope: '/subscriptions/c95e0456-ea5b-4a22-a0cd-e3767f24725b/resourceGroups/commercial-prod'
      }
    }
    // Will be replaced by a single line in a future release.
    recipes: {
      'Radius.Data/postgreSqlDatabases': {
        default: {
          templateKind: 'terraform'
          templatePath: 'git::https://github.com/zachcasper/recipes.git//azure/postgresql'
          parameters: {
            resource_group_name: 'commercial-prod'
            location: 'eastus'
          }
        }
      }
    }
  }
}
