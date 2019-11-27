data "aws_iam_policy_document" "bastion-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_instance_profile" "bastion_profile" {
  name = "bastion_profile_${terraform.workspace}"
  role = "${aws_iam_role.bastion_role.name}"
}

# TODO: define rule for keypair to use
resource "aws_key_pair" "sandbox-key" {
  key_name   = "sandbox-key-${terraform.workspace}"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}

data "aws_ami" "ami-amz" {
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

  most_recent = true
  owners      = ["amazon"]
}

# TODO: use spot instance
resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.ami-amz.id
  instance_type               = "t2.micro"
  vpc_security_group_ids      = ["${aws_security_group.allow_ssh.id}"]
  subnet_id                   = "${data.terraform_remote_state.component_network.outputs.sn_public_a_id}"
  associate_public_ip_address = true
  user_data                   = "${file("install-bastion.sh")}"
  iam_instance_profile        = "${aws_iam_instance_profile.bastion_profile.name}"
  key_name                    = "sandbox-key-${terraform.workspace}"

  tags = "${
    map(
      "Name", "Bastion-${terraform.workspace}",
      "Plateform", "${terraform.workspace}"
    )
  }"
}
