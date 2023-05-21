package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestMinecraftServerDigitalocean(t *testing.T) {
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/simple",
		// EnvVars: {
		// 	"CONSUL_HTTP_ADDR": "http://bare.station:8500"
		// },
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndValidate(t, terraformOptions)
	// terraform.InitAndApply(t, terraformOptions)
}
