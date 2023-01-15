#!/bin/bash

CUR_DIR=$PWD
SCRIPT_DIR=${CM_TMP_CURRENT_SCRIPT_PATH}

echo "******************************************************"
echo "Cloning Mlcommons from ${CM_GIT_URL} with branch ${CM_GIT_CHECKOUT} ${CM_GIT_DEPTH} ${CM_GIT_RECURSE_SUBMODULES}..."

if [ ! -d "training" ]; then
  if [ -z ${CM_GIT_SHA} ]; then
    git clone ${CM_GIT_RECURSE_SUBMODULES} -b "${CM_GIT_CHECKOUT}" ${CM_GIT_URL} ${CM_GIT_DEPTH} training
    cd training
  else
    git clone ${CM_GIT_RECURSE_SUBMODULES} ${CM_GIT_URL} ${CM_GIT_DEPTH} training
    cd training
    git checkout -b "${CM_GIT_CHECKOUT}"
  fi
  if [ "${?}" != "0" ]; then exit 1; fi
else
  cd training
fi

if [ ${CM_GIT_PATCH} == "yes" ]; then
  patch_filename=${CM_GIT_PATCH_FILENAME}
  if [ ! -n ${CM_GIT_PATCH_FILENAMES} ]; then
    patchfile=${CM_GIT_PATCH_FILENAME:-"git.patch"}
    CM_GIT_PATCH_FILENAMES=$patchfile
  fi
  IFS=', ' read -r -a patch_files <<< ${CM_GIT_PATCH_FILENAMES}
  for patch_filename in "${patch_files[@]}"
  do
    echo "Applying patch ${SCRIPT_DIR}/patch/$patch_filename"
    git apply ${SCRIPT_DIR}/patch/"$patch_filename"
    if [ "${?}" != "0" ]; then exit 1; fi
  done
fi
cd "$CUR_DIR"