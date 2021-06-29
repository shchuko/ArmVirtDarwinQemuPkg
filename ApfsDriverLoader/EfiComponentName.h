/** @file

APFS Driver Loader - loads apfs.efi from EfiBootRecord block

Copyright (c) 2017-2018, savvas

All rights reserved.

This program and the accompanying materials
are licensed and made available under the terms and conditions of the BSD License
which accompanies this distribution.  The full text of the license may be found at
http://opensource.org/licenses/bsd-license.php

THE PROGRAM IS DISTRIBUTED UNDER THE BSD LICENSE ON AN "AS IS" BASIS,
WITHOUT WARRANTIES OR REPRESENTATIONS OF ANY KIND, EITHER EXPRESS OR IMPLIED.

**/
#ifndef EFI_COMPONENT_NAME_H_
#define EFI_COMPONENT_NAME_H_

#include <Library/UefiLib.h>
#include <Protocol/ComponentName.h>

//
// EFI Component Name Functions
//
EFI_STATUS
EFIAPI
ApfsDriverLoaderComponentNameGetDriverName (
  IN  EFI_COMPONENT_NAME_PROTOCOL  *This,
  IN  CHAR8                        *Language,
  OUT CHAR16                       **DriverName
  );

EFI_STATUS
EFIAPI
ApfsDriverLoaderComponentNameGetControllerName (
  IN  EFI_COMPONENT_NAME_PROTOCOL  *This,
  IN  EFI_HANDLE                   ControllerHandle,
  IN  EFI_HANDLE                   ChildHandle        OPTIONAL,
  IN  CHAR8                        *Language,
  OUT CHAR16                       **ControllerName
  );

extern EFI_COMPONENT_NAME_PROTOCOL   gApfsDriverLoaderComponentName;
extern EFI_COMPONENT_NAME2_PROTOCOL  gApfsDriverLoaderComponentName2;

#endif //EFI_COMPONENT_NAME_H_
