# keedio-vagrant


## Introduction
This is a Vagrant based test environment, designed to test the integration of the different packages of the Keedio software stack, which can be used to deploy virtual clusters using either Ambari or by manually configuring the services.
A hiera based configuration file can be used to adapt Keedio-vagrant to different environments and requirements. 
By default it uses the Keedio public repository to install the packages. To limit the external bandwidth requirement, a local mirror of the main keedio repository repo.keedio.org can be created in a VM called buildoop. The same VM contains the buildoop packaging system and can be used to build new versions of the software components. These new versions can then be deployed to the test VMs using the local repo.
The vagrant plugin "vagrant-vbox-snapshot" can be used to snapshot the state of the cluster, and move easily back and forward in time by selecting the right snapshot.


## Obtaining access to Keedio stack
Keedio uses Red Hat satellite to manage the distribution of its Keedio stack, in order to install it stack you need to request an activation code.   You can request it here  https://www.keedio.org/demo/

You have to use it in the setup process. 

As an alternative you can package your own repository using buildoop and you can tell keedio-vagrant to use default yum repositories by setting the variable satellite: false in ./hiera/configuration.yaml.


#Preliminary steps

Install Vagrant and Virtualbox before starting.  
Make sure you install the vagrant snapshotting plugin for virtualbox 
```
vagrant plugin install vagrant-vbox-snapshot
```
Install hiera-eyaml ruby gem
```
gem install hiera-eyaml
```
Download the keedio-vagrant stack

```
git clone --recursive https://github.com/keedio/keedio-vagrant.git
cd  keedio-vagrant
```

#Setup the cluster
The following procedure is required and independent from hypervisor or cloud provider.
```
./setup.sh
####################################################
Setting up environment for Keedio Stack deployment
This will use default encryption keys and passwords
Please use setup_secure.sh if you want to change them
#####################################################
[hiera-eyaml-core] hiera-eyaml (core): 2.0.8
Please provide the activation key:
####################################################
The hiera/secure.eyaml file has been created
You can check the values and modify it with the command

eyaml edit hiera/secure.eyaml
#####################################################
```
## Optional: setup the cluster in secure mode

To generate new encryption keys, and set non default password you can issue the foillowing command:
```
./setup_secure.sh

####################################################
Setting up environment for Keedio Stack deployment
This will use default encryption keys and passwords
Please use setup_secure.sh if you want to change them
#####################################################
[hiera-eyaml-core] hiera-eyaml (core): 2.0.8
Creating Hiera encryption keys
Are you sure you want to overwrite "./keys/private_key.pkcs7.pem"? (y/N): y
Are you sure you want to overwrite "./keys/public_key.pkcs7.pem"? (y/N): y
[hiera-eyaml-core] Keys created OK
Please provide the activation key:
Please provide the admin password for the backend database:[adminadmin]
Please provide the hue user password for the backend database:[hue]
Please provide the hive user password for the backend database:[hive]
Please provide the oozie user password for the backend database:[oozie]
Please provide the ambari user password for the backend database:[bigdata]
Please provide the Free IPA admin password:[adminadmin]
Please provide the Ambari admin password:[admin]
####################################################
The hiera/secure.eyaml file has been created
You can check the values and modify it with the command

eyaml edit hiera/secure.eyaml
#####################################################
Making a backup-copy of the existing ssh keys in ./files/ssh-backup
Generating new ssh keys in ./files/.ssh/
Generating public/private rsa key pair.
./files/.ssh/id_rsa already exists.
Overwrite (y/n)? y
Your identification has been saved in ./files/.ssh/id_rsa.
Your public key has been saved in ./files/.ssh/id_rsa.pub.
The key fingerprint is...
```

# Keedio-vagrant with Virtualbox

## Preliminary steps


Populate the /etc/hosts of your machine with the provided information
```
sudo cat  append-to-etc-hosts.txt  >> /etc/hosts
```
Prepare Vagrantfile and configuration.yaml
```
cd  ambari1
cp vagrantfiles/Vagrantfile.virtualbox Vagrantfile
cp configurations/standard-user.yaml hiera/configuration.yaml
```




Start the cluster:
You can now start your ambari cluster, you should always start the master machine, and a number of slaves (ambari1, ambari2, ambari3...)

```
vagrant up master ambari1 ambari2
```

this can take several minutes, when it is complete you should be able to access the Ambari web page: master.ambari.keedio.org:8080. The default credentials are both "admin".

 
You can suspend the execution of all the VMs with
```
vagrant suspend
```

And restart with 

```
vagrant resume
```
# Keedio-vagrant on AWS

## Preliminary steps

For use AWS for deployment you need the following things:

- An account on Amazon Web Services.
- Install aws-cli (http://docs.aws.amazon.com/cli/latest/userguide/installing.html)
- Install the Vagrant plugin for AWS

## Installing AWS-CLI

We strongly recommended to follow the installation guide from AWS doc (see the url).
If you had pip already installed:

```
pip install --upgrade --user awscli
```
For install pip:

```
curl -O https://bootstrap.pypa.io/get-pip.py
python3 get-pip.py --user
```
For add the AWS-CLI executable to your command line path, add the export command to profile script:

```
export PATH=~/.local/bin:$PATH
```

Then, load the profile into your current session:

```
source ~/.bash_profile
```

## Configuring AWS-CLI

First of all, you need to configure AWS:

```
aws configure
```
NOTE: Output format in Json.

In order to interact with AWS, we'll need to get AWS tokens. Execute the next command and follow keep safe the tokens printed on the screen:

```
aws sts get-session-token
```

## Install the AWS Vagrant plugin

```
vagrant plugin install vagrant-aws
```

## Creating the security group

You can change rules in the future:

```
aws ec2 create-security-group --group-name kdssg --description "Security group for KDS services"
aws ec2 authorize-security-group-ingress --group-name kdssg --protocol udp  --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-name kdssg --protocol tcp  --cidr 0.0.0.0/0

```


## Getting the security group id
You can use the default group, it is all open:

```
aws ec2 describe-security-groups --group-names kdssg |grep GroupId
```

## Create keypair
You will need also a keypair on AWS, take a look to the next URL for learn how to create it on AWS: http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html
You can create it from CLI:

```
aws ec2 create-key-pair --key-name MyKeyPair
```

You need to save the output to a file.

## Create the Vagrantfile

```
cp -p vagrantfiles/Vagrantfile.aws Vagrantfile
```

## Moving the configuration.yaml file

```
cp -p configurations/configuration_aws.yaml hiera/configuration.yaml
```

## Exporting the ENV variables
In order to use Vagrant, you will need to write some variables on the Vagrant file:

- AWS_INSTANCE_TYPE (default is t2.medium)
- AWS_VPC_SUBNET_ID
- AWS_VPC_SECURITY_GROUP
- AWS_ACCESS_KEY_ID (get on token-session)
- AWS_SECRET_ACCESS_KEY
- AWS_KEYPAIR_NAME (MyKeyPair)
- AWS_SSH_PRIVATE_KEY_PATH (path to your id_rsa)
- AWS_REGION OR AWS_DEFAULT_REGION
- AWS_SESSION_TOKEN

You can also export it like ENV variables:

```
export VARIABLE="value"
```

## Launching Vagrant AWS

1- Edit hiera/default:
```
nameresolution: 'script' ======> nameresolution: 'aws'
```

2- Vagrant up:

```
vagrant up --provider=aws --no-provision
```

3- Exec the aws_hosts.sh script:
When vagrant up is finished, you need to launch this script for create the /etc/hosts.

```
bash aws_hosts.sh
```

4- Run rsync:

```
vagrant rsync
```

5- Run the provision:

```
vagrant provision
```

NOTE: This phase can take a long time, so you can go for a coffee and take a break. 

# Keedio-vagrant on Azure

## Preliminary steps

For use Azure for deployment you need the following things:

- At least a trial account on Microsoft Azure.
- Install Azure-cli (https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- Install the Vagrant plugin for Azure

## Installing Azure CLI

You can try install it with the Microsoft install notes for Azure CLI (strongly recommended):

```
curl -L https://aka.ms/InstallAzureCli | bash
```
You must restart the shell:

```
exec -l $SHELL
```

## Configuring Azure CLI

In order to interact with Azure machines, we'll need to do login in our Azure's account. Execute the next command and follow the steps printed $

```
az login
```

If you want to be sure that it have been logged:

```
az account list
```

## Generating keys for Azure deployments

The Azure provider seems to only like PEM files with both the public and private keys, and X509 certificates, so let’s get us some of that:

```
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ~/.ssh/azurevagrant.key -out ~/.ssh/azurevagrant.key
chmod 600 ~/.ssh/azurevagrant.key
openssl x509 -inform pem -in ~/.ssh/azurevagrant.key -outform der -out ~/.ssh/azurevagrant.cer
```
The .cer file contains our public key, but the .pem file contains both our public and private keys, so we’ll need to secure it appropriately.
Now we can upload that .cer file as a management certificate in Azure using the browser.

# Install the Azure Vagrant plugin

```
vagrant plugin install vagrant-azure --plugin-version '2.0.0.pre6'
```

# Export env variables
In order to use Azure Vagrant you will need to export some variables. First of all, we need to get some info:

```
az ad sp create-for-rbac
```

Keep an eye on the output, you are going to need it.

The list of variables is the following:

- AZ_VM_SIZE=ENV["AZ_VM_SIZE"] || "Standard_D1_v2" (Default value)
- AZ_RESOURCE_GROUP_NAME=ENV["AZ_RESOURCE_GROUP_NAME"] || "KDSRG" (Default value)
- AZ_KEYPAIR_PATH=ENV["AZ_KEYPAIR_PATH"]
- AZ_SUBCRIPTION_ID=ENV["AZ_SUBCRIPTION_ID"]
- AZ_TENANT_ID=ENV["AZ_TENANT_ID"]
- AZ_CLIENT_ID=ENV["AZ_CLIENT_ID"]
- AZ_CLIENT_SECRET=ENV["AZ_CLIENT_SECRET"]
- AZ_LOCATION=ENV["AZ_LOCATION"]

You can export it executing the next command:

```
export VARIABLE="value"
```

# Create the Vagrant file

```
cp -p vagrantfiles/Vagrantfile.azure Vagrantfile
```

## Moving the configuration.yaml file

```
cp -p configurations/configuration_az.yaml hiera/configuration.yaml
```

# Launching Vagrant Azure

1- Edit hiera/default:
```
nameresolution: 'script' ======> nameresolution: 'azure'
```

2- Vagrant up:

```
vagrant up --provider=azure --no-provision --no-parallel
```

3- Exec the az_hosts.sh script:
When vagrant up is finished, you need to launch this script for create the /etc/hosts.

```
bash az_hosts.sh
```

4- Run rsync:

```
vagrant rsync
```

5- Run the provision:

```
vagrant provision
```

NOTE: This phase can take a long time, so you can go for a coffee and take a break.

# Optional:  Enabling Free IPA

Free IPA is a RedHat service that provides LDAP and Kerberos authentication, you need to enable it only if you want to test the securization of your cluster. We reccomend enabling it after the VMs have been started. In order to do that you have to change the hiera/configuration.yaml file.
```
ipa: true
```
Then you have to reprovision all the VMs
```
vagrant provision
```

# Managing passwords 

We use hiera-eyaml to encrypt passwords in the file /keedio-vagrant/ambari1/hiera/secure.eyaml. Full descrition of hiera-email can be found here https://github.com/TomPoulton/hiera-eyaml. Here we give a quick introduction. 
To install hiera-eyaml 
```
gem install hiera-eyaml
```
You need to move to ambari1 folder. 

You can view and edit existing passwords with 
```
eyaml edit hiera/secure.eyaml
```
You can create new encryption  keys with 
```
eyaml createkeys
```
You can encrypt passwords with 
```
eyaml encrypt -s 'password'
```
You can take the output and paste it manually into hiera/secure.eyaml using any editor.  









