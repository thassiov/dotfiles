-- Markdown & Note-taking
-- Markdown rendering and bullets

return {
  -- Markdown rendering
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.nvim" },
    opts = {
      -- Anti-conceal: show raw syntax on cursor line so editing isn't lossy.
      anti_conceal = {
        enabled = true,
        above = 0,
        below = 0,
        ignore = {
          code_background = true,
          indent = true,
          sign = true,
          virtual_lines = true,
        },
      },

      -- LaTeX (requires `utftex` or `latex2text` external binary).
      latex = {
        enabled = true,
        converter = { "utftex", "latex2text" },
        position = "center",
        top_pad = 0,
        bottom_pad = 0,
      },

      -- Headings: per-level icons, full-width bar background, borders on H1/H2.
      heading = {
        enabled = true,
        atx = true,
        setext = true,
        sign = true,
        icons = { "█ ", "▓ ", "▒ ", "░ ", "● ", "○ " },
        position = "overlay",
        width = "full",
        left_margin = 0,
        left_pad = 0,
        right_pad = 2,
        min_width = 60,
        -- Top/bottom border on H1+H2 only (lower levels get just the bar).
        border = { true, true, false, false, false, false },
        border_virtual = true,
        border_prefix = true,
        above = "▄",
        below = "▀",
      },

      paragraph = {
        enabled = true,
        left_margin = 0,
        indent = 0,
        min_width = 0,
      },

      -- Code: thick border, language label + icon, inline code with padding.
      code = {
        enabled = true,
        sign = true,
        conceal_delimiters = true,
        language = true,
        position = "left",
        language_icon = true,
        language_name = true,
        language_info = true,
        language_pad = 0,
        disable_background = { "diff" },
        background_inset = 1,
        width = "block",
        left_margin = 0,
        left_pad = 2,
        right_pad = 2,
        min_width = 0,
        border = "thick",
        language_border = "█",
        above = "▄",
        below = "▀",
        inline = true,
        inline_left = "",
        inline_right = "",
        inline_pad = 1,
        style = "full",
      },

      -- Thematic break (---) as full-width unicode rule.
      dash = {
        enabled = true,
        icon = "─",
        width = "full",
      },

      document = { enabled = true },

      -- Bullets cycle by nesting depth.
      bullet = {
        enabled = true,
        icons = { "●", "○", "◆", "◇" },
        left_pad = 0,
        right_pad = 0,
      },

      -- Checkboxes: standard states + extra custom ones.
      checkbox = {
        enabled = true,
        bullet = false,
        left_pad = 0,
        right_pad = 1,
        unchecked = { icon = "󰄱 ", highlight = "RenderMarkdownUnchecked" },
        checked = { icon = "󰱒 ", highlight = "RenderMarkdownChecked" },
        -- stylua: ignore
        custom = {
          todo      = { raw = "[-]", rendered = "󰥔 ", highlight = "RenderMarkdownTodo" },
          cancelled = { raw = "[~]", rendered = "󰜺 ", highlight = "RenderMarkdownChecked" },
          important = { raw = "[!]", rendered = "󰀪 ", highlight = "RenderMarkdownWarn" },
          question  = { raw = "[?]", rendered = "󰘥 ", highlight = "RenderMarkdownInfo" },
          star      = { raw = "[*]", rendered = "󰓎 ", highlight = "RenderMarkdownInfo" },
        },
      },

      -- Quotes: repeat the bar on wrapped lines (needs breakindent — set in autocommands).
      quote = {
        enabled = true,
        icon = "▋",
        repeat_linebreak = true,
        highlight = {
          "RenderMarkdownQuote1",
          "RenderMarkdownQuote2",
          "RenderMarkdownQuote3",
          "RenderMarkdownQuote4",
          "RenderMarkdownQuote5",
          "RenderMarkdownQuote6",
        },
      },

      -- Also render markdown in diff view.
      render = { diff = true },

      -- Tables: round borders, trimmed cells + virtual borders for long-row tolerance.
      pipe_table = {
        enabled = true,
        preset = "round",
        cell = "trimmed",
        padding = 1,
        min_width = 0,
        border_enabled = true,
        border_virtual = true,
        alignment_indicator = "━",
        style = "full",
      },

      -- Callouts: full GitHub + Obsidian palette is the plugin's default — ~25 types.
      -- Not overridden.

      -- Link icons: default covers footnote/image/email/wiki + 20+ URL patterns.
      -- Not overridden.

      sign = { enabled = true },

      -- Obsidian-style ==highlighted text==.
      inline_highlight = { enabled = true },

      -- Org-indent-mode emulation: indent content under H2+.
      indent = {
        enabled = true,
        per_level = 2,
        skip_level = 1,
        skip_heading = false,
        icon = "▎",
      },

      -- Inline HTML: conceal comments, icons on common tags.
      html = {
        enabled = true,
        comment = { conceal = true },
        -- stylua: ignore
        tag = {
          details = { icon = "󰂖 " },
          summary = { icon = "󰁂 " },
          kbd     = { icon = "󰌌 " },
          mark    = { icon = "󰷯 " },
        },
      },

      -- Window options swapped between rendered and raw view.
      win_options = {
        conceallevel = {
          default = vim.o.conceallevel,
          rendered = 3,
        },
        concealcursor = {
          default = vim.o.concealcursor,
          rendered = "",
        },
      },

      -- Also render in floating/preview buffers (noice, lazy, claudecode chat, etc.).
      overrides = {
        buftype = {
          nofile = {
            render_modes = true,
            padding = { highlight = "NormalFloat" },
            sign = { enabled = false },
          },
        },
        preview = { render_modes = true },
      },

      -- YAML frontmatter.
      yaml = { enabled = true },
    },
  },

  -- Better bullets in markdown
  "bullets-vim/bullets.vim",
}
