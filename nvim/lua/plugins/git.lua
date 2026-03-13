-- Git Plugins
-- Git integration and tools

return {
  -- Git signs in gutter
  {
    "lewis6991/gitsigns.nvim",
  },

  -- Git commands
  {
    "tpope/vim-fugitive",
    keys = {
      { "<leader>gs", "<cmd>Git<CR>", desc = "[G]it [S]tatus" },
      { "<leader>gb", "<cmd>Git blame<CR>", desc = "[G]it [B]lame" },
    },
  },

  -- Git diff viewer
  {
    "sindrets/diffview.nvim",
    opts = {
      keymaps = {
        view = {
          { "n", "<leader>q", "<cmd>DiffviewClose<CR>", { desc = "Close diff view" } },
        },
      },
    },
    keys = {
      { "<leader>gd", "<cmd>DiffviewFileHistory %<CR>", desc = "[G]it [D]iff current file" },
      { "<leader>gD", "<cmd>DiffviewOpen<CR>", desc = "[G]it [D]iff index" },
    },
  },

  -- Visual git with inline diff, blame, and history
  {
    "tanvirtin/vgit.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    event = "VimEnter",
    config = function()
      require("vgit").setup({
        settings = {
          live_blame = {
            enabled = true,
          },
          live_gutter = {
            enabled = true,
          },
          scene = {
            diff_preference = "unified", -- or "split"
          },
        },
      })
    end,
    keys = {
      -- Hunk operations
      {
        "<leader>ghp",
        function()
          require("vgit").hunk_preview()
        end,
        desc = "[G]it [H]unk [P]review",
      },
      {
        "<leader>ghs",
        function()
          require("vgit").buffer_hunk_stage()
        end,
        desc = "[G]it [H]unk [S]tage",
      },
      {
        "<leader>ghr",
        function()
          require("vgit").buffer_hunk_reset()
        end,
        desc = "[G]it [H]unk [R]eset",
      },
      {
        "<leader>ghu",
        function()
          require("vgit").buffer_reset()
        end,
        desc = "[G]it [H]unk [U]ndo buffer",
      },
      {
        "]h",
        function()
          require("vgit").hunk_down()
        end,
        desc = "Next git hunk",
      },
      {
        "[h",
        function()
          require("vgit").hunk_up()
        end,
        desc = "Previous git hunk",
      },

      -- Buffer operations
      {
        "<leader>gf",
        function()
          require("vgit").buffer_diff_preview()
        end,
        desc = "[G]it buffer diff (File)",
      },
      {
        "<leader>gl",
        function()
          require("vgit").buffer_blame_preview()
        end,
        desc = "[G]it buffer blame (Line)",
      },
      {
        "<leader>gt",
        function()
          require("vgit").buffer_history_preview()
        end,
        desc = "[G]it buffer history (Timeline)",
      },

      -- Project operations
      {
        "<leader>gp",
        function()
          require("vgit").project_diff_preview()
        end,
        desc = "[G]it [P]roject diff",
      },
      {
        "<leader>gP",
        function()
          require("vgit").project_logs_preview()
        end,
        desc = "[G]it [P]roject logs",
      },

      -- Toggle
      {
        "<leader>gx",
        function()
          require("vgit").toggle_diff_preference()
        end,
        desc = "[G]it toggle diff style (unified/split)",
      },
    },
  },
}
