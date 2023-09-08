resource "random_pet" "suffix" {}

module "terraform-azure-function-scheduler-stop-start" {
  source = "../.."
}
