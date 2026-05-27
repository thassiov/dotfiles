-- Markdown & Note-taking
-- Markdown rendering and bullets

return {
  -- Markdown rendering
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.nvim" },
    opts = {
      -- Show raw syntax on the cursor line so editing isn't lossy; conceal everywhere else.
      anti_conceal = { enabled = true, above = 0, below = 0 },

      -- Per-level heading icons. Decreasing visual weight: full block -> shades -> dots.
      heading = {
        enabled = true,
        sign = true,
        icons = { "█ ", "▓ ", "▒ ", "░ ", "● ", "○ " },
        width = "block", -- background bar spans only the heading text width
        left_pad = 0,
        right_pad = 2,
      },

      -- Code blocks: thick border, language label on the left, padding inside.
      code = {
        enabled = true,
        style = "full",
        position = "left",
        border = "thick",
        width = "block",
        left_pad = 2,
        right_pad = 2,
        above = "▄",
        below = "▀",
      },

      -- Bullets cycle by nesting depth.
      bullet = {
        enabled = true,
        icons = { "●", "○", "◆", "◇" },
      },

      -- Tables with round Unicode borders.
      pipe_table = {
        enabled = true,
        preset = "round",
        style = "full",
        cell = "padded",
      },

      -- Indent guides off by default — flip to true if you want hierarchical indent.
      indent = { enabled = false },

      -- Default callout palette already includes GitHub + Obsidian variants.
      -- No override needed unless we want different icons/colors.
    },
  },

  -- Better bullets in markdown
  "bullets-vim/bullets.vim",
}
