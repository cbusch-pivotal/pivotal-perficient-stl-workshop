#!/bin/bash
set -e
names=(
  ssahadevan@pivotal.io
  cbusch@pivotal.io
  chriscbusch@gmail.com
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

DEBUG=0
org=STLWorkshop
quota=student
pword="passw0rd"

echo "*** Creating student spaces and add student to space..."
for name in ${names[@]}
do
  space=${name%@*}

  #echo "*** Creating student$[$i]..."
  #doCmd "cf create-user $name $pword"

  echo "*** Creating space $space..."
  doCmd "cf create-space $space -o $org"
  doCmd "cf set-space-quota $space $quota"
  doCmd "cf set-space-role $name $org $space SpaceDeveloper"
done

