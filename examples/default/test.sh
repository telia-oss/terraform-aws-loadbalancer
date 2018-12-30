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

echo $elb_name

active_count=`aws elbv2 describe-load-balancers --names $elb_name | jq  '.LoadBalancers[]| select (.State.Code=="active")'| jq -s length`


check_counts active_count 1 "Load Balancer Active"
exit $tests_failed