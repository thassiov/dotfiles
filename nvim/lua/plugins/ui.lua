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
        mirage = false,
        -- overrides intentionally omitted so we get dark's actual palette
      })
      vim.cmd.colorscheme("ayu-dark")

      -- Custom highlights (kept from before; drop if you want the theme's defaults)
      vim.cmd.highlight("CursorLine gui=bold")
      vim.cmd.highlight("LineNr guifg=grey")
      vim.cmd.hi("Visual guibg=#404040")

      -- Rounded border on all floating windows (LSP hover docs, signature, etc.).
      vim.o.winborder = "rounded"

      -- Floats (LSP hover docs) share Normal's bg in ayu, so they vanish into the
      -- editor. Lighten NormalFloat a touch and give the border a visible colour.
      local function lighten(hex, amt)
        local r, g, b = tonumber(hex:sub(2, 3), 16), tonumber(hex:sub(4, 5), 16), tonumber(hex:sub(6, 7), 16)
        local function up(c)
          return math.min(255, math.floor(c + (255 - c) * amt))
        end
        return string.format("#%02x%02x%02x", up(r), up(g), up(b))
      end

      local function style_floats()
        local normal = vim.api.nvim_get_hl(0, { name = "Normal" })
        local base = normal.bg and string.format("#%06x", normal.bg) or "#0b0e14"
        -- Just a touch lighter than the editor bg, not a hard contrast.
        local float_bg = lighten(base, 0.06)
        vim.api.nvim_set_hl(0, "NormalFloat", { bg = float_bg })
        -- Orange border (ayu's `import`/keyword colour) on the lighter bg.
        vim.api.nvim_set_hl(0, "FloatBorder", { bg = float_bg, fg = "#ff8f40" })
      end

      style_floats()
      vim.api.nvim_create_autocmd("ColorScheme", { callback = style_floats })

      -- LSP hover / signature floats: rounded border + breathing room so the
      -- text never tucks under the border (the "swallowed letters" problem) and
      -- the right edge isn't flush against the line.
      local orig_open = vim.lsp.util.open_floating_preview
      function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
        opts = opts or {}
        opts.border = opts.border or "rounded"
        opts.max_width = opts.max_width or 80
        opts.max_height = opts.max_height or 25
        opts.wrap = opts.wrap ~= false
        local bufnr, winnr = orig_open(contents, syntax, opts, ...)
        if winnr and vim.api.nvim_win_is_valid(winnr) then
          -- Left pad via foldcolumn, right pad by widening past the wrapped text.
          vim.wo[winnr].foldcolumn = "1"
          local w = vim.api.nvim_win_get_width(winnr)
          pcall(vim.api.nvim_win_set_width, winnr, w + 2)
        end
        return bufnr, winnr
      end
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
    "nvim-mini/mini.nvim",
    config = function()
      -- Better Around/Inside textobjects
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [']quote
      --  - ci'  - [C]hange [I]nside [']quote
      require("mini.ai").setup({ n_lines = 500 })

      -- Auto-close brackets and quotes (replaces jiangmiao/auto-pairs)
      require("mini.pairs").setup({})

      -- mini.statusline / mini.tabline disabled in favor of lualine
      -- mini.surround disabled in favor of vim-surround
    end,
  },
}
