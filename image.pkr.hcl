variable "region" {
  type    = string
  default = "us-east-1"
}

# uncomment to keep image name unique and append -${local.timestamp} below
#locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

source "amazon-ebs" "swarm" {
  ami_name      = "trying-docker-swarm" # -${local.timestamp}
  instance_type = "t2.micro"
  region        = var.region
# If you need to overwrite your staticly named AMI, uncomment below
  force_deregister = true
  force_delete_snapshot = true
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"] # Canonical
  }
  ssh_username = "ubuntu"
}

build {
  sources = ["source.amazon-ebs.swarm"]
  # TODO - share var with terraform on pub key path
  # REALLY LAME that ~/ doesn't work :(
  provisioner "file" {
    source      = "../../.ssh/aws.pub"
    destination = "/tmp/aws.pub"
  }

  provisioner "shell" {
    script = "swarm.sh"
  }
}