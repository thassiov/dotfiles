-- Database client (dadbod) wired to the workbench
-- Saved queries are the per-tray queries.sql files, linked into <workbench>/tool-data/dadbod/<connection>/ by tools/db/tray-sql.
-- Which connections exist depends on the machine (see config/workbench.lua):
--   work:     one `prod` connection, reached through the VPN container. Needs psql and the mcp-vpn container. See nvim/README.md "dadbod".
--   personal: `infrastructure` and `knowledge` on postgres.grid.local, over the home network (no VPN). Needs psql and the grid CLI,
--             which fetches the password from 1Password (`grid secrets get postgres-grid-admin password --reveal`).

local wb = require("config.workbench")
local workbench = wb.root
local db_proxy_port = "15432"

-- ---------------------------------------------------------------- work: prod through the VPN container
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

-- ---------------------------------------------------------------- personal: grid databases over the home network
-- The password goes to psql through PGPASSWORD, so it is never in the URL or on a command line. It stays in this nvim session's
-- environment until you quit, so anything started from here (a :terminal, a language server) can read it.
local function ensure_grid_password()
  if (vim.env.PGPASSWORD or "") ~= "" then
    return true
  end
  local password = vim.env.POSTGRES_PASSWORD or ""
  if password == "" then
    local result = vim.system({ "grid", "secrets", "get", "postgres-grid-admin", "password", "--reveal" }, { text = true, timeout = 20000 }):wait()
    if result.code == 0 then
      password = (result.stdout or ""):match("([^\r\n]+)%s*$") or ""
    end
  end
  if password == "" then
    vim.notify("dadbod: could not get the grid database password (is the grid CLI set up for 1Password?)", vim.log.levels.ERROR)
    return false
  end
  vim.env.PGPASSWORD = password
  return true
end

local function grid_url(database)
  return function()
    if not ensure_grid_password() then
      return ""
    end
    local host = vim.env.POSTGRES_HOST or "postgres.grid.local"
    return ("postgresql://grid_admin@%s:5432/%s"):format(host, database)
  end
end

local function connections()
  if wb.kind == "work" then
    return { { name = "prod", url = resolve_prod_url } }
  end
  return {
    { name = "infrastructure", url = grid_url("infrastructure") },
    { name = "knowledge", url = grid_url("knowledge") },
  }
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
      vim.g.dbs = connections()
    end,
  },
}
