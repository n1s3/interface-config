## Interface config

### setup.sh options

#### --ssh | -s

Do ssh config.  
This is optional, and defaults to false.  
Providing this flag will enable ssh config.  

#### --port | -p

SSH port to configure.  
Defaults to 23.  

#### --interface | -i

Interface to configure.  
Defaults to eth1  

#### --addr | -I

IP address to set interface to.  
Defaults to 192.168.20.10/24  
Provide this param in cidr notation.  

#### --gateway | -g

Gateway to set interface to.  
Defaults to X.X.X.1

#### --dns | -d

DNS server to set interface to.  
Defaults to 1.1.1.1  
