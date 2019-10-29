#!/bin/bash

MIRROR_REGISTRY=`oc get ImageContentSourcePolicy  image-policy-0 -o yaml | grep ocp/release | awk '{print $2}' |awk -F"/" '{print $1}'`
echo "Mirror test images"
working_dir=$(pwd)
input="$working_dir/imagelist"
while IFS= read -r line
do
  namespace=`echo "$line"| awk -F"/" '{print $2}'`
  imagename=`echo "$line"| awk -F"/" '{print $3}'`
  oc image mirror -a #{File.expand_path('~/mirror_pullsecret_config.json') $line $MIRROR_REGISTRY/$namespace/$imagename
  if [ $? -ne 0 ]; then
    echo -e "Image mirrors failed, please try it again.\n"
  fi
done < "$input"

echo "Mirror images for jenkins images.... "
VERSION=`oc get clusterversion | grep "version" | awk '{print $2}'`
listjenkins=`oc adm release info --pullspecs registry.svc.ci.openshift.org/ocp/release:$VERSION | grep  jenkins| awk -F"/" '{print $3}'`
for item in ${listjenkins[@]}
do
  oc image mirror -a #{File.expand_path('~/mirror_pullsecret_config.json') quay.io/openshift-release-dev/$item ${MIRROR_REGISTRY}/openshift-release-dev/ocp-v4.0-art-dev
  if [ $? -ne 0 ]; then
    echo -e "Image mirrors failed, please try it again.\n"
  fi
done
