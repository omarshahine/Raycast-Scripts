#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Track Package using Parcel
# @raycast.mode silent

# Optional parameters:
# @raycast.icon assets/track-parcel.png
# @raycast.argument1 { "type": "text", "placeholder": "package id"}
# @raycast.argument2 { "type": "text", "placeholder": "package description"}

# Documentation:
# @raycast.author Omar Shahine
# @raycast.authorURL https://omar.shahine.com

# Parcel Protocols
# parcel://automaticwithlabel/{var:label}/?{var:code}
# parcel://automatic/?{var:code}

code=$1
# remove leading whitespace characters
code="${code#"${code%%[![:space:]]*}"}"
# remove trailing whitespace characters
code="${code%"${code##*[![:space:]]}"}"   

open "parcel://automaticwithlabel/$2/?$code"

