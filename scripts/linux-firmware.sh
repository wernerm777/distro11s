# Copyright © 2011 cozybit Inc.  All rights reserved.

#!/bin/bash

source `dirname $0`/common.sh

Q pushd ${DISTRO11S_SRC}/linux-firmware || exit 1
mkdir -p ${STAGING}/lib/firmware
do_stamp_cmd linux-firmware.install cp -R * ${STAGING}/lib/firmware 
