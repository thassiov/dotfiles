-- Development Tools
-- Testing, REST client, and other utilities

return {
  -- Testing utility
  {
    "vim-test/vim-test",
    dependencies = {
      "voldikss/vim-floaterm",
    },
    keys = {
      { "<leader>t", "<cmd>TestNearest<CR>", desc = "Run nearest test" },
      { "<leader>T", "<cmd>TestFile<CR>", desc = "Run all tests in file" },
    },
    init = function()
      vim.g["test#strategy"] = "neovim"
    end,
  },

  -- REST client
  {
    "jellydn/hurl.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    ft = "hurl",
    opts = {
      debug = false,
      show_notification = true,
      mode = "split",
      formatters = {
        json = { "jq" },
        html = {
          "prettier",
          "--parser",
          "html",
        },
      },
    },
    keys = {
      { "<leader>H", "<cmd>HurlRunner<CR>", desc = "Run all requests" },
      { "<leader>h", "<cmd>HurlRunnerAt<CR>", desc = "Run request at cursor" },
      { "<leader>vh", "<cmd>HurlVerbose<CR>", desc = "Run request in verbose mode" },
    },
  },
}
