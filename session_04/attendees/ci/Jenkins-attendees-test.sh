#!/bin/bash
set -e -x

echo "Build number is: ${BUILD_NUMBER}"

hostname=attendees
appBase=${hostname}-v
appName=${appBase}${BUILD_NUMBER}
verHostname=${appName}
testRoute=${hostname}-test
cfDomain=pcf1.fe.gopivotal.com

# find all existing apps starting with "attendees-v"
deployedApps=$(cf apps | grep ${appBase} | cut -d" " -f1)
#echo "Deployed app(s): $deployedApps"

# push the new (green) version to PCF
targetJar=target/${hostname}-${BUILD_NUMBER}.jar
#cf push $appName -n $verHostname -p $targetJar
cf push $appName -n $verHostname -m 1G -i 1 -p $targetJar --no-manifest

# Smoke test before adding new green app to main app route
echo "Do some smoke testing...."

#*** Script should exit(!0) before this point, if a failure occurred ***

# Map app version onto main app route and scale the app to support traffic
# i.e. $ cf map-route attendees-v5 cfapps.io -n attendees
echo "map ${appName} to route ${hostname}.${cfDomain}"
cf map-route $appName $cfDomain -n $testRoute

# remove new version route
cf unmap-route $appName $cfDomain -n $verHostname

# cf scale attendees-v5 -i 2
echo "scaling ${appName} up..."
cf scale $appName -i 5

# Scale down, unmap routes, and remove old versions of app, except a basename app = attendees
if [ ! -z "$deployedApps" -a "$deployedApps" != " " -a "$deployedApps" != "$appName" ]; then
  echo "Performing zero-downtime cutover to $hostname"

  while read -r line 
  do
    if [ ! -z "$line" -a "$line" != " " -a "$line" != "$appName" -a "$line" != "$hostname" ]; then 
      echo "Scaling down, unmapping and removing app: $line"
      cf scale "$line" -i 1
      cf unmap-route "$line" $cfDomain -n $testRoute
      cf delete "$line" -f 
    else
      echo "Skipping $line" 
    fi
  done <<<"$deployedApps" 
fi

# clean up any unused routes to avoid conflicts in the future
cf delete-orphaned-routes -f

