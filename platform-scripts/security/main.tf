# ------------------------ IAM role for bastion instance -------------------------------------------------

resource "aws_iam_role" "bastion_role" {
  name_prefix           = "bastion"
  path                  = "/"
  description           = "roles policy the bastion uses"
  force_detach_policies = true
  assume_role_policy    = "${file("${path.module}/templates/ec2-service-role-policy.json")}"
}

resource "aws_iam_role_policy_attachment" "bastion-role-codecommit" {
  role       = "${aws_iam_role.bastion_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeCommitReadOnly"
}

resource "aws_iam_instance_profile" "bastion_profile" {
  name_prefix = "bastion"
  role        = "${aws_iam_role.bastion_role.name}"
}

# --------------------------------------------------------------------------------------------------------------
# roles to assign to the EC2 instance(s)
# --------------------------------------------------------------------------------------------------------------
resource "aws_iam_role" "test_ssm_role" {
  name_prefix           = "testssm"
  path                  = "/"
  description           = "roles polices the test can use"
  force_detach_policies = true
  assume_role_policy    = "${file("${path.module}/templates/ssm-service-role-policy.json")}"
}

resource "aws_iam_instance_profile" "test_ssm_profile" {
  name_prefix = "testssm"
  role        = "${aws_iam_role.test_ssm_role.name}"
}
