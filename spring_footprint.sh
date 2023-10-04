#!/bin/bash
#

set -e

mkdir appbits;
cf curl /v2/apps > ./allapps.json;
echo "App Name, Buildpack, Org Name, Space Name, Compiled Class Version, Spring Boot Version\n" > output.csv;
for k in $(jq '.resources | keys | .[]' allapps.json); do
  value=$(jq -r ".resources[$k]" allapps.json);
  name=$(jq -r '.entity.name' <<< "$value");
  appguid=$(jq -r '.metadata.guid' <<< "$value");
  buildpack=$(jq -r '.entity.buildpack' <<< "$value");
  spaceguid=$(jq -r '.entity.space_guid' <<< "$value");
  spacename=$(cf curl /v2/spaces/$spaceguid | jq -r '.entity.name');
  orgguid=$(cf curl /v2/spaces/$spaceguid | jq -r '.entity.organization_guid');
  orgname=$(cf curl /v2/organizations/$orgguid/summary | jq -r '.name');
  echo -n $name >> output.csv;
  echo -n "," >> output.csv;
  echo $appguid;
  echo -n $buildpack >> output.csv;
  echo -n "," >> output.csv;
  echo -n $orgname >> output.csv;
  echo -n "," >> output.csv;
  echo -n $spacename >> output.csv;
  echo -n "," >> output.csv;
  if [[ $buildpack == *"java"* ]]; 
  then
    echo "Java Buildpack, figuring out the bits"
    cf curl /v2/apps/$appguid/download > ./appbits/appbits.jar;
    unzip -q -d ./appbits ./appbits/appbits.jar ;
    javaversionstring=$(file $(find ./appbits/BOOT-INF/classes -name "*.class" | head -1 ) | awk -F ':' '{print $2}' | awk -F ',' '{print $2}');
    echo -n $javaversionstring >> output.csv;
    echo -n "," >> output.csv;
    springbootversion=$(syft -q ./appbits/appbits.jar | grep "spring-boot " | head -1 | awk '{print $2}');
    echo -n $springbootversion >> output.csv;
    rm -rf ./appbits;
    mkdir appbits;
  fi
  echo "" >> output.csv;
done
echo "" >> output.csv;
rm -rf ./appbits;
rm -rf allapps.json;


