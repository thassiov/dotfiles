-- Markdown & Note-taking
-- Markdown rendering and bullets

return {
  -- Markdown rendering
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {},
    dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" },
    config = function()
      require("render-markdown").setup({})
    end,
  },

  -- Better bullets in markdown
  "bullets-vim/bullets.vim",
}
