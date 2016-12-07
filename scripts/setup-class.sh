#!/usr/bin/env bash
# 
# This script requires bash 4! Upgrade!
#
# This script takes in a list of emails (newline seperated) and builds out cf orgs and users. 
# It is assumed that the email takes the form of first_last or first.last. We will create an 
# org named fl-org where f is the first initial and l is the last initial. If we encounter 
# 1 duplcate we will append 1 to the org name. If we encounter two duplicates your in trouble
# this script creates org_summary.txt which is helpful for orienting students about where they 
# should go. 
#
# Before running this script make to set the default behavior of the foundation to be all_closed
# in terms of security groups

#cf create-security-group development-security-group ./development-security-group.json

declare -A orgs

simulate=0
create_prod=0
summary_file=org_summary.txt
email_file=class-participant-emails.txt

function show_help {
	cat <<EOD
Usage: setup-class [OPTION..]

  -h, -?   Show usage
  -s       Simulate setting up the class, but don't create anything
  -p       Create a production space for users and apply a "deny all" ASG to the development space
  -o FILE  Set the file for the output summary.  Default is "org_summary.txt"
  -e FILE  The file to read for email addresses.  Default is "class-participant-emails.txt

EOD
}

while getopts "h?spoe" opt; do
  case "$opt" in
	h|\?)
		show_help
      		exit 0
		;;
	s) simulate=1
	   ;;
	p) create_prod=1
     	   ;;
	o) summary_file=$OPTARG
	   ;;
        e) email_file=$OPTARG
           ;;
  esac
done  

cat > $summary_file <<EOD
|===============================================
|User Name                    |Password |Org
EOD

for email in `cat $email_file` ; do
  org=`echo $email | tr '_.' "\n" | egrep -v com | colrm 2 | tr -d "\n" && echo -org`
  
  if [[ ${orgs[$org]} -eq 1 ]]; then 
  org=$org"1"
  fi
  orgs[$org]=1
  
  echo "INFO: Setting up $org: for $email"

  if [ "$simulate" -eq "0" ]
  then
    cf create-org $org
    cf create-space development -o $org
    if [ "$create_prod" -eq "1" ]; then cf create-space production -o $org; fi
  
    cf create-user $email password
    cf set-org-role admin $org OrgManager
    cf set-org-role $email $org OrgManager
    cf set-space-role $email $org development SpaceManager
    cf set-space-role $email $org development SpaceDeveloper
    if [ "$create_prod" -eq "1" ]; then cf set-space-role $email $org production SpaceManager; fi
    if [ "$create_prod" -eq "1" ]; then cf set-space-role $email $org production SpaceDeveloper; fi
    if [ "$create_prod" -eq "1" ]; then cf bind-security-group all_open $org production; fi
  fi
  echo "|$email |password |$org" >> $summary_file
done

echo "|===============================================" >> $summary_file
