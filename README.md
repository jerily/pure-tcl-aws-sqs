# pure-tcl-aws-sqs

AWS SQS client implemented in Tcl 9.1. Its only package dependency is
[`pure-tcl-aws-core`](https://github.com/jerily/pure-tcl-aws-core), which supplies
HTTP, JSON, XML, credentials and signing. No AWS C++ SDK is required.

```tcl
package require pure-tcl-aws-sqs 1.0.0
set client [::aws::sqs::create {region us-east-1}]
try {
    puts [$client list_queues]
} finally {
    $client destroy
}
```

`package require awssqs 1.0.19` is also supported. Use one implementation
of the `awssqs` package per interpreter. Existing namespace commands
(`::aws::sqs::method $client ...`) and client methods share the same behavior.
Client destruction returns an empty result. Unknown methods and invalid arguments
raise Tcl errors. See the core README for credentials, configuration and retries.

## Methods

| Method | Arguments after the client handle |
| --- | --- |
| `create_queue` | `name` |
| `get_queue_url` | `name` |
| `delete_queue` | `url` |
| `list_queues` | — |
| `send_message` | `url message` |
| `receive_messages` | `url ?count?` |
| `set_queue_attributes` | `url attributes` |
| `change_message_visibility` | `url receipt seconds` |
| `delete_message` | `url receipt` |
| `delete_message_batch` | `url receipts` |
| `get_queue_attributes` | `url` |

## Behavior

`send_message` and `delete_queue` return `1`; `create_queue` and `get_queue_url` return queue URLs. `receive_messages` returns dictionaries containing `MessageId`, `ReceiptHandle`, and `Body`. Batch deletions report partial failures. Sending and receiving are not automatically retried after ambiguous failures.

## Install and examples

Install the core and its dependencies first, then run:

```sh
make install PREFIX=/your/prefix
```

The release recipe declares examples with `file` entries. After registry installation:

```sh
ttrek run -package pure-tcl-aws-sqs -script example-list-queues
ttrek run -package pure-tcl-aws-sqs -script example-queue-url -- queue-name
```

`./run-example.sh --help` lists arguments. Set AWS credentials and `AWS_REGION`
or `AWS_DEFAULT_REGION` before running AWS examples. Examples read resources or sign URLs.

## Tests

With Tcl 9.1 and the dependencies on `TCLLIBPATH`:

```sh
make test TCLSH=tclsh9.1
```

Python 3 supplies local HTTP fixtures. Tests use fake credentials and do not
contact AWS. They check requests, result formats, and error handling.

## Install with ttrek

If you do not have the ttrek client, get it from [ttrek.sh](https://ttrek.sh).
Then install the package:

```sh
ttrek install pure-tcl-aws-sqs
```
