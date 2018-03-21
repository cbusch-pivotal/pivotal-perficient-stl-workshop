#!/usr/bin/env bash

set -e -x

# login
fly -t ccb login -c http://192.168.100.4:8080

# create the pipeline
fly -t ccb set-pipeline --pipeline attendees-demo --config pipeline.yml --load-vars-from ~/.concourse/ci-props.yml

# unpause so it can run
fly -t ccb unpause-pipeline --pipeline attendees-demo

