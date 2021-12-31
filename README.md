# openstack-environment-builder-for-packstack-openstack
<h3>Building an environment in openstack</h3>
<h3>This environment tested in virtualbox</h3>

<h3>Requirements</h3>

- A virtual machine with two network interfaces
- Interface A: Host-only Network - to access openstack from the host OS
  -   IPv4 Address: 10.0.0.1
  -   IPv4 Network Address: 255.255.255.0
  -   Enable DHCP Address
  -   DHCP Server Address: 10.0.0.2
  -   Lower Address Bound: 10.0.0.10
  -   Upper Address Bound: 10.0.0.254
- Interface B: NAT Networking used for the gust OS to access the internet plus openstack instances access the internet
  -   Network CIDER=10.10.10.0/24 
  -   DHCP is enabled
	
