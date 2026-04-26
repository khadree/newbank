const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, PutCommand } = require("@aws-sdk/lib-dynamodb");
const { SNSClient, PublishCommand } = require("@aws-sdk/client-sns");

const ddbClient = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(ddbClient);
const snsClient = new SNSClient({});

exports.handler = async (event) => {
    for (const record of event.Records) {
        try {
            // 1. Parse the SQS message body
            const body = JSON.parse(record.body);
            console.log("Processing message:", body);

            // 2. Log to DynamoDB (Audit Trail)
            await docClient.send(new PutCommand({
                TableName: process.env.DYNAMO_TABLE,
                Item: {
                    TransactionID: body.transactionId || record.messageId,
                    Timestamp: Date.now(),
                    Message: body.message,
                    User: body.email || "Unknown"
                }
            }));

            // 3. Send Notification via SNS (SMS or Email)
            // If body has a phone number, it sends SMS; otherwise, it hits the Topic
            await snsClient.send(new PublishCommand({
                Message: `Alert: ${body.message}`,
                Subject: "NewBank Notification",
                TopicArn: process.env.NOTIFICATION_TOPIC, 
                // PhoneNumber: body.phone // Uncomment if sending direct SMS
            }));

            console.log("Successfully processed record:", record.messageId);
        } catch (error) {
            console.error("Error processing message:", error);
            // Throwing the error ensures SQS retries the message
            throw error; 
        }
    }
};
