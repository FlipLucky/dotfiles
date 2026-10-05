-- Optional per-user keybind overrides (managed by DMS). Loaded after default binds.

-- Ctrl+Shift+R is the browser hard reload; move workspace rename onto SUPER
hl.unbind("CTRL + SHIFT + R")
hl.bind("SUPER + SHIFT + R", hl.dsp.exec_cmd("dms ipc call workspace-rename open"))
