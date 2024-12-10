#!/usr/bin/env bash
# .github/actions/scripts/checkpatch.sh
#
# SPDX-License-Identifier: Apache-2.0
#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to you under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

TOOLDIR=$(dirname $0)

fail=0
message=0

usage() {
  echo "USAGE: ${0} [options] [list|-]"
  echo ""
  echo "Options:"
  echo "-h"
  echo "-m Change-Id check in commit message (coupled with -g)"
  echo "-g <commit list>"
  echo "   git diff --cached | ./tools/checkpatch.sh -"
  echo "Where a <commit list> is any syntax supported by git for specifying git revision, see GITREVISIONS(7)"

  exit $@
}

check_msg() {
  while read; do
    if [[ $REPLY =~  ^Change-Id ]]; then
      echo "Remove Gerrit Change-ID's before submitting upstream"
      fail=1
    fi
  done
}

check_commit() {
  if [ $message != 0 ]; then
    msg=`git show -s --format=%B $1`
    check_msg <<< "$msg"
  fi
}

if [ -z "$1" ]; then
  usage
  exit 0
fi

while [ ! -z "$1" ]; do
  case "$1" in
  -m )
    message=1
    ;;
  -g )
    check=check_commit
    ;;
  -h )
    usage 0
    ;;
  -* )
    usage 1
    ;;
  * )
    break
    ;;
  esac
  shift
done

for arg in $@; do
  $check $arg
done

exit $fail
