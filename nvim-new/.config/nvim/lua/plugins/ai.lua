-- AI Assistant
-- Claude Code integration for AI-powered coding assistance

return {
	{
		"coder/claudecode.nvim",
		dependencies = {
			"folke/snacks.nvim",
		},
		config = true,
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
				keep_terminal_focus = true, -- Focus goes to diff window
			},

			-- Server settings
			port_range = { min = 10000, max = 65535 },
			auto_start = true,
			log_level = "info",
		},
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
}
