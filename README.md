# ArmVirtDarwinQemuPkg

An experimental ArmVirtPkg fork patched to virtualize macOS over QEMU. Based on ArmVirtPkg
from [edk2](https://github.com/tianocore/edk2)
version [`edk2-stable202105`](https://github.com/tianocore/edk2/tree/edk2-stable202105). Patches are ported
from [OvmfDarwinPkg](https://github.com/shchuko/OvmfDarwinPkg).

**Not tested yet!**

# Build notes

Has requirements equal to ArmVirtPkg does. Don't forget to install cross-compiler if use x86_64 host. Repo contains
the [`builduefi.sh`](builduefi.sh) wrapper which downloads required edk2 version and starts UEFI build.

To simplify building under
macOS, [Docker build environment](https://github.com/shchuko/edk2-env-docker/tree/edk2-stable202105) was created. Just
run [`dockerbuild.sh`](dockerbuild.sh) instead of [`builduefi.sh`](builduefi.sh), the options are the same.

