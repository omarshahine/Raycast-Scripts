#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Expand URL
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🌐
# @raycast.argument1 { "type": "text", "placeholder": "Enter short URL" }

# Documentation:
# @raycast.description Expand URL
# @raycast.author Omar Shahine
# @raycast.authorURL https://omar.shahine.com

# Example Short URL http://bit.ly/apple
# Example Safe Link URL https://nam06.safelinks.protection.outlook.com/?url=https%3A%2F%2Ftechcommunity.microsoft.com%2Ft5%2Fmicrosoft-sharepoint-blog%2Ftech-therapy-with-sue-hanley-the-intrazone-podcast%2Fba-p%2F3508287&data=05%7C01%7COmar.Shahine%40microsoft.com%7C83bdf1fbf07846b5397c08da5aff94de%7C72f988bf86f141af91ab2d7cd011db47%7C0%7C0%7C637922351030051170%7CUnknown%7CTWFpbGZsb3d8eyJWIjoiMC4wLjAwMDAiLCJQIjoiV2luMzIiLCJBTiI6Ik1haWwiLCJXVCI6Mn0%3D%7C3000%7C%7C%7C&sdata=x03c%2FDcVVk%2FSgPtv7YQSKoJGLCcTUlGEv5kpji9kqtw%3D&reserved=0

#line=$(curl -sLI "$1" | grep -i Location | head -1)
line=$(curl -X GET -sLI "$1" | grep -i Location | head -1)
url=${line#*' '}
#url=${line:10}  

echo $url

if test -z "$url" 
then
      echo $1 | pbcopy
else
      echo $url | pbcopy
fi