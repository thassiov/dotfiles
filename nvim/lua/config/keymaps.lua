-- Keymaps
-- General keybindings (plugin-specific keymaps are in their plugin files)

-- Clear search highlight
vim.keymap.set("n", "<leader>.", "<cmd>nohlsearch<CR>", { desc = "Clear highlight" })

-- Buffer management
vim.keymap.set("n", "<leader>w", "<cmd>w<CR>", { desc = "Save buffer" })
vim.keymap.set("n", "<C-c>", "<cmd>bd<CR>", { desc = "Close buffer" })
vim.keymap.set("n", "<Tab>", "<cmd>bnext<CR>", { desc = "Navigate to the next open buffer" })
vim.keymap.set("n", "<S-Tab>", "<cmd>bprevious<CR>", { desc = "Navigate to the previous open buffer" })

-- Close hidden buffers (requires close_buffers plugin)
vim.keymap.set(
  "n",
  "<leader>o",
  "<cmd>lua require('close_buffers').delete({ type = 'hidden', force = true })<CR>",
  { desc = "Close buffers and leave only the buffers that are open in the screen" }
)

-- Close other buffers (requires close_buffers plugin)
vim.keymap.set(
  "n",
  "<leader>O",
  "<cmd>lua require('close_buffers').delete({ type = 'other' })<CR>",
  { desc = "Close buffers and leave only the current buffer open" }
)

-- Close floating windows with Esc
vim.keymap.set("n", "<esc>", function()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_config(win).relative == "win" then
      vim.api.nvim_win_close(win, false)
    end
  end
end, { desc = "Closes popups (floating windows) using Esc" })

-- Folding
vim.keymap.set(
  "n",
  "<leader>fafe",
  "zMzvzz",
  { desc = "Folds all foldable blocks except the current one under cursor" }
)

-- Diagnostics
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous [D]iagnostic message" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next [D]iagnostic message" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic [E]rror messages" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- Window navigation
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })
