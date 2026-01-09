-- AI Assistant
-- Claude Code integration for AI-powered coding assistance

return {
	{
		"coder/claudecode.nvim",
		dependencies = {
			"folke/snacks.nvim",
		},
		opts = {
			-- Terminal configuration
			terminal = {
				split_side = "right", -- Open on the right side
				split_width_percentage = 0.50, -- 50% of screen width
				provider = "auto", -- Auto-detect best terminal provider
				auto_close = true, -- Close terminal when Claude exits
			},

			-- Diff window configuration
			diff = {
				auto_close_on_accept = true, -- Close diff after accepting changes
				vertical_split = true, -- Use vertical split for diffs
				open_in_current_tab = true, -- Diffs open in remaining 30% space
				keep_terminal_focus = false, -- Focus goes to diff window
			},

			-- Server settings
			port_range = { min = 10000, max = 65535 },
			auto_start = true,
			log_level = "info",
		},
		config = function(_, opts)
			require("claudecode").setup(opts)

			-- Hook into terminal functions to auto-open/close dashboard
			local terminal = require("claudecode.terminal")
			local original_open = terminal.open
			local original_close = terminal.close
			local original_toggle = terminal.toggle

			terminal.open = function(...)
				local result = original_open(...)
				vim.schedule(function()
					vim.cmd("ClaudeDashboardOpen")
				end)
				return result
			end

			terminal.close = function(...)
				vim.schedule(function()
					vim.cmd("ClaudeDashboardClose")
				end)
				return original_close(...)
			end

			terminal.toggle = function(...)
				local bufnr = terminal.get_active_terminal_bufnr()
				local was_visible = false
				if bufnr then
					local info = vim.fn.getbufinfo(bufnr)
					was_visible = info and #info > 0 and #info[1].windows > 0
				end

				local result = original_toggle(...)

				vim.schedule(function()
					if was_visible then
						vim.cmd("ClaudeDashboardClose")
					else
						vim.cmd("ClaudeDashboardOpen")
					end
				end)
				return result
			end
		end,
		keys = {
			-- Main commands
			{ "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude Code" },
			{ "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude Code window" },
			{ "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume previous session" },
			{ "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue last conversation" },

			-- Model and context management
			{ "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
			{ "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer to context" },

			-- Send selection to Claude
			{ "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send selection to Claude" },

			-- Diff management
			{ "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept Claude's changes" },
			{ "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Reject Claude's changes" },
		},
	},

	-- Claude Dashboard - shows todos and tool processes
	{
		"thassiov/claude-dashboard.nvim",
		dependencies = { "coder/claudecode.nvim" },
		opts = {
			width = 0.5, -- Half of Claude terminal window
			panels = {
				todos = { enabled = true, height = 0.5 },
				processes = { enabled = true, height = 0.5, limit = 10 },
			},
		},
		keys = {
			{ "<leader>aD", "<cmd>ClaudeDashboard<cr>", desc = "Toggle Claude Dashboard" },
		},
	},
}
