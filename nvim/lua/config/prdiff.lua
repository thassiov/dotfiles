-- PR-style diff: open diffview showing ONLY what the current branch introduces
-- vs the repo's default branch (main/master) -- i.e. what you'd see in a GitHub
-- PR diff (three-dot merge-base range).
--
-- Behaviour:
--   * Syncs the remote default branch first (git fetch origin <branch>); uses
--     origin/<branch> as the base when that succeeds.
--   * Falls back to the LOCAL <branch> ref if the fetch fails (offline, no
--     remote, etc) -- with a warning.
--   * --imply-local surfaces uncommitted working-tree changes on the HEAD side,
--     so edits to files already in the branch diff show up even before commit.
--     CAVEAT: a file changed ONLY in the working tree (never committed on the
--     branch) may not appear in the three-dot set; use a plain :DiffviewOpen for
--     that edge case.

local M = {}

-- Run git in the cwd; returns (exit_code, trimmed_stdout).
local function git(args)
  local out = vim.fn.system(vim.list_extend({ "git" }, args))
  return vim.v.shell_error, vim.trim(out)
end

-- Resolve the default branch: prefer origin/HEAD's target, else main, else master.
local function default_branch()
  local code, out = git({ "symbolic-ref", "--quiet", "--short", "refs/remotes/origin/HEAD" })
  if code == 0 and out ~= "" then
    return (out:gsub("^origin/", ""))
  end
  for _, b in ipairs({ "main", "master" }) do
    if select(1, git({ "show-ref", "--verify", "--quiet", "refs/heads/" .. b })) == 0 then
      return b
    end
  end
  return "main"
end

function M.open()
  if select(1, git({ "rev-parse", "--is-inside-work-tree" })) ~= 0 then
    vim.notify("prdiff: not inside a git repository", vim.log.levels.ERROR)
    return
  end

  local branch = default_branch()
  local base

  -- Try to sync the remote default branch; use origin/<branch> if it works.
  local fetched = select(1, git({ "fetch", "--quiet", "origin", branch })) == 0
  local has_remote_ref = select(1, git({ "show-ref", "--verify", "--quiet", "refs/remotes/origin/" .. branch })) == 0

  if fetched and has_remote_ref then
    base = "origin/" .. branch
  else
    base = branch
    vim.notify("prdiff: remote sync failed, using local '" .. branch .. "'", vim.log.levels.WARN)
  end

  -- Three-dot = merge-base: only what this branch introduces.
  vim.cmd(string.format("DiffviewOpen %s...HEAD --imply-local", base))
end

return M
