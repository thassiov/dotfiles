-- UI Plugins
-- Theme, statusline, and visual enhancements

return {
  -- Color scheme
  {
    "Shatur/neovim-ayu",
    lazy = false,
    priority = 1000,
    config = function()
      require("ayu").setup({
        overrides = {
          Normal = { bg = "#05070A" },
        },
      })
      require("ayu").colorscheme()

      -- Custom highlights
      vim.cmd.highlight("CursorLine gui=bold")
      vim.cmd.highlight("LineNr guifg=grey")
      vim.cmd.hi("Visual guibg=#404040")
    end,
  },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "iceberg_dark",
          component_separators = { left = "|", right = "|" },
          section_separators = { left = "░", right = "░" },
        },
        tabline = {
          lualine_a = { "buffers" },
          lualine_b = {},
          lualine_c = {},
          lualine_x = {},
          lualine_y = {},
          lualine_z = { "tabs" },
        },
      })
    end,
  },

  -- Zen mode
  {
    "folke/zen-mode.nvim",
    keys = {
      { "<leader>z", "<cmd>ZenMode<cr>", desc = "Toggle zen mode" },
    },
  },

  -- Highlight TODO comments
  {
    "folke/todo-comments.nvim",
    event = "VimEnter",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = { signs = false },
  },

  -- Mini.nvim modules
  {
    "echasnovski/mini.nvim",
    config = function()
      -- Better Around/Inside textobjects
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [']quote
      --  - ci'  - [C]hange [I]nside [']quote
      require("mini.ai").setup({ n_lines = 500 })

      -- NOTE: mini.statusline and mini.tabline are disabled since we use lualine
      -- NOTE: mini.pairs is disabled since we use auto-pairs
      -- NOTE: mini.surround is disabled since we use vim-surround
    end,
  },
}
