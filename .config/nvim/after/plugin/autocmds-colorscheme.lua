-- This is simpler than making every plugin for which ColorScheme auto-commands
-- are set up depend on the color scheme.
vim.cmd.doautoall "ColorScheme"
