# Infrastructure as Code Labs

Terraform & Packer used to deploy infra in AWS.

## Getting started

* Install terraform

```sh
wget https://releases.hashicorp.com/terraform/0.10.8/terraform_0.10.8_linux_amd64.zip -O /tmp/terraform.zip
cd /tmp
unzip /tmp/terraform.zip
sudo install /tmp/terraform /usr/bin
```

* Install packer

```sh
wget https://releases.hashicorp.com/packer/1.1.1/packer_1.1.1_linux_amd64.zip -O /tmp/packer.zip
cd /tmp
unzip /tmp/packer.zip
sudo install /tmp/packer /usr/bin
```

* Set ssh key for keypair

```sh
ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa.iac
```

* Set AWS credentials

```sh
export AWS_ACCESS_KEY_ID="<your access key>"
export AWS_SECRET_ACCESS_KEY="<your secret key>"

```
## Configure AMI with packer

```sh
cd ami_web
packer validate ami_web.json
packer build ami_web.json
```

## Deploy vpc

```sh
cd vpc
terraform init
terraform validate
terraform plan
terraform apply
```

## Configure AMI with packer

```sh
cd ../ami_web
# Update vpc_id & subnet_id in ami_web/ami_web.json from value created in vpc
packer validate ami_web.json
packer build ami_web.json
```

## Deploy web
```sh
cd ../web
terraform init
terraform validate
terraform plan
terraform apply
```

* Get AWS elb url and reload it to see each web VM
