import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';
import { MetricUnit, Metrics } from '@aws-lambda-powertools/metrics';
import { getHeaders, errorHandler, logger } from '@shared';
import { Tracer } from '@aws-lambda-powertools/tracer';
import { captureLambdaHandler } from '@aws-lambda-powertools/tracer/middleware';
import { injectLambdaContext } from '@aws-lambda-powertools/logger/middleware';
import { logMetrics } from '@aws-lambda-powertools/metrics/middleware';
import middy from '@middy/core';
import httpErrorHandler from '@middy/http-error-handler';

import { config } from '@config';
import { connectWithIAM } from '@shared/databases-services/health-check-service/connection';

const tracer = new Tracer();
const metrics = new Metrics();

const stage = config.get('stage');

let db: ReturnType<typeof connectWithIAM> extends Promise<infer DB>
  ? DB
  : never;

export const healthCheck = async ({
  body,
}: APIGatewayProxyEvent): Promise<APIGatewayProxyResult> => {
  try {
    logger.info('Connecting to database');
    if (!db) {
      db = await connectWithIAM();
    }

    const helloResult = await db.command({ hello: 1 });

    metrics.addMetric('SuccessfulHealthCheck', MetricUnit.Count, 1);
    return {
      statusCode: 200,
      body: JSON.stringify(helloResult),
      headers: getHeaders(stage),
    };
  } catch (error) {
    let errorMessage = 'Unknown error';
    if (error instanceof Error) errorMessage = error.message;
    logger.error(errorMessage);

    metrics.addMetric('HealthCheckError', MetricUnit.Count, 1);

    return errorHandler(error);
  }
};

export const handler = middy(healthCheck)
  .use(injectLambdaContext(logger))
  .use(captureLambdaHandler(tracer))
  .use(logMetrics(metrics))
  .use(httpErrorHandler());
