const AWS = require('aws-sdk');
const ddb = new AWS.DynamoDB.DocumentClient();

exports.handler = (event, context, callback) => {
  if (event.requestContext) {
    //  event.path = '/id/3'
    if (event.path && event.path.split('/').length === 3) {
      const entityId = event.path.split('/')[2];
      console.log('entityId', entityId);
      const entityPromise = getEntity(entityId);
      entityPromise.then(() => {
        successResponse.body = JSON.stringify(successResponse.body);
        console.log('successResponse', successResponse);
        callback(null, successResponse);
      });
      entityPromise.catch((err) => {
        console.error('entityPromise error', err);
        errorResponse(err.message, context.awsRequestId, callback);
      });
    } else {
      const entitiesPromise = getEntities();
      entitiesPromise.then(() => {
        successResponse.body = JSON.stringify(successResponse.body);
        callback(null, successResponse);
      });
      entitiesPromise.catch((err) => {
        errorResponse(err.message, context.awsRequestId, callback);
      });
    }
  }
  var params = {
    TableName: 'a-table-name'
  };

  var responseBody = {
    data: []
  };

  var successResponse = {
    statusCode: 200,
    headers: {
      'Content-Type': 'application/json; charset=utf-8'
    },
    'body': responseBody,
    'isBase64Encoded': false
  };

  function getEntity(entityId) {
    const getEntityParams = {
      TableName: 'a-table-name',
      Key: {
        "id": entityId
      }
    };
    return ddb.get(getEntityParams, function(error, data) {
      if (error) {
        console.error('error on getting item', error);
        responseBody.data.push(`Error getting entity, entityId: ${entityId}`);
      } else {
        responseBody.data.push(data);
      }
    }).promise();
  }

  function getEntities() {
    const params = {
      TableName: 'a-table-name'
    };
    return ddb.scan(params, scanCallback).promise();
  }
  function scanCallback(error, results) {
    if (error) {
      console.error('Error inside of scan callback', error);
    } else {
      results.Items.forEach(function(item) {
        responseBody.data.push(item);
      });
    }
    if (!typeof results.LastEvaluatedKey) {
      params.ExclusiveStartKey = results.LastEvaluatedKey;
      ddb.scan(params, scanCallback);
    }
  }

  function errorResponse(errorMessage, awsRequestId, callback) {
    callback(null, {
      statusCode: 500,
      body: JSON.stringify({
        Error: errorMessage,
        Reference: awsRequestId
      }),
      headers: {
        "Access-Control-Allow-Origin": '*',
        "Content-Type": "application/json; charset=utf-8"
      },
      "isBase64Encoded": false
    });
  }
}