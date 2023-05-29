# How to use this script

### SSH configuration

You may need to change the default port for ssh on the NVR. This is beacuse the router also checks for incoming ssh connections on port 22. Either change the ssh port on the router from 22, or use this script to change the NVR ssh port from 22. Supply --ssh as an argument and this script will automaticaly change the ssh port to 23. Use --port to change the port to a value other than 23.

### Using the script

Execute the following command from within the shell of the system that is to be configured.  
This can be done remotely with an active ssh connection, however the connection will drop while executing this script.

    curl -sSL https://raw.githubusercontent.com/n1s3/interface-config/master/setup.sh | sh
    
If you need to specify any arguments to the script, this can be done like so.

    curl -sSL https://raw.githubusercontent.com/n1s3/interface-config/master/setup.sh | sh -s -- --ssh -p 23 -i eth1
 
 You may specify any arguments you wish, just supply each arg following the '--' double dash.

## Interface config

### setup.sh options

#### --ssh | -s

Do ssh config.  
This is optional, and defaults to false.  
Providing this flag will enable ssh configuration.  

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
