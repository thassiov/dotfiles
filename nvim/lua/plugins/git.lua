-- Git Plugins
-- gitsigns: gutter signs, current-line blame lens, detailed blame popup,
--           status-bar branch/diff (via lualine defaults that read gitsigns state)
-- fugitive: project status, file blame, side-by-side diff, file/line history

return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      current_line_blame = true,
      current_line_blame_opts = {
        delay = 300,
        virt_text_pos = "eol",
      },
    },
    keys = {
      {
        "<leader>5",
        function()
          require("gitsigns").blame_line({ full = true })
        end,
        desc = "Blame current line (detailed popup)",
      },
    },
  },

  {
    "tpope/vim-fugitive",
    keys = {
      { "<leader>gs", "<cmd>Git<CR>", desc = "[G]it [S]tatus" },
      { "<leader>gb", "<cmd>Git blame<CR>", desc = "[G]it [B]lame (file)" },
      { "<leader>gD", "<cmd>Gdiffsplit<CR>", desc = "[G]it [D]iff current file" },
      { "<leader>gt", "<cmd>0Glog<CR>", desc = "[G]it file history (timeline)" },
      {
        "<leader>gt",
        function()
          local s = vim.fn.getpos("v")[2]
          local e = vim.fn.getpos(".")[2]
          if s > e then
            s, e = e, s
          end
          vim.cmd(string.format("Gclog -L%d,%d:%%", s, e))
        end,
        mode = "v",
        desc = "[G]it line history (visual range)",
      },
    },
  },
}
