import { MongoClient, MongoClientOptions, Db } from 'mongodb';
import { config } from '@config/config';

import { AssumeRoleCommand, STSClient } from '@aws-sdk/client-sts';
import { URL } from 'url';
const accessRoleArn = config.get('accessRoleArn');
const clusterName = config.get('clusterName');

const sts = new STSClient();

let client: MongoClient | null = null;
let db: Db | null = null;

const defaultConnOptions: MongoClientOptions = {
  // eg: maxPoolSize: 10, ssl: true, etc.
};

export async function connectWithIAM(
  options: MongoClientOptions = {},
): Promise<Db> {
  console.log('Getting mongo client');
  if (db) {
    console.log('Returning mongo client in cache');
    return db;
  }
  const command = new AssumeRoleCommand({
    RoleArn: accessRoleArn,
    RoleSessionName: 'HealthCheckServiceConnection',
  });
  console.log('Fetching credentials', command);
  const { Credentials } = await sts.send(command);

  if (!Credentials) {
    throw new Error('Failed to assume mongo db IAM role');
  }

  const { AccessKeyId, SessionToken, SecretAccessKey } = Credentials;
  const encodedSecretKey = encodeURIComponent(SecretAccessKey || '');
  const combo = `${AccessKeyId}:${encodedSecretKey}`;
  const url = new URL(`mongodb+srv://${combo}@${clusterName}.mongodb.net`);
  url.searchParams.set('authSource', '$external');
  url.searchParams.set(
    'authMechanismProperties',
    `AWS_SESSION_TOKEN:${SessionToken}`,
  );
  url.searchParams.set('w', 'majority');
  url.searchParams.set('retryWrites', 'true');
  url.searchParams.set('authMechanism', 'MONGODB-AWS');

  console.log('Connecting with MongoClient');
  const mongoClient = new MongoClient(url.toString(), {
    ...defaultConnOptions,
    ...options,
  });
  client = await mongoClient.connect();

  const dbName = config.get('databaseName') || client.options.dbName;
  db = client.db(dbName);

  console.log('Successfully connected to mongo db, returning mongo client');
  return db;
}

/**
 * Optionally, you might want to expose the MongoClient instance for closing the connection
 */
export function getClient(): MongoClient | null {
  return client;
}

/** Disconnects the MongoDB client and resets cached connections. */
export async function disconnect(): Promise<void> {
  if (client) {
    console.log('DB Service: Disconnecting from database');
    await client.close();
    client = null;
    db = null;
    console.log('DB Service: Disconnected');
  }
}
