extension radius

resource riskDev 'Applications.Core/environments@2023-10-01-preview' = {
  name: 'risk-dev'
  properties: {
    compute: {
      kind: 'kubernetes'
      namespace: 'risk-dev'
    }
    providers: {
      aws: {
        scope: '/planes/aws/aws/accounts/817312594854/regions/us-east-2'
      }
    }
    // Will be replaced by a single line in a future release.
    recipes: {
      'Radius.Data/postgreSqlDatabases': {
        default: {
          templateKind: 'terraform'
          templatePath: 'git::https://github.com/zachcasper/recipes.git//aws/postgresql'
        }
      }
    }
  }
}

resource riskTest 'Applications.Core/environments@2023-10-01-preview' = {
  name: 'risk-test'
  properties: {
    compute: {
      kind: 'kubernetes'
      namespace: 'risk-test'
    }
    providers: {
      aws: {
        scope: '/planes/aws/aws/accounts/817312594854/regions/us-east-2'
      }
    }
    // Will be replaced by a single line in a future release.
    recipes: {
      'Radius.Data/postgreSqlDatabases': {
        default: {
          templateKind: 'terraform'
          templatePath: 'git::https://github.com/zachcasper/recipes.git//aws/postgresql'
        }
      }
    }
  }
}

resource riskProd 'Applications.Core/environments@2023-10-01-preview' = {
  name: 'risk-prod'
  properties: {
    compute: {
      kind: 'kubernetes'
      namespace: 'risk-prod'
    }
    providers: {
      aws: {
        scope: '/planes/aws/aws/accounts/817312594854/regions/us-east-2'
      }
    }
    // Will be replaced by a single line in a future release.
    recipes: {
      'Radius.Data/postgreSqlDatabases': {
        default: {
          templateKind: 'terraform'
          templatePath: 'git::https://github.com/zachcasper/recipes.git//aws/postgresql'
        }
      }
    }
  }
}

