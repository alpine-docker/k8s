#!/bin/bash

# Run v1 or v2 of the aws cli based on env var
if [[ -n "$AWS_CLI" && ("$AWS_CLI" == "v2" || "$AWS_CLI" == "2") ]]; then
    exec /usr/local/bin/awsv2 "$@"
else
    exec /usr/local/bin/awsv1 "$@"
fi
