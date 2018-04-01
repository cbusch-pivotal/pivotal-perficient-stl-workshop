#!/bin/bash
set -e
names=(
  ssahadevan@pivotal.io
  cbusch@pivotal.io
  swomack@pivotal.io
)

# DEBUG=1 echoes the command, otherwise run the command
function doCmd()
{
  if [ $DEBUG -eq 1 ]
  then
    echo "DEBUG: $1"
  else
    # actually run the command!
    $1
  fi
}

DEBUG=1
org=STLWorkshop
quota=student
pword="passw0rd"

echo "*** Creating student accounts and spaces..."
for name in ${names[@]}
do
  space=${name%@*}
  echo "Creating user $name and space $space..."

  echo "*** Creating student$[$i]..."
  doCmd "cf create-user $name $pword"

  echo "*** Creating space $space..."
  doCmd "cf create-space $space -o $org"
  doCmd "cf set-space-quota $space $quota"
  doCmd "cf set-space-role $name $org $space SpaceDeveloper"
done

