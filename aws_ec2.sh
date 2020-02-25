#!/bin/bash
# command aws_ec2.sh
aws ec2 describe-instances --query 'Reservations[].Instances[].[Tags[?Key==`Name`] | [0].Value, Placement.AvailabilityZone,State.Name, PrivateIpAddress, PublicIpAddress ]' --output table
