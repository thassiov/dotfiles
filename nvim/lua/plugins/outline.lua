-- Symbol outline / TOC sidebar
-- Renders the current buffer's symbols (treesitter or LSP) in a left sidebar.
-- For markdown: headings become the TOC. For code: functions/classes/etc.

return {
  {
    "stevearc/aerial.nvim",
    opts = {
      -- Treesitter first (works for markdown headings without LSP), fall back to LSP.
      backends = { "treesitter", "lsp", "markdown", "man" },

      layout = {
        default_direction = "left",
        placement = "edge",
        min_width = 30,
        max_width = { 40, 0.2 }, -- min(40 cols, 20% of editor width)
      },

      -- Single sidebar reflects the focused buffer, not per-window.
      attach_mode = "global",

      -- Don't filter to functions/classes/etc. — show every symbol kind,
      -- including markdown headings and struct fields.
      filter_kind = false,

      -- Show indent guides for hierarchy.
      show_guides = true,

      -- Highlight matching symbol as cursor moves; don't auto-jump.
      autojump = false,

      -- Flash on <CR>-jump so the landing is visible.
      highlight_on_jump = 300,
    },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    config = function(_, opts)
      require("aerial").setup(opts)

      -- Toggle outline sidebar. The `!` focuses the aerial window so j/k/<CR> work immediately.
      vim.keymap.set("n", "<leader>lo", "<cmd>AerialToggle!<CR>", { desc = "Toggle [L]ist / [O]utline" })

      -- Auto-open for markdown buffers.
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "markdown" },
        callback = function()
          vim.cmd("AerialOpen")
        end,
      })
    end,
  },
}
