-- Treesitter
-- Parser installer + queries for Neovim's built-in treesitter (nvim-treesitter main branch).

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup({
        install_dir = vim.fn.stdpath("data") .. "/site",
      })

      require("nvim-treesitter").install({
        "bash",
        "c",
        "html",
        "lua",
        "markdown",
        "markdown_inline",
        "vim",
        "vimdoc",
        "cpp",
        "css",
        "cmake",
        "diff",
        "csv",
        "dockerfile",
        "git_config",
        "git_rebase",
        "gitcommit",
        "gitignore",
        "graphql",
        "hcl",
        "jsdoc",
        "json",
        "javascript",
        "luadoc",
        "passwd",
        "pem",
        "python",
        "rasi",
        "readline",
        "regex",
        "rust",
        "go",
        "sql",
        "ssh_config",
        "terraform",
        "toml",
        "tmux",
        "tsx",
        "xml",
      })

      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          pcall(vim.treesitter.start, args.buf)
          -- Folding is owned by nvim-ufo (see plugins/folds.lua). ufo's
          -- treesitter provider applies *manual* folds, so don't set
          -- foldmethod=expr here -- expr recomputes folds on every buffer
          -- change, which slams the fold under the cursor shut on InsertLeave.
        end,
      })
    end,
  },
}
