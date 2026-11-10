-- Where the workbench and its tools live on this machine.
-- The same config runs on the work machine and on the personal one, so detect which one this is.
--   work:      ~/dev/secondnature/{workbench,tools} exists
--   personal:  everything else (/storage/dev/personal/{workbench,tools})
-- $WORKBENCH overrides the workbench root on either machine; the tools in tools/db and tools/http read the same variable.

local M = {}

local work = vim.fn.expand("~/dev/secondnature")

if vim.uv.fs_stat(work .. "/workbench") then
  M.kind = "work"
  M.root = vim.env.WORKBENCH or (work .. "/workbench")
  M.tools = work .. "/tools"
else
  M.kind = "personal"
  M.root = vim.env.WORKBENCH or "/storage/dev/personal/workbench"
  M.tools = "/storage/dev/personal/tools"
end

return M
