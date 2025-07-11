# Connection to MDB Atlas with IAM Role

We assume a role and fetch credentials with AWS STS.

We perform a simple hello ping to mongodb

```typescript
logger.info('Connecting to database');
if (!db) {
  db = await connectWithIAM();
}

const helloResult = await db.command({ hello: 1 });
```

## Atlas TF Provider

We create a private endpoint with Atlas API / Terraform provider to link to our private subnet

## STS

Requires a private endpoint to STS from the private vpc

Cache the connection (db) for future lambda runs to prevent lots of connections opening

```typescript
/**
 * Fetch environment variables from config
 */
const accessRoleArn = config.get('accessRoleArn');
const clusterHost = config.get('clusterHost');

let client: MongoClient | null = null;
let db: Db | null = null;

const sts = new STSClient();
const defaultConnOptions: MongoClientOptions = {
  // eg: maxPoolSize: 10, ssl: true, etc.
};

export async function connectWithIAM(
  options: MongoClientOptions = {},
): Promise<Db> {
  logger.info('Starting Connection...');

  if (db) {
    logger.info('Returning MongoClient db from cache');
    return db;
  }

  logger.info('No cached connection. Fetching credentials from STS...');

  const command = new AssumeRoleCommand({
    RoleArn: accessRoleArn,
    RoleSessionName: 'HealthCheckServiceConnection',
  });

  const { Credentials } = await sts.send(command);
  if (!Credentials) {
    throw new Error('Failed to assume MDB IAM role');
  }

  const { AccessKeyId, SessionToken, SecretAccessKey } = Credentials;

  const encodedAccessKey = encodeURIComponent(SecretAccessKey || '');
  const mdbUserCredentials = `${AccessKeyId}:${encodedAccessKey}`;

  logger.info('Preparing Connection String');

  // Cluster host is the full host i.e. {cluster_name}-{private_link_id}-{internal_project_id}
  // private_link_id is only set if using a private endpoint
  // internal_project_id is an Atlas internal 5 character unique string
  // for example {myatlascluster-pl-0.a0bc0}.mongodb.net
  const url = new URL(
    `mongodb+srv://${mdbUserCredentials}@${clusterHost}.mongodb.net`,
  );
  url.searchParams.set('authSource', '$external');
  url.searchParams.set(
    'authMechanismProperties',
    `AWS_SESSION_TOKEN:${SessionToken}`,
  );
  url.searchParams.set('w', 'majority');
  url.searchParams.set('retryWrites', 'true');
  url.searchParams.set('authMechanism', 'MONGODB-AWS');

  logger.info('Connecting to MongoDB');

  const mongoClient = new MongoClient(url.toString(), {
    ...defaultConnOptions,
    ...options,
  });

  client = await mongoClient.connect();

  const dbName = config.get('databaseName') || client.options.dbName;
  db = client.db(dbName);

  logger.info('Successfully connected to MongoDB, returning MongoClient db');
  return db;
}
```
