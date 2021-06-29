#!/bin/bash
##
# edk2 build command wrapper
#
# Note: set '$EDK_DIR' to specify edk2 sources root
#       if not set, edk2 will be cloned using cloneEdk()
#
# Copyright (c) 2021, Vladislav Yaroshchuk <yaroshchuk2000@gmail.com>
# SPDX-License-Identifier: BSD-2-Clause-Patent
#
##
set -eo pipefail

cloneEdk() {
  EDK_REMOTE="https://github.com/tianocore/edk2.git"
  EDK_BRANCH="edk2-stable202105"
  EDK_DIR="$PWD/edk2"

  if [[ ! -d "$EDK_DIR" ]]; then
    git clone --filter=blob:none --single-branch --branch "$EDK_BRANCH" "$EDK_REMOTE" "$EDK_DIR"

    cd "$EDK_DIR"
    git submodule update --init
    make -C BaseTools
    cd - 1> /dev/null
  fi
}

setEnv() {
  if [[ -z ${EDK_DIR+x} ]]; then
    cloneEdk
  fi

  PKG_PATH="$PWD"
  PKG_NAME="ArmVirtDarwinQemuPkg"
  PKG_PLATFORM_FILE="ArmVirtDarwinQemu.dsc"
  PKG_BINDIR_PREFIX="ArmVirtDarwinQemu"

  FIRMWARE_CODE_BASENAME="QEMU_DARWIN_EFI.fd"
  FIRMWARE_VARS_BASENAME="QEMU_DARWIN_VARS.fd"

  BINARIES_DIR="$PKG_PATH/Binaries"
  CREATE_ZIP="False"

  PKG_LINK_PATH="$EDK_DIR/$PKG_NAME"
}

cleanup() {
  echo "Doing cleanup..."

  if [[ -d "$BINARIES_DIR" ]]; then
    cd "${BINARIES_DIR:?}"
    rm -rf -- *
    cd - 1> /dev/null
  fi
}

loadEnvDefaults() {
  ACTIVE_PLATFORM="$PKG_NAME/$PKG_PLATFORM_FILE"
  TARGET_ARCH="AARCH64"
  TARGET="DEBUG"
  TOOLCHAIN="GCC5"
}

printHelp() {
  echo -e "edk2 'build' tool wrapper"
  echo -e "usage: ./builduefi.sh [options] [build-args]"
  echo
  echo -e "options:"
  echo -e "\t-help\t\t\tPrint this help"
  echo -e "\t-buildRelease\t\tShortcut for '-b RELEASE'"
  echo -e "\t-createZip\t\tCreate zip archive with FVs"
  echo -e "\t-b TARGET\t\tCustom build target"
  echo -e "\t-t TOOLCHAIN\t\tCustom toolchain"
  echo
  echo -e "build-args: will be used as edk2 'build' args"
  echo

  loadEnvDefaults

  echo -e "defaults:"
  echo -e "\tACTIVE_PLATFORM=$ACTIVE_PLATFORM"
  echo -e "\tBUILDTARGET=$TARGET"
  echo -e "\tTOOLCHAIN=$TOOLCHAIN"
  echo -e "\tTARGET_ARCH=$TARGET_ARCH"
}

createLinks() {
  [[ ! -d $PKG_LINK_PATH ]] && ln -s "$PKG_PATH" "$PKG_LINK_PATH"

  cd "$EDK_DIR"

  [[ -d "$PKG_PATH/LegacyPackages" ]] &&
    while read -r LEGACY_PKG_PATH; do
      LEGACY_PKG_LINK="$(basename "$LEGACY_PKG_PATH")"
      [[ -d $LEGACY_PKG_LINK ]] || ln -s "$LEGACY_PKG_PATH" "$LEGACY_PKG_LINK"
    done < <(find "$PKG_PATH/LegacyPackages" -maxdepth 1 -type d)

  cd "$PKG_PATH"

  if [[ ! -d "$BINARIES_DIR" ]]; then
    mkdir -p "$BINARIES_DIR"
  fi
}

updEnv() {
  if [[ -n $CUSTOM_TARGET ]]; then
    TARGET="$CUSTOM_TARGET"
  fi

  if [[ -n $CUSTOM_TOOLCHAIN ]]; then
    TOOLCHAIN="$CUSTOM_TOOLCHAIN"
  fi

  FIRMWARE_SRC_DIR="$EDK_DIR/Build/${PKG_BINDIR_PREFIX}-${TARGET_ARCH}/${TARGET}_${TOOLCHAIN}/FV/"
  FIRMWARE_CODE_SRC="$FIRMWARE_SRC_DIR/$FIRMWARE_CODE_BASENAME"
  FIRMWARE_VARS_SRC="$FIRMWARE_SRC_DIR/$FIRMWARE_VARS_BASENAME"
}

packBinaries() {
  cp "$FIRMWARE_CODE_SRC" "$BINARIES_DIR/$FIRMWARE_CODE_BASENAME"
  cp "$FIRMWARE_VARS_SRC" "$BINARIES_DIR/$FIRMWARE_VARS_BASENAME"

  echo "$PKG_NAME:
  TARGET: $TARGET
  ARCH: $TARGET_ARCH
  TOOLCHAIN: $TOOLCHAIN" >"$BINARIES_DIR/FV_INFO.yaml"

  if [[ "$CREATE_ZIP" == "True" ]]; then
    echo "Creating zip archive..."
    cd "$BINARIES_DIR"
    zip -qr "$BINARIES_DIR/${PKG_BINDIR_PREFIX}Bin.zip" ./*
    cd "$PKG_PATH"
    echo "- Done -"
  fi
}

runBuild() {
  cd "$EDK_DIR"

  CMD="build -a $TARGET_ARCH -t $TOOLCHAIN -p $ACTIVE_PLATFORM -b $TARGET $BUILD_COMMAND_ARGS"
  echo "exec: $CMD"

  source edksetup.sh
  eval "$CMD"
  EXIT_STATUS=$?

  cd "$PKG_PATH"

  return $EXIT_STATUS
}

readArgs() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
    -b)
      CUSTOM_TARGET="$2"
      shift
      ;;

    -t)
      CUSTOM_TOOLCHAIN="$2"
      shift
      ;;

    -buildRelease)
      CUSTOM_TARGET="RELEASE"
      ;;

    -help)
      printHelp
      exit $?
      ;;

    -createZip)
      CREATE_ZIP="True"
      ;;

    *)
      BUILD_COMMAND_ARGS="$BUILD_COMMAND_ARGS$*"
      break
      ;;
    esac
    shift
  done
}

setEnv
readArgs "$@"
cleanup
loadEnvDefaults
updEnv
createLinks

if runBuild; then
  packBinaries
else
  echo "Build errored!"
  exit 1
fi
