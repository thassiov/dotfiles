-- Git Plugins
-- gitsigns: gutter signs, current-line blame lens, detailed blame popup,
--           status-bar branch/diff (via lualine defaults that read gitsigns state)
-- fugitive: project status, file blame, side-by-side diff, file/line history
-- diffview: PR-style review -- branch-vs-main diff in its own tab, file panel,
--           full navigable side-by-side buffers (see lua/config/prdiff.lua)

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

  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles" },
    keys = {
      {
        "<leader>prd",
        function()
          require("config.prdiff").open()
        end,
        desc = "[P]ull [R]equest [D]iff (branch vs main)",
      },
    },
    opts = function()
      local actions = require("diffview.actions")
      return {
        -- R4: side-by-side (two vertical windows), full file loaded each side.
        view = {
          default = { layout = "diff2_horizontal" },
        },
        -- R3: changed-file list panel with +/- counts, left side, tree layout.
        file_panel = {
          listing_style = "tree",
          win_config = { position = "left", width = 35 },
        },
        hooks = {
          -- Give the LSP a clean buffer to attach to. typescript-tools inits
          -- tsserver once per session off the *current* buffer; if that first
          -- init happens while a synthetic `diffview://` buffer is current it
          -- asserts and never starts (see root_dir guard in lsp.lua). Once the
          -- view is up, focus the first real (on-disk) file pane and re-fire
          -- FileType so the attach -> init runs with a valid current buffer.
          -- Skipped once tsserver is already warm.
          view_opened = function()
            vim.defer_fn(function()
              local ok, provider = pcall(require, "typescript-tools.tsserver_provider")
              if ok and provider.npm_global_path then
                return -- already initialised this session
              end
              for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
                local buf = vim.api.nvim_win_get_buf(win)
                local name = vim.api.nvim_buf_get_name(buf)
                if vim.bo[buf].buftype == "" and vim.fn.filereadable(name) == 1 then
                  vim.api.nvim_set_current_win(win)
                  vim.api.nvim_exec_autocmds("FileType", { buffer = buf, modeline = false })
                  break
                end
              end
            end, 200)
          end,
        },
        -- Merged on top of diffview defaults (<tab>/<s-tab> next/prev file kept).
        keymaps = {
          view = {
            { "n", "<leader>e", actions.toggle_files, { desc = "Toggle file panel" } },
            { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close PR diff" } },
          },
          file_panel = {
            { "n", "<leader>e", actions.toggle_files, { desc = "Toggle file panel" } },
            { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close PR diff" } },
          },
        },
      }
    end,
  },
}
