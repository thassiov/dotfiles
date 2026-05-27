-- Telescope
-- Fuzzy finder for files, buffers, LSP, and more

return {
  {
    "nvim-telescope/telescope.nvim",
    event = "VimEnter",
    branch = "master",
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

      pcall(require("telescope").load_extension, "fzf")
      pcall(require("telescope").load_extension, "ui-select")

      local builtin = require("telescope.builtin")

      -- ============================================================================
      -- NUMBERED / SYMBOL PICKERS (revived from the coc.nvim era)
      -- ============================================================================
      vim.keymap.set("n", "<leader>1", builtin.lsp_document_symbols, { desc = "File symbols (LSP)" })
      vim.keymap.set("n", "<leader>!", builtin.lsp_document_symbols, { desc = "File symbols (LSP)" })
      vim.keymap.set("n", "<leader>2", builtin.buffers, { desc = "Buffers" })
      vim.keymap.set("n", "<leader>3", builtin.git_files, { desc = "Git files" })
      vim.keymap.set("n", "<leader>#", builtin.find_files, { desc = "All files" })
      vim.keymap.set("n", "<leader>4", builtin.live_grep, { desc = "Grep project" })

      -- Command palette
      vim.keymap.set("n", "<leader><leader>", builtin.commands, { desc = "Command palette" })

      -- ============================================================================
      -- SEARCH OPERATIONS (s prefix)
      -- ============================================================================
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

      -- ============================================================================
      -- FILE OPERATIONS (f prefix)
      -- ============================================================================
      vim.keymap.set("n", "<leader>fn", function()
        builtin.find_files({ cwd = vim.fn.stdpath("config") })
      end, { desc = "[F]ind [N]eovim config files" })
      vim.keymap.set("n", "<leader>ff", vim.lsp.buf.code_action, { desc = "Code action (LSP fix)" })

      -- ============================================================================
      -- LSP / CODE NAVIGATION (g prefix + diagnostics)
      -- ============================================================================
      vim.keymap.set("n", "<leader>gd", builtin.lsp_definitions, { desc = "[G]o to [D]efinition" })
      vim.keymap.set("n", "<leader>gy", builtin.lsp_type_definitions, { desc = "[G]o to t[Y]pe definition" })
      vim.keymap.set("n", "<leader>gr", builtin.lsp_references, { desc = "[G]o to [R]eferences" })
      vim.keymap.set("n", "<leader>lw", builtin.lsp_dynamic_workspace_symbols, { desc = "[L]SP [W]orkspace symbols" })
      vim.keymap.set("n", "<leader>le", vim.diagnostic.open_float, { desc = "[L]SP show [E]rrors (float)" })
      vim.keymap.set("n", "<leader>cd", builtin.diagnostics, { desc = "[C]ode [D]iagnostics" })

      -- ============================================================================
      -- GIT (telescope-side; fugitive owns <leader>gs and <leader>gb)
      -- ============================================================================
      vim.keymap.set("n", "<leader>gc", builtin.git_commits, { desc = "[G]it [C]ommits" })
    end,
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "TelescopeResults",
        command = "setlocal nofoldenable",
      })
    end,
  },
}
