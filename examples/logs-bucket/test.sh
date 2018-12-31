#!/bin/sh
set -eo pipefail

# for integer comparisons: check_counts <testValue> <expectedValue> <testName>
check_counts() {
 if [ $1 -eq $2 ]
 then
   echo "√ $3"
 else
   echo "✗ $3"
   tests_failed=$((tests_failed+1))
fi
}

tests_failed=0

export AWS_DEFAULT_REGION=eu-west-1

elb_name=`cat terraform-out/terraform-out.json |jq -r '.name.value'`
bucket_name=`cat terraform-out/terraform-out.json |jq -r '.access_logs_bucket_arn.value' |awk '{print substr($0,14)}'`
account_id=`aws sts get-caller-identity | jq -r .Account`

active_count=`aws elbv2 describe-load-balancers --names $elb_name | jq  '.LoadBalancers[]| select (.State.Code=="active")'| jq -s length`
test_file_check=`aws s3api wait object-exists --bucket $bucket_name --key AWSLogs/$account_id/ELBAccessLogTestFile`

check_counts $active_count 1 "Load Balancer Active"
check_counts $test_file_check 0 "Test File Written by Loadbalancer"

# remove test file so that destroy can remove the bucket
aws s3 rm s3://$bucket_name/AWSLogs/$account_id/ELBAccessLogTestFile

exit $tests_failed