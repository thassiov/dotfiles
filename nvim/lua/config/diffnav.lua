-- Diff-aware LSP navigation for diffview.
--
-- <leader>d (go to definition): inside a diffview tab, jump to the definition
-- WITHIN the diff -- the target file opens as its own diff and the cursor lands
-- on the local/right pane at the target line. If the target file isn't part of
-- the PR diff (unchanged file, node_modules, a global lib), it's opened in place
-- in the current window instead; the left/old pane just keeps showing the
-- previous file's diff, which is harmless.
--
-- Outside a diffview tab, the keymap wrapper (plugins/telescope.lua) never calls
-- this -- it uses the normal telescope picker.
--
-- Relies on diffview's semi-private view API (get_current_view, set_file_by_path,
-- cur_layout:get_main_win, emitter). Pinned via lazy-lock, so stable for us.
-- The right pane is the actual local file the LSP indexed, so the target
-- line/col map 1:1 -- no old/new translation.

local M = {}

-- Make `abs` relative to git root `root`, or nil if it's outside the repo.
local function relativize(abs, root)
  abs = vim.fs.normalize(abs)
  root = vim.fs.normalize(root)
  if root:sub(-1) ~= "/" then
    root = root .. "/"
  end
  if abs:sub(1, #root) == root then
    return abs:sub(#root + 1)
  end
  return nil
end

-- Is `rel` (repo-relative path) one of the files in the current diff?
local function in_diff(view, rel)
  for _, file in view.files:iter() do
    if file.path == rel then
      return true
    end
  end
  return false
end

-- Move cursor to the target location in the current window and center.
local function place_cursor(win, item)
  pcall(vim.api.nvim_set_current_win, win)
  pcall(vim.api.nvim_win_set_cursor, win, { item.lnum, math.max((item.col or 1) - 1, 0) })
  vim.cmd("normal! zz")
end

-- Open the target in the current window (fallback: target not in the diff).
local function open_in_place(item)
  vim.cmd.edit(vim.fn.fnameescape(item.filename))
  place_cursor(0, item)
end

-- Navigate the diff to `rel` and place the cursor once its diff has loaded.
local function goto_in_diff(view, rel, item)
  local placed = false
  local function place()
    if placed then
      return
    end
    placed = true
    pcall(function()
      view.emitter:off(place, "file_open_post")
    end)
    place_cursor(view.cur_layout:get_main_win().id, item)
  end

  -- set_file is async; place the cursor after the file's diff finishes loading.
  view.emitter:on("file_open_post", place)
  view:set_file_by_path(rel, true, true)
  -- Safety net if the event doesn't fire (e.g. already the current entry).
  vim.defer_fn(place, 150)
end

function M.definition()
  local ok, lib = pcall(require, "diffview.lib")
  local view = ok and lib.get_current_view() or nil
  if not view then
    -- Not in a diff tab -- just do a normal jump.
    vim.lsp.buf.definition()
    return
  end

  vim.lsp.buf.definition({
    on_list = function(result)
      local items = result and result.items or {}
      if #items == 0 then
        vim.notify("No definition found", vim.log.levels.INFO)
        return
      end

      local item = items[1] -- first result; multiple defs is a rare edge
      local root = view.adapter and view.adapter.ctx and view.adapter.ctx.toplevel
      local rel = root and relativize(item.filename, root) or nil

      if rel and in_diff(view, rel) then
        goto_in_diff(view, rel, item)
      else
        open_in_place(item)
      end
    end,
  })
end

return M
