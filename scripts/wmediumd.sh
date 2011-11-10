# Copyright © 2011 cozybit Inc.  All rights reserved.

#!/bin/bash

source `dirname $0`/common.sh

Q pushd ${DISTRO11S_SRC}/wmediumd || exit 1
export CFLAGS="${CFLAGS} -D_GNU_SOURCE"
export LDFLAGS="-L ${STAGING}/usr/local/lib -L ${STAGING}/usr/lib"
export SUBDIRS="rawsocket wmediumd"
do_stamp_cmd wmediumd.make "make clean; make -j ${DISTRO11S_JOBS};"
do_stamp_cmd wmediumd.install cp ./wmediumd/wmediumd ${STAGING}/usr/local/bin
mkdir -p ${STAGING}/etc/wmediumd/
do_stamp_cmd wmediumd.install_etc cp ./wmediumd/cfg-examples/* ${STAGING}/etc/wmediumd/
