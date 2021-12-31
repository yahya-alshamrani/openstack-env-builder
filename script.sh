#!/bin/bash

cat <<EOF > ./admin
unset OS_SERVICE_TOKEN
export OS_USERNAME=admin
export OS_PASSWORD='password'
export OS_REGION_NAME=RegionOne
export OS_AUTH_URL=http://10.0.0.50:5000/v3
export OS_PROJECT_NAME=admin
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_IDENTITY_API_VERSION=3
EOF

cat <<EOF > ./hr-user
unset OS_SERVICE_TOKEN
export OS_USERNAME=hr-user
export OS_PASSWORD='password'
export OS_REGION_NAME=RegionOne
export OS_AUTH_URL=http://10.0.0.50:5000/v3
export OS_PROJECT_NAME=hr
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_IDENTITY_API_VERSION=3
EOF

source admin
openstack project create hr --description 'HR Department'
openstack user create --project hr --password 'password' --email 'hr-user@localhost' hr-user
openstack role add --project hr --user hr-user _member_

openstack flavor create --id 6 --ram 256 --disk 1 --vcpus 1 --public m1.mini
openstack flavor create --id 7 --ram 128 --disk 1 --vcpus 1 --public m1.micro

curl -L https://download.cirros-cloud.net/0.3.5/cirros-0.3.5-x86_64-disk.img | openstack image create \
--container-format bare --disk-format qcow2 --public 'cirros-0.3.5'
curl -L https://download.cirros-cloud.net/0.4.0/cirros-0.4.0-x86_64-disk.img | openstack image create \
--container-format bare --disk-format qcow2 --public 'cirros-0.4.0'
curl -L https://download.cirros-cloud.net/0.5.2/cirros-0.5.2-x86_64-disk.img | openstack image create \
--container-format bare --disk-format qcow2 --public 'cirros-0.5.2'

openstack network create --share --external --provider-network-type flat --provider-physical-network extnet public
openstack subnet create --subnet-range '10.10.10.0/24' --no-dhcp --gateway '10.10.10.1' \
--network public --allocation-pool start=10.10.10.100,end=10.10.10.200 --dns-nameserver 8.8.8.8 public-subnet

source hr-user
openstack network create hr-network-1
openstack subnet create --subnet-range 192.168.1.0/24 --dhcp --network hr-network-1 --dns-nameserver 8.8.8.8 hr-network-1-subnet
openstack router create hr-router-1
openstack router add subnet hr-router-1 hr-network-1-subnet
openstack router set --external-gateway public hr-router-1
openstack security group create 'allow-ssh'
openstack security group rule create --dst-port 22:22 --protocol tcp --ingress 'allow-ssh'
openstack security group create 'allow-icmp'
openstack security group rule create --protocol icmp --ingress 'allow-icmp'

openstack server create --flavor m1.mini --image 'cirros-0.5.2' --network hr-network-1 \
--security-group default --security-group allow-ssh  --security-group allow-icmp i1

source admin
openstack floating ip create --floating-ip-address '10.10.10.101' --project hr public

source hr-user
openstack server add floating ip i1 '10.10.10.101'
