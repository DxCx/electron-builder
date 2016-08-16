!ifndef INSTALL_MODE_PER_ALL_USERS
  Function un.installMode.CurrentUser
    !insertmacro setInstallModePerUser
  FunctionEnd
!endif

!ifdef INSTALL_MODE_PER_ALL_USERS_REQUIRED
  Function un.installMode.AllUsers
    !insertmacro setInstallModePerAllUsers
  FunctionEnd
!endif

Function un.onInit
  !insertmacro check64BitAndSetRegView

  ${IfNot} ${Silent}
    MessageBox MB_OKCANCEL "Are you sure you want to uninstall ${PRODUCT_NAME}?" IDOK +2
    Quit

    !ifdef ONE_CLICK
      # one-click installer executes uninstall section in the silent mode, but we must show message dialog if silent mode was not explicitly set by user (using /S flag)
      !insertmacro CHECK_APP_RUNNING "uninstall"
      SetSilent silent
    !endif
  ${EndIf}

  !insertmacro initMultiUser un.

  !ifmacrodef customUnInit
    !insertmacro customUnInit
  !endif
FunctionEnd

Section "un.install"
  SetAutoClose true

  !ifndef ONE_CLICK
    # for boring installer we check it here to show progress
    !insertmacro CHECK_APP_RUNNING "uninstall"
  !endif

  StrCpy $startMenuLink "$SMPROGRAMS\${PRODUCT_FILENAME}.lnk"
  StrCpy $desktopLink "$DESKTOP\${PRODUCT_FILENAME}.lnk"

  WinShell::UninstAppUserModelId "${APP_ID}"
  WinShell::UninstShortcut "$startMenuLink"
  WinShell::UninstShortcut "$desktopLink"

  Delete "$startMenuLink"
  Delete "$desktopLink"

  !ifmacrodef unregisterFileAssociations
    !insertmacro unregisterFileAssociations
  !endif

  # delete the installed files
  RMDir /r $INSTDIR

  ${GetParameters} $R0
  ${GetOptions} $R0 "/KEEP_APP_DATA" $R1
  ${If} ${Errors}
    RMDir /r "$APPDATA\${PRODUCT_FILENAME}"
  ${EndIf}

  DeleteRegKey SHCTX "${UNINSTALL_REGISTRY_KEY}"
  DeleteRegKey SHCTX "${INSTALL_REGISTRY_KEY}"

  !ifmacrodef customUnInstall
    !insertmacro customUnInstall
  !endif
SectionEnd