from support import Fixture, run, verify_signature
import json


class Handler(Fixture):
    def route(self, body):
        assert verify_signature(self, body) == "sqs"
        data = json.loads(body)
        action = self.headers["X-Amz-Target"].split(".")[-1]
        if action == "CreateQueue":
            assert data == {"QueueName": "queue"}
            result = {"QueueUrl": "queue-url"}
        elif action == "ListQueues":
            if "NextToken" in data:
                assert data["NextToken"] == "next+/?"
                result = {"QueueUrls": ["two"]}
            else:
                result = {"QueueUrls": ["one"], "NextToken": "next+/?"}
        else:
            assert data["QueueUrl"] == "queue-url"
            if action == "SetQueueAttributes":
                assert data["Attributes"] == {"VisibilityTimeout": "60"}
                result = {}
            elif action == "GetQueueAttributes":
                assert data["AttributeNames"] == ["All"]
                result = {"Attributes": {"VisibilityTimeout": "60"}}
            elif action == "ChangeMessageVisibility":
                assert data["ReceiptHandle"] == "receipt" and data["VisibilityTimeout"] == 30
                result = {}
            elif action == "DeleteMessageBatch":
                assert data["Entries"] == [{"Id": "1", "ReceiptHandle": "good"}, {"Id": "2", "ReceiptHandle": "bad"}]
                result = {"Successful": [{"Id": "1"}], "Failed": [{"Id": "2", "Code": "InvalidId", "Message": "invalid"}]}
            else:
                assert action == "DeleteQueue"
                result = {}
        self.reply(200, result)


if __name__ == "__main__":
    run(Handler, "extra.test")
