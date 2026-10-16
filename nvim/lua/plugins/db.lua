-- Database client (dadbod) wired to the workbench
-- Requirements: psql on the host (apt: postgresql-client) and the mcp-vpn container for prod. See nvim/README.md "dadbod".
-- One `prod` connection, reached through the VPN container. Saved queries are the per-tray
-- queries.sql files linked into <workbench>/tool-data/dadbod/prod/ by tools/db/tray-sql.

local workbench = vim.fn.expand("~/dev/secondnature/workbench")
local db_proxy_port = "15432"

local function read_postgres_url()
  local file = io.open(vim.fn.expand("~/.work-credentials/db.env"), "r")
  if not file then
    return nil
  end
  local url
  for line in file:lines() do
    local value = line:match("^%s*export%s+POSTGRES_URL=(.+)$") or line:match("^%s*POSTGRES_URL=(.+)$")
    if value then
      url = value:gsub("^[\"']", ""):gsub("[\"']%s*$", "")
    end
  end
  file:close()
  return url
end

local function resolve_prod_url()
  local ensure = vim.fn.system({ vim.fn.expand("~/.work-credentials/vpn/vpn-ctl.sh"), "ensure" })
  if vim.v.shell_error ~= 0 then
    vim.notify("dadbod: could not start the VPN container\n" .. ensure, vim.log.levels.ERROR)
    return ""
  end

  local ip = vim.trim(vim.fn.system({
    "docker",
    "inspect",
    "-f",
    "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}",
    "mcp-vpn",
  }))
  local url = read_postgres_url()
  if vim.v.shell_error ~= 0 or ip == "" or not url then
    vim.notify("dadbod: could not resolve the prod URL (VPN address or db.env missing)", vim.log.levels.ERROR)
    return ""
  end

  return (url:gsub("@[^/]+/", "@" .. ip .. ":" .. db_proxy_port .. "/", 1))
end

return {
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      { "tpope/vim-dadbod", lazy = true },
    },
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
    init = function()
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_save_location = workbench .. "/tool-data/dadbod"
      vim.g.db_ui_execute_on_save = 0
      vim.g.dbs = {
        { name = "prod", url = resolve_prod_url },
      }
    end,
  },
}
