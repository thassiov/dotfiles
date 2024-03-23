lua << EOF
require("mason").setup()
require("mason-lspconfig").setup({
ensure_installed = {
  'bashls',
  'cssls',
  'diagnosticls',
  'docker_compose_language_service',
  'dockerls',
  'eslint',
  'html',
  'jsonls',
  'ltex',
  'lua_ls',
  'pylsp',
  'terraformls',
  'tsserver',
  'vimls',
  'yamlls'
}
})
require("mason-lspconfig").setup_handlers {
  function (server_name) 
    require("lspconfig")[server_name].setup {}
    end,
}

require("mason-nvim-dap").setup()

-- require('lint').setup()
vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  callback = function()
  require("lint").try_lint()
  end,
})


require("formatter").setup({
logging = true,
filetype = {
  html = {
    require("formatter.filetypes.html").prettier,
  },
  css = {
    require("formatter.filetypes.css").prettier,
  },
  json = {
    require("formatter.filetypes.json").prettier,
  },
  javascript = {
    require("formatter.filetypes.javascript").prettier,
  },
  javascriptreact = {
    require("formatter.filetypes.javascriptreact").prettier,
  },
  typescript = {
    require("formatter.filetypes.typescript").prettier,
  },
  typescriptreact = {
    require("formatter.filetypes.typescriptreact").prettier,
  },
},
})
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
augroup("__formatter__", { clear = true })
autocmd("BufWritePost", {
  group = "__formatter__",
  command = ":FormatWrite",
})
EOF
