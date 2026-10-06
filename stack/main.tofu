# Issue sluiceway/sluiceway#292: one stack, so that a scan runs at all.
terraform {
  required_version = ">= 1.11.0"
}

resource "terraform_data" "note" {
  input = "issue 292"
}
