-- Autocommands
-- Automatic commands that run on events

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Markdown fold experience: open with sections collapsed below H1, show the fold
-- column on the left, and render closed folds as a clean heading line.
function _G.markdown_foldtext()
  local line = vim.fn.getline(vim.v.foldstart)
  local count = vim.v.foldend - vim.v.foldstart + 1
  return string.format("%s   ⮟ [%d lines]", line, count)
end

vim.api.nvim_create_autocmd("FileType", {
  desc = "Markdown fold + wrap tuning",
  group = vim.api.nvim_create_augroup("markdown-folds", { clear = true }),
  pattern = "markdown",
  callback = function()
    -- Folds
    vim.opt_local.foldlevel = 1
    vim.opt_local.foldcolumn = "1"
    vim.opt_local.foldtext = "v:lua.markdown_foldtext()"
    vim.opt_local.fillchars:append({ fold = " " })
    -- Wrap config so render-markdown.nvim's quote.repeat_linebreak works correctly
    -- (the quote bar `▋` repeats on wrapped lines).
    vim.opt_local.wrap = true
    vim.opt_local.breakindent = true
    vim.opt_local.breakindentopt = ""
    vim.opt_local.showbreak = "  "
    -- Hard-wrap at 160 chars on insert (and for gq formatting).
    vim.opt_local.textwidth = 160
  end,
})
