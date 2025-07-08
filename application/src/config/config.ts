const convict = require('convict');

export const config = convict({
  // shared config
  stage: {
    doc: 'The stage being deployed',
    format: String,
    default: '',
    env: 'STAGE',
  },
  dbConnectionSecret: {
    doc: 'The secret name for the database',
    format: String,
    default: 'dbConnectionSecret',
    env: 'DB_CONNECTION_SECRET',
  },
  databaseName: {
    doc: 'The name of the database',
    format: String,
    default: 'test',
    env: 'DB_NAME',
  },
  accessRoleArn: {
    doc: 'The arn of the iam role',
    format: String,
    default: 'accessRoleArn',
    env: 'MDB_ACCESS_ROLE_ARN',
  },
  clusterName: {
    doc: 'The name of the cluster for connection string',
    format: String,
    default: 'clusterName',
    env: 'MDB_CLUSTER_NAME',
  },
}).validate({ allowed: 'strict' });
