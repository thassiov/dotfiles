-- Folds
-- nvim-ufo: modern fold UI on top of vim's folding.
-- Uses the existing treesitter foldexpr (set per-filetype in plugins/treesitter.lua)
-- as the provider; ufo just renders better and adds preview/peek.

return {
  {
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },
    event = "BufReadPost",
    config = function()
      -- ufo requires high foldlevel globally so folds don't auto-close on open.
      -- Per-filetype overrides (e.g. markdown -> foldlevel=1) live in
      -- config/autocommands.lua and win because they're window-local.
      vim.opt.foldlevel = 99
      vim.opt.foldlevelstart = 99
      vim.opt.foldenable = true
      vim.opt.foldcolumn = "1"

      require("ufo").setup({
        provider_selector = function(_, _, _)
          -- Use treesitter where the parser exists; fall back to indent.
          return { "treesitter", "indent" }
        end,
        open_fold_hl_timeout = 250,
        preview = {
          win_config = {
            border = { "", "─", "", "", "", "─", "", "" },
            winhighlight = "Normal:Folded",
            winblend = 0,
          },
        },
      })

      -- Keymaps (use ufo's enhanced versions of z* commands).
      vim.keymap.set("n", "zR", require("ufo").openAllFolds, { desc = "Open all folds (ufo)" })
      vim.keymap.set("n", "zM", require("ufo").closeAllFolds, { desc = "Close all folds (ufo)" })
      vim.keymap.set("n", "zr", require("ufo").openFoldsExceptKinds, { desc = "Open folds except kinds (ufo)" })
      vim.keymap.set("n", "zm", require("ufo").closeFoldsWith, { desc = "Close folds with level (ufo)" })

      -- Peek folded lines under cursor; fall back to LSP hover.
      vim.keymap.set("n", "K", function()
        local winid = require("ufo").peekFoldedLinesUnderCursor()
        if not winid then
          vim.lsp.buf.hover()
        end
      end, { desc = "Peek fold or LSP hover" })
    end,
  },
}
