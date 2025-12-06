-- Telescope
-- Fuzzy finder for files, buffers, LSP, and more

return {
  {
    "nvim-telescope/telescope.nvim",
    event = "VimEnter",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function()
          return vim.fn.executable("make") == 1
        end,
      },
      { "nvim-telescope/telescope-ui-select.nvim" },
      { "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
    },
    config = function()
      require("telescope").setup({
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown(),
          },
        },
      })

      -- Enable extensions
      pcall(require("telescope").load_extension, "fzf")
      pcall(require("telescope").load_extension, "ui-select")

      -- Keymaps
      local builtin = require("telescope.builtin")

      -- ============================================================================
      -- SUPER QUICK ACCESS (Most Common - Single Key)
      -- ============================================================================
      vim.keymap.set("n", "<leader>f", builtin.git_files, { desc = "Find files (git)" })
      vim.keymap.set("n", "<leader>F", builtin.find_files, { desc = "Find ALL files" })
      vim.keymap.set("n", "<leader>g", builtin.live_grep, { desc = "Grep text in project" })
      vim.keymap.set("n", "<leader>b", builtin.buffers, { desc = "Search buffers" })
      vim.keymap.set("n", "<leader>/", function()
        builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
          winblend = 10,
          previewer = false,
        }))
      end, { desc = "Search in current buffer" })

      -- ============================================================================
      -- FILE OPERATIONS (f prefix)
      -- ============================================================================
      vim.keymap.set("n", "<leader>ff", builtin.git_files, { desc = "[F]ind [F]iles (git)" })
      vim.keymap.set("n", "<leader>fa", builtin.find_files, { desc = "[F]ind [A]ll files" })
      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "[F]ind [B]uffers" })
      vim.keymap.set("n", "<leader>fn", function()
        builtin.find_files({ cwd = vim.fn.stdpath("config") })
      end, { desc = "[F]ind [N]eovim config files" })

      -- ============================================================================
      -- SEARCH OPERATIONS (s prefix)
      -- ============================================================================
      vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
      vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch [W]ord under cursor" })
      vim.keymap.set("n", "<leader>sb", function()
        builtin.live_grep({
          grep_open_files = true,
          prompt_title = "Live Grep in Open Files",
        })
      end, { desc = "[S]earch in open [B]uffers" })
      vim.keymap.set("n", "<leader>s/", function()
        builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
          winblend = 10,
          previewer = false,
        }))
      end, { desc = "[S]earch in current buffer" })
      vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
      vim.keymap.set("n", "<leader>sc", builtin.commands, { desc = "[S]earch [C]ommands" })

      -- ============================================================================
      -- LSP OPERATIONS (l prefix)
      -- ============================================================================
      vim.keymap.set("n", "<leader>ld", builtin.lsp_definitions, { desc = "[L]SP [D]efinition" })
      vim.keymap.set("n", "<leader>lt", builtin.lsp_type_definitions, { desc = "[L]SP [T]ype definition" })
      vim.keymap.set("n", "<leader>lr", builtin.lsp_references, { desc = "[L]SP [R]eferences" })
      vim.keymap.set("n", "<leader>ls", builtin.lsp_document_symbols, { desc = "[L]SP document [S]ymbols" })
      vim.keymap.set("n", "<leader>lw", builtin.lsp_dynamic_workspace_symbols, { desc = "[L]SP [W]orkspace symbols" })
      vim.keymap.set("n", "<leader>ln", vim.lsp.buf.rename, { desc = "[L]SP re[N]ame" })
      vim.keymap.set("n", "<leader>la", vim.lsp.buf.code_action, { desc = "[L]SP code [A]ction" })
      vim.keymap.set("n", "<leader>le", vim.diagnostic.open_float, { desc = "[L]SP show [E]rrors (float)" })
      vim.keymap.set("n", "<leader>lD", builtin.diagnostics, { desc = "[L]SP search [D]iagnostics" })

      -- ============================================================================
      -- GIT OPERATIONS (g prefix)
      -- ============================================================================
      vim.keymap.set("n", "<leader>gs", builtin.git_status, { desc = "[G]it [S]tatus" })
      vim.keymap.set("n", "<leader>gc", builtin.git_commits, { desc = "[G]it [C]ommits" })
      vim.keymap.set("n", "<leader>gb", builtin.git_bcommits, { desc = "[G]it [B]uffer commits" })
    end,
    init = function()
      -- Disable folding in Telescope results
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "TelescopeResults",
        command = "setlocal nofoldenable",
      })
    end,
  },
}
