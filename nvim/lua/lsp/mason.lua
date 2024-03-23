require("mason").setup()
require("mason-lspconfig").setup()
require("mason-lspconfig").setup_handlers {
  function (server_name)
    require("lspconfig")[server_name].setup {}
    end,
}

require("mason-nvim-dap").setup()

require("mason-null-ls").setup()
require("null-ls").setup()

