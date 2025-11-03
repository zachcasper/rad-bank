extension radius

resource retailDev 'Applications.Core/environments@2023-10-01-preview' = {
  name: 'retail-dev'
  properties: {
    compute: {
      kind: 'kubernetes'
      namespace: 'retail-dev'
    }
    // Will be replaced by a single line in a future release.
    recipes: {
      'Radius.Compute/containers': {
        default: {
          templateKind: 'terraform'
          templatePath: 'git::https://github.com/zachcasper/recipes.git//kubernetes/containers'
        }
      }
      'Radius.Data/mySqlDatabases': {
        default: {
          templateKind: 'terraform'
          templatePath: 'git::https://github.com/zachcasper/recipes.git//kubernetes/mysql'
        }
      }
      'Radius.Data/neo4jDatabases': {
        default: {
          templateKind: 'terraform'
          templatePath: 'git::https://github.com/zachcasper/recipes.git//kubernetes/neo4j'
        }
      }
      'Radius.Data/postgreSqlDatabases': {
        default: {
          templateKind: 'terraform'
          templatePath: 'git::https://github.com/zachcasper/recipes.git//kubernetes/postgresql'
        }
      }
      'Radius.Data/redisCaches': {
        default: {
          templateKind: 'terraform'
          templatePath: 'git::https://github.com/zachcasper/recipes.git//kubernetes/redis'
        }
      }
    }
  }
}

resource retailTest 'Applications.Core/environments@2023-10-01-preview' = {
  name: 'retail-test'
  properties: {
    compute: {
      kind: 'kubernetes'
      namespace: 'retail-test'
    }
    // Will be replaced by a single line in a future release.
    recipes: {
      'Radius.Compute/containers': {
        default: {
          templateKind: 'terraform'
          templatePath: 'git::https://github.com/zachcasper/recipes.git//kubernetes/containers'
        }
      }
      'Radius.Data/mySqlDatabases': {
        default: {
          templateKind: 'terraform'
          templatePath: 'git::https://github.com/zachcasper/recipes.git//kubernetes/mysql'
        }
      }
      'Radius.Data/neo4jDatabases': {
        default: {
          templateKind: 'terraform'
          templatePath: 'git::https://github.com/zachcasper/recipes.git//kubernetes/neo4j'
        }
      }
      'Radius.Data/postgreSqlDatabases': {
        default: {
          templateKind: 'terraform'
          templatePath: 'git::https://github.com/zachcasper/recipes.git//kubernetes/postgresql'
        }
      }
      'Radius.Data/redisCaches': {
        default: {
          templateKind: 'terraform'
          templatePath: 'git::https://github.com/zachcasper/recipes.git//kubernetes/redis'
        }
      }
    }
  }
}

resource retailProd 'Applications.Core/environments@2023-10-01-preview' = {
  name: 'retail-prod'
  properties: {
    compute: {
      kind: 'kubernetes'
      namespace: 'retail-prod'
    }
    // Will be replaced by a single line in a future release.
    recipes: {
      'Radius.Compute/containers': {
        default: {
          templateKind: 'terraform'
          templatePath: 'git::https://github.com/zachcasper/recipes.git//kubernetes/containers'
        }
      }
      'Radius.Data/mySqlDatabases': {
        default: {
          templateKind: 'terraform'
          templatePath: 'git::https://github.com/zachcasper/recipes.git//kubernetes/mysql'
        }
      }
      'Radius.Data/neo4jDatabases': {
        default: {
          templateKind: 'terraform'
          templatePath: 'git::https://github.com/zachcasper/recipes.git//kubernetes/neo4j'
        }
      }
      'Radius.Data/postgreSqlDatabases': {
        default: {
          templateKind: 'terraform'
          templatePath: 'git::https://github.com/zachcasper/recipes.git//kubernetes/postgresql'
        }
      }
      'Radius.Data/redisCaches': {
        default: {
          templateKind: 'terraform'
          templatePath: 'git::https://github.com/zachcasper/recipes.git//kubernetes/redis'
        }
      }
    }
  }
}
