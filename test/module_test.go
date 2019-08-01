package module_test

import (
	"fmt"
	"strings"
	"testing"

	lb "github.com/telia-oss/terraform-aws-loadbalancer/v3/test"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestModule(t *testing.T) {
	tests := []struct {
		description string
		directory   string
		name        string
		region      string
		expected    lb.Expectations
	}{
		{
			description: "basic example",
			directory:   "../examples/basic",
			name:        fmt.Sprintf("lb-basic-test-%s", random.UniqueId()),
			region:      "eu-west-1",
			expected:    lb.Expectations{},
		},
		{
			description: "complete example",
			directory:   "../examples/complete",
			name:        fmt.Sprintf("lb-complete-test-%s", random.UniqueId()),
			region:      "eu-west-1",
			expected:    lb.Expectations{},
		},
	}

	for _, tc := range tests {
		tc := tc // Source: https://gist.github.com/posener/92a55c4cd441fc5e5e85f27bca008721
		t.Run(tc.description, func(t *testing.T) {
			t.Parallel()

			options := &terraform.Options{
				TerraformDir: tc.directory,

				Vars: map[string]interface{}{
					// aws_s3_bucket requires a lowercase name.
					"name_prefix": strings.ToLower(tc.name),
					"region":      tc.region,
				},

				EnvVars: map[string]string{
					"AWS_DEFAULT_REGION": tc.region,
				},
			}

			// Create aws bucket first to avoid "Provider produced inconsistent final plan":
			// When expanding the plan for module.lb.aws_lb.main to include new values learned so far during apply, provider "aws" produced an invalid new value for .access_logs[0].bucket: was cty.StringVal(""), but now cty.StringVal("lb-complete-test-ec52p520190801083106270600000001").
			bucket := &terraform.Options{
				TerraformDir: options.TerraformDir,
				Vars:         options.Vars,
				EnvVars:      options.EnvVars,
				Targets:      []string{"aws_s3_bucket.bucket", "aws_s3_bucket_policy.bucket"},
			}

			defer terraform.Destroy(t, options)
			terraform.InitAndApply(t, bucket)
			terraform.InitAndApply(t, options)

			lb.RunTestSuite(t, tc.region, tc.expected)
		})
	}
}
