-- Neovim Configuration
-- Modular setup - all configuration is split into separate files

-- Load core settings
require("config.settings")

-- Load keymaps
require("config.keymaps")

-- Load autocommands
require("config.autocommands")

-- Load plugin manager and plugins
require("config.lazy")
