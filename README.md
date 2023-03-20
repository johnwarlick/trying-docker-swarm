# AWS
The Terraform and Packer files are all right now only focused on AWS. I'll refactor a bit when I get to setting it up for Azure, GCP, and DigitalOcean. 

## TODO 
- Set up more than one EC2
- Explore cloud-init, decide on mix of that and/or Ansible for getting Swarm configured 
- Get that automation finished and then add in deploying the mock app 

# Multipass 
Using multipass right now to set up a manager and two workers on my Macbook Pro. Currently the Ansible files are all focused on this. I am using https://xavier-pestel.medium.com/an-easy-way-to-install-a-docker-swarm-cluster-with-ansible-ebebada3c116 and https://techsparx.com/software-development/docker/swarm/multipass.html to jumpstart the process. 