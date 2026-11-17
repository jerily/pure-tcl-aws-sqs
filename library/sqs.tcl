# 
# Copyright Jerily LTD. All Rights Reserved.
# SPDX-FileCopyrightText: 2026 Neofytos Dimitriou (neo@jerily.cy)
# SPDX-License-Identifier: MIT.
# 

package require pure-tcl-aws-core 1.0.0
namespace eval ::aws::sqs {namespace path ::aws::core}
::aws::core::register sqs {create_queue get_queue_url delete_queue list_queues send_message receive_messages set_queue_attributes change_message_visibility delete_message delete_message_batch get_queue_attributes}

# Send a request using SQS's JSON protocol.
proc ::aws::sqs::call {client action fields {retry 0}} {json $client AmazonSQS.$action $fields 1.0 $retry}

# Create a queue and return its URL.
proc ::aws::sqs::_create_queue {client name} {dict get [call $client CreateQueue [dict create QueueName [list S $name]]] QueueUrl}

# Resolve an existing queue without creating it.
proc ::aws::sqs::_get_queue_url {client name} {dict get [call $client GetQueueUrl [dict create QueueName [list S $name]] 1] QueueUrl}

# Delete a queue and all messages it contains.
proc ::aws::sqs::_delete_queue {client url} {call $client DeleteQueue [dict create QueueUrl [list S $url]]; return 1}

# Follow queue-list pagination and return all URLs.
proc ::aws::sqs::_list_queues {client} {
    set fields [dict create MaxResults {N 1000}]; set out {}; set seen {}
    while {1} {
        set page [call $client ListQueues $fields 1]
        lappend out {*}[get $page QueueUrls]
        set token [get $page NextToken]
        if {![next seen $token]} {return $out}
        dict set fields NextToken [list S $token]
    }
}

# Send UTF-8 text once; ambiguous failures are not automatically retried.
proc ::aws::sqs::_send_message {client url message} {
    call $client SendMessage [dict create QueueUrl [list S $url] MessageBody [list S $message]]
    return 1
}

# Receive messages with the existing three-field dictionary shape.
proc ::aws::sqs::_receive_messages {client url {count 1}} {
    integer $count 1 10 max_number_of_messages
    set page [call $client ReceiveMessage [dict create QueueUrl [list S $url] MaxNumberOfMessages [list N $count]]]
    set out {}
    foreach m [get $page Messages] {lappend out [dict create MessageId [get $m MessageId] ReceiptHandle [get $m ReceiptHandle] Body [get $m Body]]}
    return $out
}

# Set queue attributes as strings, as required by SQS.
proc ::aws::sqs::_set_queue_attributes {client url attributes} {
    call $client SetQueueAttributes [dict create QueueUrl [list S $url] Attributes [stringmap $attributes]]
    return
}

# Change the visibility timeout of an in-flight message.
proc ::aws::sqs::_change_message_visibility {client url receipt seconds} {
    integer $seconds 0 43200 visibility_timeout_seconds
    call $client ChangeMessageVisibility [dict create QueueUrl [list S $url] ReceiptHandle [list S $receipt] VisibilityTimeout [list N $seconds]]
    return
}

# Acknowledge a successfully processed message.
proc ::aws::sqs::_delete_message {client url receipt} {
    call $client DeleteMessage [dict create QueueUrl [list S $url] ReceiptHandle [list S $receipt]] 1
    return
}

# Delete up to ten receipts and surface per-message failures.
proc ::aws::sqs::_delete_message_batch {client url receipts} {
    integer [llength $receipts] 1 10 receipt_count
    set entries {}; set id 0
    foreach receipt $receipts {lappend entries [list M [dict create Id [list S [incr id]] ReceiptHandle [list S $receipt]]]}
    set result [call $client DeleteMessageBatch [dict create QueueUrl [list S $url] Entries [list L $entries]] 1]
    if {[llength [get $result Failed]]} {aws_error sqs BatchFailure "message deletions failed: [dict get $result Failed]"}
    return
}

# Return all queue attributes as a Tcl dictionary.
proc ::aws::sqs::_get_queue_attributes {client url} {
    get [call $client GetQueueAttributes [dict create QueueUrl [list S $url] AttributeNames [strings All]] 1] Attributes
}
package provide pure-tcl-aws-sqs 1.0.0
package provide awssqs 1.0.19
