# -------------------------------   code commit repository -----------------------------
resource "aws_codecommit_repository" "bastion-smoketest" {
  repository_name = "bastion-smoketest"
  description     = "smoke test scripts for the bastion."
}
