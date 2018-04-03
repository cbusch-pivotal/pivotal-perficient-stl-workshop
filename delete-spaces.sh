#!/bin/bash
set -e

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

spaces=$(cf spaces | sed 1,3d)
echo $spaces

for space in ${spaces[@]}
do
  echo "***Deleting space..."
  doCmd "cf delete-space -f $space"
done

