#!/bin/bash

set -e

# validate parameters
usage() 
{ 
        echo "Usage: $0 -g <resourceGroupName> -l <location> -d <dnslabel>" 1>&2; exit 1; 
 
}

# Initialize parameters specified from command line
while getopts ":g:l:s:k:i:d:e:j" o; do
	case "${o}" in
		g)	resourceGroupName=${OPTARG}
			;;
		l)	location=${OPTARG}
			;;
		d) dnsLabel=${OPTARG}
            ;;
		esac
done
shift $((OPTIND-1))

#Prompt for parameters is some required parameters are missing

if [ -z "$location" ]; then
	echo "Enter a location below to create a new resource group else skip this"
	echo "location:"
	read location
fi

if [ -z "$dnsLabel" ]; then
	echo "Enter the name of the dndLabel for the master load balancer"
	echo "dnsLabel:"
	read dnsLabel
fi

if [ -z "$resourceGroupName" ]; then
	echo "Enter the name of the resource group to store the custom script"
	echo "resourceGroupName:"
	read resourceGroupName
fi

#templateFile Path - template file to be used
templateFilePath=./azuredeploy.json

#parameter file path
#parametersFilePath="azuredeploy.parameters.json"


templatefile=./dcos-master-3agenttypes.template.json 
template=$(<$templatefile)

echo inject yaml into ARM template

fixup_yaml()
{

# REPLACE_USE_OAUTH
# REPLACE_MASTER_IPS

	local yamlfile=$1
	local pat=$2
	echo fixup $yamlfile
	customData=$(cat "$yamlfile"  \
	| sed 's/\"/\\\"/g' \
	| sed ':a;N;$!ba;s/\n/\\n/g' \
	| sed 's/REPLACE_DNSLABEL/'$dnsLabel'/g') 
	# echo "$customData" > cd.txt

	echo Replacing $pat
    template=${template/$pat/$customData} 
}


fixup_yaml "./cloud-config-template.master.yml" "REPLACE_MASTERCONFIG" 
fixup_yaml "./cloud-config-template.private.yml" "REPLACE_PRIVATECONFIG" 
fixup_yaml "./cloud-config-template.diskagent.yml" "REPLACE_DISKCONFIG" 
fixup_yaml "./cloud-config-template.public.yml" "REPLACE_PUBLICCONFIG" 

echo "Getting ready for deployment"
echo "$template" > azuredeploy.json

# deploy	
deploymentName='dep1'

#login to azure using your credentials
#azure login

#set the default subscription id
#azure account set $subscriptionId

#switch the mode to azure resource manager
#azure config mode arm

paramJson=$(echo { \"masterEndpointDNSNamePrefix\" : { \"value\" : \"$dnsLabel\"} , \"agentEndpointDNSNamePrefix\" : { \"value\" : \"${dnsLabel}agnt\"} })

echo Provisioning with $paramJson
echo $paramJson > azuredeploy.params.json

#Start deployment
echo "Starting deployment..."
azure group create --name $resourceGroupName --location $location
azure group deployment create -g $resourceGroupName --template-file $templateFilePath -e ./azuredeploy.params.json



