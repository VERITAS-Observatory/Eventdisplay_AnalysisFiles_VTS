#!/bin/bash
# upload IRFs to UCLA using rsync (slower than bbftp!)
# - uploading in tar packages
# - one tar package per directory


USER="${VTS_UCLA_USER}"
echo "USER: $USER"
# Eventdisplay version
VERSION=$(cat ../IRFMINORVERSION)
cd ../tar_packages_${VERSION}

rsync -avz -e ssh \
    ./*.tar \
    ${USER}:/home/maierg/EVNDISP/tmp_${VERSION}/
