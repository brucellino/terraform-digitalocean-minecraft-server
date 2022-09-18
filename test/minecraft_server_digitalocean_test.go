package test

import "testing"
import "github.com/gruntwork-io/terratest/modules/terraform"

func TestMinecraftServerDigitalocean(t *testing.T) {
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/simple",
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndValidate(t, terraformOptions)
}
