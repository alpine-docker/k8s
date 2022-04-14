#!/bin/sh
[ "v2" == "$awscli" ] && ln -s /usr/local/bin/awsv2 /usr/bin/aws || ln -s /usr/local/bin/awsv1 /usr/bin/aws

exec "$@"