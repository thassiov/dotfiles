-- File Navigation
-- File tree explorer

return {
	-- File tree explorer
	{
		"kyazdani42/nvim-tree.lua",
		config = function()
			require("nvim-tree").setup({
				disable_netrw = true,
				hijack_netrw = true,
				create_in_closed_folder = false,
				respect_buf_cwd = true,
				open_on_tab = false,
				hijack_cursor = false,
				update_cwd = false,
				diagnostics = {
					enable = true,
				},
				actions = {
					open_file = {
						quit_on_open = false,
						resize_window = false,
						window_picker = {
							enable = true,
							chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
							exclude = {
								filetype = { "notify", "packer", "qf", "diff", "fugitive", "fugitiveblame" },
								buftype = { "nofile", "terminal", "help" },
							},
						},
					},
				},
				view = {
					width = 40,
					side = "right",
				},
				renderer = {
					indent_markers = {
						enable = false,
						icons = {
							corner = "└ ",
							edge = "│ ",
							none = "  ",
						},
					},
					add_trailing = true,
					root_folder_modifier = ":~",
					special_files = { "Cargo.toml", "Makefile", "README.md", "readme.md" },
					group_empty = true,
				},
				filters = {
					dotfiles = false,
					custom = { ".git", "node_modules", ".cache" },
				},
				git = {
					enable = true,
					ignore = true,
					timeout = 500,
				},
			})

			-- Keymaps
			vim.keymap.set("n", "<leader><Tab>", require("nvim-tree.api").tree.toggle, { desc = "Toggle file tree" })
			vim.keymap.set(
				"n",
				"<leader><S-Tab>",
				"<cmd>NvimTreeFindFileToggle<CR>",
				{ desc = "Toggle file tree and focus current file" }
			)
		end,
	},
}
