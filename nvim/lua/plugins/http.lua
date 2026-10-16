-- HTTP client (rest.nvim)
-- Requests live in .http files (JetBrains syntax). <Leader>S (buffer-local, http files only) runs the request under the cursor,
-- the same key dadbod uses to run a query in sql files. Other commands: :Rest last / :Rest open.
--
-- Requirements (all must line up; see nvim/README.md "rest.nvim"):
--   1. libreadline-dev (apt): lazy.nvim builds Lua 5.1 with hererocks for rest.nvim's Lua rocks.
--      Without it the build stops with "readline/readline.h: No such file or directory".
--   2. tree-sitter CLI >= 0.26.1 on PATH (release binary in ~/.local/bin; not the apt package, not npm).
--   3. One manual step on a fresh install: the rock build backend lands in the wrong tree. Run
--        ~/.local/share/nvim/lazy-rocks/hererocks/bin/luarocks install luarocks-build-treesitter-parser
--      then :Lazy build rest.nvim (README has the full sequence).
--   4. The "http" parser in site/parser, installed through the parser list in plugins/treesitter.lua.
--      The copy luarocks builds is not on Neovim's runtimepath and is not used.
-- Used with the workbench through tools/http/http-client (file tree on tool-data/http); see nvim/README.md "Using it with the workbench".
-- If a failed build retries on every start, rename this file to http.lua.disabled until it is fixed.

return {
  {
    "rest-nvim/rest.nvim",
    ft = "http",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    init = function()
      vim.g.rest_nvim = {}
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "http",
        callback = function(args)
          vim.keymap.set("n", "<Leader>S", "<cmd>Rest run<CR>", { buffer = args.buf, desc = "Run request under cursor" })
        end,
      })
    end,
  },
}
