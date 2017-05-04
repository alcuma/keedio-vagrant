#!/bin/bash

#This script creates a custom /etc/hosts for Azure Vagrant nodes.

#Get all the IP's internal and public

az vm list-ip-addresses -g "$AZ_RESOURCE_GROUP_NAME" -o table |grep KDS > /tmp/az_hosts

echo "127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4" > ~/git/keedio-vagrant/ambari1/files/az_hosts
echo "::1         localhost localhost.localdomain localhost6 localhost6.localdomain6" >> ~/git/keedio-vagrant/ambari1/files/az_hosts

cat /tmp/az_hosts |awk -F" " '{print $2 "\t" $1".keedio.local""\t" $1}' >> ~/git/keedio-vagrant/ambari1/files/az_hosts
cat /tmp/az_hosts |awk -F" " '{print $3 "\t" $1".kds.local""\t"}' >> ~/git/keedio-vagrant/ambari1/files/az_hosts

rm -f /tmp/az_hosts