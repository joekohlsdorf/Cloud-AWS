#!/bin/bash
DG="\033[1;30m"
RD="\033[0;31m"
NC="\033[0;0m"
LB="\033[1;34m"
all_done(){
    echo -e "$LB"
    echo '  __                        _'
    echo ' /\_\/                   o | |             |'
    echo '|    | _  _  _    _  _     | |          ,  |'
    echo '|    |/ |/ |/ |  / |/ |  | |/ \_|   |  / \_|'
    echo ' \__/   |  |  |_/  |  |_/|_/\_/  \_/|_/ \/ o'
    echo -e "$NC"
}
env_destroyed(){
    echo -e "$RD"
    echo ' ___                              __,'
    echo '(|  \  _  , _|_  ,_        o     /  |           __|_ |'
    echo ' |   ||/ / \_|  /  | |  |  |    |   |  /|/|/|  |/ |  |'
    echo '(\__/ |_/ \/ |_/   |/ \/|_/|/    \_/\_/ | | |_/|_/|_/o'
    echo -e "$NC"
}


echo -e "\nThis script should be executed from the s3-bucket-protection root directory.\n"
if [ -z "$1" ]
then
   echo "You must specify 'up' or 'down' to run this script"
   exit 1
fi
MODE=$(echo "$1" | tr [:upper:] [:lower:])
if [[ "$MODE" == "up" ]]
then
	read -sp "CrowdStrike API Client ID: " FID
	echo
	read -sp "CrowdStrike API Client SECRET: " FSECRET
	echo -e "\nThe following values are not required for the integration, only the demo."
	read -p "EC2 Instance Key Name: " ECKEY
	read -p "Trusted IP address: " TRUSTED
    UNIQUE=$(echo $RANDOM | md5sum | sed "s/[[:digit:].-]//g" | head -c 8)
    if ! [ -f terraform/terraform.tfstate ]; then
        terraform -chdir=terraform init
    fi
	terraform -chdir=terraform apply -compact-warnings --var falcon_client_id=$FID \
		--var falcon_client_secret=$FSECRET --var instance_key_name=$ECKEY \
		--var trusted_ip=$TRUSTED/32 --var unique_id=$UNIQUE --auto-approve
    echo -e "$RD\nPausing for 30 seconds to allow configuration to settle.$NC"
    sleep 30
    all_done
	exit 0
fi
if [[ "$MODE" == "down" ]]
then
	terraform -chdir=terraform destroy -compact-warnings --auto-approve
    rm lambda/quickscan-bucket.zip
    env_destroyed
	exit 0
fi
echo "Invalid command specified."
exit 1
