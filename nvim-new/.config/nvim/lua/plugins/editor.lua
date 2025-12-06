-- Editor Plugins
-- Plugins that enhance editing experience

return {
  -- Auto-detect tabstop and shiftwidth
  "tpope/vim-sleuth",

  -- Buffer management
  "kazhala/close-buffers.nvim",

  -- Commenting (gc to comment visual regions/lines)
  { "numToStr/Comment.nvim", opts = {} },

  -- NOTE: Removed nerdcommenter - it overlaps with Comment.nvim
  -- Comment.nvim is more modern and simpler

  -- Surround text objects
  "tpope/vim-surround",

  -- Auto-close brackets and quotes
  "jiangmiao/auto-pairs",
}
