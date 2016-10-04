# Custom DCOS template with 3 agent types

ACS deployment with customizable node configurations. Many applicaitions require local volumes on the hosts.

This template deploys:
* 3 masters
* public agents
* private agents without local dataDisks 
* private agents with local dataDisks mounted as host volumes

## Private Agents with Disk Configuration
* 2 local dataDisks
* disks attached to VM and mounted at cluster creation time in cloud-config.txt
* Custom Mesos attribute HasDisk is defined as "true" 

## Deploy from Azure CLI
Other custom ACS templates fail to deploy because line feeds get lots in translation from customData in the template to user-data.txt on the VM to cloud-config.txt on the VM.

This template create the customData from the YAML templates. The templates are written to make sure translation all the way to cloud-config.txt goes well. Note the double \\ in 

```
- echo UUID=$(sudo /sbin/blkid | grep md127 | cut -d\\" -f 2) /dcos/volume0 ext4 defaults 0 2 >> /etc/fstab
```
and 

```
- bash -c "try=1;until dpkg -i /tmp/{1,2,3,4}.deb || ((try>9));do echo retry \\$((try++));sleep
    \\$((try*try));done"
```

The ```\\``` is required to ensure proper formatting of the cloud-config.txt.