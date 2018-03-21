#!/bin/bash

set -e

echo "Finalizing production deployment..."

# required
versionFile=  artifactId= 

# optional
hostname=$CF_HOST # default to env variable from pipeline

while [ $# -gt 0 ]; do
  case $1 in
    -v | --version-file )
      versionFile=$2
      shift
      ;;
    -a | --artifactId )
      artifactId=$2
      shift
      ;;
    * )
      echo "Unrecognized option: $1" 1>&2
      exit 1
      ;;
  esac
  shift
done

error_and_exit() {
  echo $1 >&2
  exit 1
}

if [ ! -f "$versionFile" ]; then
  error_and_exit "missing version file: $versionFile"
fi
if [ -z "$artifactId" ]; then
  error_and_exit "missing artifactId!"
fi

# copy the war file to the output directory
version=`cat $versionFile`

# actual app name of new app
appName="${artifactId}-${version//\./-}"

# route name -- could use different name than the app name (artifactId)
#routeName="${hostname}-${version//\./-}"

# get latest CF CLI
curl -L "https://cli.run.pivotal.io/stable?release=linux64-binary&source=github" | tar -zx
./cf --version

./cf login -a ${CF_API_ENDPOINT} -u ${CF_USER} -p ${CF_PWD} -o ${CF_ORG} -s ${CF_SPACE} --skip-ssl-validation

# list the app names which are deployed using the base app name
DEPLOYED_APPS=$(./cf apps | grep ${artifactId} | cut -d" " -f1)
echo "Deployed apps: ${DEPLOYED_APPS}"

# Map app version onto main app route and scale the app to support traffic
# cf map-route attendees-0-0-5 cfapps.io -n attendees
echo "map ${appName} to route ${hostname}.${CF_DOMAIN}"
./cf map-route $appName $CF_DOMAIN -n $hostname

# remove versioned route name
./cf unmap-route $appName $CF_DOMAIN -n $appName

# cf scale attendees-0-0-5 -i 2
echo "scaling ${appName} up..."
./cf scale $appName -i 2

# Scale down, unmap routes, and remove old versions of app, except a basename app = attendees
if [ ! -z "$DEPLOYED_APPS" -a "$DEPLOYED_APPS" != " " -a "$DEPLOYED_APPS" != "$appName" ]; then
  echo "Performing zero-downtime cutover to $appName"

  while read -r line 
  do
    # if the currently deployed apps are not the new app or an app with the base app name
    if [ ! -z "$line" -a "$line" != " " -a "$line" != "$appName" -a "$line" != "$artifactId" ]; then 
      echo "Scaling down, unmapping and removing app: $line"
      ./cf scale "$line" -i 1
      #./cf unmap-route "$line" $CF_DOMAIN -n $hostname
      ./cf delete "$line" -f 
    else
      echo "Skipping $line" 
    fi
  done <<<"$DEPLOYED_APPS" 
fi

# clear up unused routes
./cf delete-orphaned-routes -f

