# Custom DCOS template with 3 agent types

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fxtophs%2Fdcos-multi-agent-type%2Fmaster%2Fazuredeploy.json" target="_blank">
<img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fxtophs%2Fdcos-multi-agent-type%2Fmaster%2Fazuredeploy.json" target="_blank">
<img src="http://armviz.io/visualizebutton.png"/>
</a>

ACS deployment with customizable node configurations. Many applicaitions require local volumes on the hosts.

This template deploys:
* 3 masters
* 3 public agents
* 1 private agent without local dataDisks 
* 1 private agent with local dataDisks mounted as host volumes

## Private Agents with Disk Configuration
* 2 local dataDisks
* disks attached to VM and mounted at cluster creation time in cloud-config.txt
* Custom Mesos attribute HasDisk is defined as "true" 

## Deploy from Azure CLI
[Other custom ACS templates](https://github.com/anhowe/acs/tree/master/dcos-attacheddisks) fail to deploy because line feeds get lost in translation from customData in the template to user-data.txt on the VM to cloud-config.txt on the VM.

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

## Known Issues
Navstar crashes with Standard_A1 sized agents.