## Loadbalancer

[![Build Status](https://travis-ci.com/telia-oss/terraform-aws-loadbalancer.svg?branch=master)](https://travis-ci.com/telia-oss/terraform-aws-loadbalancer)

Module for creating an ALB or NLB. In the case of an ALB it also takes care of setting up
a security group with all egress. The module however, does not create ingress security group rules. See the default example on how to do that.

The module can also create a Cloud Watch Dashboard that will display target response times,
active connections and request count.
