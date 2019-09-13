## Loadbalancer

[![workflow](https://github.com/telia-oss/terraform-aws-loadbalancer/workflows/workflow/badge.svg)](https://github.com/telia-oss/terraform-aws-loadbalancer/actions)

Module for creating an ALB or NLB. In the case of an ALB it also takes care of setting up a security group with all egress. The module however, does not create ingress security group rules. See examples for more information.
