-- Diff-aware LSP navigation for diffview.
--
-- <leader>d (definition) / <leader>r (references): inside a diffview tab, a
-- target that is part of the PR diff is navigated to WITHIN the diff -- the file
-- opens as its own diff and the cursor lands on the local/right pane at the
-- target line. A target that isn't in the diff (unchanged file, node_modules, a
-- global lib) is opened in place in the current window; the left/old pane just
-- keeps showing the previous file's diff, which is harmless.
--
-- References uses a telescope picker (only when there's more than one result):
-- entries in the diff are tagged "[in diff]" and sorted to the top; selecting an
-- entry routes through the same in-diff / open-in-place logic as definition.
--
-- Outside a diffview tab, the keymap wrappers (plugins/telescope.lua) never call
-- this -- they use the normal telescope pickers.
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

-- Repo-relative path of `abs` if it's part of the current diff, else nil.
local function diff_relpath(view, abs)
  local root = view.adapter and view.adapter.ctx and view.adapter.ctx.toplevel
  local rel = root and relativize(abs, root) or nil
  if not rel then
    return nil
  end
  for _, file in view.files:iter() do
    if file.path == rel then
      return rel
    end
  end
  return nil
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

-- Route a location item: navigate within the diff if it's a PR file, else open
-- it in place. Shared by definition and references.
local function goto_item(view, item)
  local rel = diff_relpath(view, item.filename)
  if rel then
    goto_in_diff(view, rel, item)
  else
    open_in_place(item)
  end
end

-- Telescope picker for references, with an "[in diff]" tag and in-diff-first order.
local function references_picker(view, items)
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local entry_display = require("telescope.pickers.entry_display")

  -- Orange tag, brighter than the muted default. Re-set on each open so it
  -- survives colorscheme changes.
  vim.api.nvim_set_hl(0, "DiffNavInDiff", { fg = "#ff8f40", bold = true })

  local displayer = entry_display.create({
    separator = " ",
    items = {
      { width = 9 }, -- "[in diff]" tag column (exactly 9 chars)
      { width = 48 }, -- file:line
      { remaining = true }, -- line text
    },
  })

  local function make_display(entry)
    return displayer({
      { entry.value.in_diff and "[in diff]" or "", "DiffNavInDiff" },
      { entry.value.floc, "TelescopeResultsIdentifier" },
      vim.trim(entry.value.text or ""),
    })
  end

  pickers
    .new({}, {
      prompt_title = "References",
      finder = finders.new_table({
        results = items,
        entry_maker = function(it)
          local short = vim.fn.fnamemodify(it.filename, ":.")
          it.floc = string.format("%s:%d", short, it.lnum or 0)
          return {
            value = it,
            display = make_display,
            -- prefix keeps in-diff on top for the empty prompt / ties
            ordinal = (it.in_diff and "0 " or "1 ") .. short .. " " .. (it.text or ""),
            filename = it.filename,
            lnum = it.lnum,
            col = it.col,
          }
        end,
      }),
      sorter = conf.generic_sorter({}),
      previewer = conf.qflist_previewer({}),
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          local entry = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          if entry and entry.value then
            goto_item(view, entry.value)
          end
        end)
        return true
      end,
    })
    :find()
end

-- True if the current buffer is a real on-disk file (not a diffview synthetic
-- buffer like the old/left pane `diffview://...` or `diffview://null`).
local function on_real_file()
  local buf = vim.api.nvim_get_current_buf()
  local name = vim.api.nvim_buf_get_name(buf)
  return vim.bo[buf].buftype == "" and name ~= "" and not name:match("^%a[%w+.%-]*://")
end

-- Diff-aware jumplist navigation. Two problems with builtin <C-o>/<C-i> in a
-- diff:
--   1. diffview's old/left panes (`diffview://null` etc.) end up in the
--      jumplist, so a jump lands on a synthetic buffer instead of the real file.
--   2. Even when it lands on a real file, it loads the buffer directly and
--      diffview's old/left pane + file panel stay on the previous file (desync).
-- Fix: repeat the builtin jump, skipping synthetic buffers until we reach a real
-- file (or the jumplist can't move); then re-sync diffview to that file.
---@param dir "back"|"forward"
function M.jump(dir)
  local key = vim.api.nvim_replace_termcodes(dir == "forward" and "<C-i>" or "<C-o>", true, false, true)
  local ok, lib = pcall(require, "diffview.lib")
  local view = ok and lib.get_current_view() or nil

  if not view then
    vim.api.nvim_feedkeys(key, "nx", false)
    return
  end

  -- Skip synthetic diffview buffers; bail if a jump doesn't move (exhausted).
  for _ = 1, 12 do
    local pb, pc = vim.api.nvim_get_current_buf(), vim.api.nvim_win_get_cursor(0)
    vim.api.nvim_feedkeys(key, "nx", false)
    if on_real_file() then
      break
    end
    local nb, nc = vim.api.nvim_get_current_buf(), vim.api.nvim_win_get_cursor(0)
    if pb == nb and pc[1] == nc[1] and pc[2] == nc[2] then
      break
    end
  end

  if not on_real_file() then
    return
  end
  local pos = vim.api.nvim_win_get_cursor(0)
  local name = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
  local rel = diff_relpath(view, name)
  if rel and (not view.cur_entry or view.cur_entry.path ~= rel) then
    goto_in_diff(view, rel, { lnum = pos[1], col = pos[2] + 1 })
  end
end

function M.definition()
  local ok, lib = pcall(require, "diffview.lib")
  local view = ok and lib.get_current_view() or nil
  if not view then
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
      goto_item(view, items[1]) -- first result; multiple defs is a rare edge
    end,
  })
end

function M.references()
  local ok, lib = pcall(require, "diffview.lib")
  local view = ok and lib.get_current_view() or nil
  if not view then
    require("telescope.builtin").lsp_references()
    return
  end

  vim.lsp.buf.references({ includeDeclaration = true }, {
    on_list = function(result)
      local items = result and result.items or {}
      if #items == 0 then
        vim.notify("No references found", vim.log.levels.INFO)
        return
      end

      -- Tag each with diff membership, then sort in-diff first.
      for _, it in ipairs(items) do
        it.in_diff = diff_relpath(view, it.filename) ~= nil
      end
      table.sort(items, function(a, b)
        if a.in_diff ~= b.in_diff then
          return a.in_diff
        end
        if a.filename ~= b.filename then
          return a.filename < b.filename
        end
        return (a.lnum or 0) < (b.lnum or 0)
      end)

      if #items == 1 then
        goto_item(view, items[1])
        return
      end
      references_picker(view, items)
    end,
  })
end

return M
