#!/bin/bash

echo "Mirror test images"
input="$working_dir/imagelist"
while IFS= read -r line
do
  namespace=`echo "$line"| awk -F"/" '{print $2}'`
  imagename=`echo "$line"| awk -F"/" '{print $3}'`
  oc image mirror $line $MIRROR_REGISTRY/$namespace/$imagename
  if [ $? -ne 0 ]; then
    echo TIMESTAMP=$(date +"%Y-%m-%d-%H-%M-%S")  >> $RESULT_FILE
    echo -e "${item} image mirrors failed, please try it again.\n#oc image mirror registry.redhat.io/rhscl/${item} ${MIRROR_REGISTRY}/rhscl/${item}" >> $RESULT_FILE
done < "$input"

echo "Mirror images for jenkins module.... "
version=`oc get clusterversion | grep "version" | awk '{print $2}'`
listjenkins=`oc adm release info --pullspecs registry.svc.ci.openshift.org/ocp/release:$VERSION | grep  jenkins| awk -F"/" '{print $3}'`
for item in ${listjenkins[@]}
do
  oc image mirror quay.io/openshift-release-dev/$item ${MIRROR_REGISTRY}/openshift-release-dev/ocp-v4.0-art-dev
  if [ $? -ne 0 ]; then
    echo TIMESTAMP=$(date +"%Y-%m-%d-%H-%M-%S")  >> $RESULT_FILE
    echo -e "${item} image mirrors failed, please try it again.\n#oc image mirror quay.io/openshift-release-dev/$item ${MIRROR_REGISTRY}/openshift-release-dev/ocp-v4.0-art-dev" >>$RESULT_FILE
  fi
done
