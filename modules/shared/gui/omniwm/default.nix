_: {
  xdg.configFile."omniwm/settings.toml" = {
    force = true;
    text = ''
      # OmniWM canonical settings.
      # Deployed to: ''${XDG_CONFIG_HOME:-$HOME/.config}/omniwm/settings.toml
      #
      # Keep runtime state out of this file. OmniWM stores state under:
      # ''${XDG_STATE_HOME:-$HOME/.local/state}/omniwm

      hotkeys = []
      monitorBarOverrides = []
      monitorOrientationOverrides = []
      monitorNiriOverrides = []
      monitorDwindleOverrides = []

      [general]
      hotkeysEnabled = true
      hyperTrigger = "Option"
      hyperKeyHoldThresholdMilliseconds = 150
      defaultLayoutType = "niri"
      preventSleepEnabled = false
      updateChecksEnabled = true
      ipcEnabled = false
      animationsEnabled = true

      [focus]
      followsMouse = false
      moveMouseToFocusedWindow = false
      followsWindowToMonitor = false

      [mouseWarp]
      monitorOrder = []
      axis = "horizontal"
      margin = 1

      [gaps]
      size = 16.0

      [gaps.outer]
      left = 0.0
      right = 0.0
      top = 0.0
      bottom = 0.0

      [niri]
      maxVisibleColumns = 2
      infiniteLoop = false
      centerFocusedColumn = "never"
      alwaysCenterSingleColumn = false
      singleWindowAspectRatio = "none"
      columnWidthPresets = [0.3333333333333333, 0.5, 0.6666666666666666]
      defaultColumnWidth = 0.5

      [dwindle]
      smartSplit = false
      defaultSplitRatio = 1.0
      splitWidthMultiplier = 1.0
      singleWindowAspectRatio = "4:3"
      useGlobalGaps = true
      moveToRootStable = true

      [borders]
      enabled = true
      width = 5.0

      [borders.color]
      red = 0.08458520228437894
      green = 1.0
      blue = 0.979300037944676
      alpha = 1.0

      [workspaceBar]
      enabled = true
      showLabels = true
      showFloatingWindows = false
      windowLevel = "popup"
      position = "overlappingMenuBar"
      notchAware = true
      deduplicateAppIcons = false
      hideEmptyWorkspaces = false
      reserveLayoutSpace = false
      height = 24.0
      backgroundOpacity = 0.1
      xOffset = 0.0
      yOffset = 0.0
      labelFontSize = 12.0

      [gestures]
      scrollEnabled = true
      scrollSensitivity = 5.0
      scrollModifierKey = "optionShift"
      mouseResizeModifierKey = "option"
      fingerCount = 3
      invertDirection = true

      [statusBar]
      showWorkspaceName = false
      showAppNames = false
      useWorkspaceId = false

      [clipboard]
      historyEnabled = false
      maxItems = 200
      maxItemBytes = 8388608
      maxTotalBytes = 67108864

      [quakeTerminal]
      enabled = true
      position = "center"
      widthPercent = 50.0
      heightPercent = 50.0
      animationDuration = 0.2
      autoHide = false
      opacity = 1.0
      monitorMode = "focusedWindow"

      [appearance]
      mode = "dark"

      [[workspaces]]
      id = "AD36F001-C57E-41A5-AC1D-DF5249D007F0"
      name = "1"
      layoutType = "niri"
      [workspaces.monitorAssignment]
      type = "main"

      [[workspaces]]
      id = "454CECD4-5E9D-4ED1-95D7-979D48817F5F"
      name = "2"
      layoutType = "niri"
      [workspaces.monitorAssignment]
      type = "main"

      [[workspaces]]
      id = "BEB842B5-E894-4791-9FD1-397C34DC3E38"
      name = "3"
      layoutType = "niri"
      [workspaces.monitorAssignment]
      type = "main"

      [[workspaces]]
      id = "248AA883-2261-4D45-943C-79C0E46A232B"
      name = "4"
      layoutType = "niri"
      [workspaces.monitorAssignment]
      type = "main"

      [[workspaces]]
      id = "8B8C45D6-CE9E-41D9-BD50-BE4989D5E3DE"
      name = "5"
      layoutType = "niri"
      [workspaces.monitorAssignment]
      type = "main"

      [[workspaces]]
      id = "5953F2BF-A378-4266-91B2-287174C4FA4D"
      name = "6"
      displayName = "D"
      layoutType = "niri"
      [workspaces.monitorAssignment]
      type = "secondary"

      [[workspaces]]
      id = "A7D5E104-6985-4516-8ED5-07F144F2A33D"
      name = "7"
      displayName = "B"
      layoutType = "niri"
      [workspaces.monitorAssignment]
      type = "secondary"

      [[appRules]]
      bundleId = "com.github.wez.wezterm"
      layout = "tile"

      [[appRules]]
      bundleId = "company.thebrowser.Browser"
      layout = "tile"

      [[appRules]]
      bundleId = "app.zen-browser.zen"
      layout = "tile"
    '';
  };
}
