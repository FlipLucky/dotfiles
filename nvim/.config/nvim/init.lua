--------------------------------------------------------------
-- Globals --
--------------------------------------------------------------
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.clipboard:append({ "unnamed", "unnamedplus" })

vim.cmd("colorscheme retrobox")

-- set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

--------------------------------------------------------------
-- Options --
--------------------------------------------------------------

-- Relative and absolute line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Keep sign column on by default
vim.opt.signcolumn = "yes"
-- No swapfile
vim.opt.swapfile = false
-- Cursorline
vim.opt.cursorline = true

-- show whitespace characters
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Preview substitutions
vim.opt.inccommand = "split"

-- Text wrapping
vim.opt.wrap = true
vim.opt.breakindent = true

-- Tabstops
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4

-- Window splitting
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Save undo history
vim.opt.undofile = true

-- Set the default border for all floating windows
vim.opt.winborder = "rounded"

-- Virtual text for errors
vim.fn.sign_define("DiagnosticSignError", { text = "", texthl = "DiagnosticSignError" })
vim.fn.sign_define("DiagnosticSignWarn", { text = "", texthl = "DiagnosticSignWarn" })
vim.fn.sign_define("DiagnosticSignInfo", { text = "", texthl = "DiagnosticSignInfo" })
vim.fn.sign_define("DiagnosticSignHint", { text = "💡", texthl = "DiagnosticSignHint" })

vim.diagnostic.config({
	-- Show diagnostics as virtual text
	virtual_text = {
		spacing = 4, -- Add some space between the code and the text
		prefix = "●", -- Or use '»' or any other character
		severity_sort = true, -- Show highest severity diagnostic first
	},

	-- Show signs in the gutter
	signs = true,

	-- Underline the problematic code
	underline = true,

	-- Show diagnostic messages in a floating window when you hover
	update_in_insert = false,
	severity_sort = true,
})

-- Optional: Open a floating window with diagnostic details on hover
vim.o.updatetime = 250 -- Decrease update time
vim.cmd([[
  autocmd CursorHold * lua vim.diagnostic.open_float(nil, { focus = false })
]])

--------------------------------------------------------------
-- Keymap --
--------------------------------------------------------------

local opts = { noremap = true, silent = true, buffer = bufnr }
vim.keymap.set("n", "<leader>o", ":update<CR> :source<CR>")
vim.keymap.set("n", "<leader>lf", vim.lsp.buf.format)
vim.keymap.set("n", "<leader>k", vim.lsp.buf.hover, opts)
vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, opts)
vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
vim.keymap.set("n", "]q", "<cmd>cnext<CR>zz", { desc = "Next Quickfix Item" })
vim.keymap.set("n", "[q", "<cmd>cprevious<CR>zz", { desc = "Previous Quickfix Item" })
-- Paste from the 'yank' register (0)
vim.keymap.set({ "n", "v" }, "<leader>p", '"0p', { desc = "Paste from Yank Register" })
vim.keymap.set({ "n", "v" }, "<leader>P", '"0P', { desc = "Paste from Yank Register (before)" })
-- autosave format
vim.api.nvim_create_autocmd("BufWritePre", {
	group = vim.api.nvim_create_augroup("LspFormatting", { clear = true }),
	pattern = "*", -- or specific filetypes like { "*.lua", "*.rs" }
	callback = function(args)
		-- explicit bufnr usually safer in callbacks
		vim.lsp.buf.format({ bufnr = args.buf })
	end,
})
-- Set how many ms of inactivity triggers the CursorHold event
-- Default is 4000ms, which is too slow for autosave.
-- 1000ms is a safe sweet spot; 200ms is "aggressive".
vim.opt.updatetime = 1000

vim.api.nvim_create_autocmd({ "CursorHold", "FocusLost", "BufLeave" }, {
	group = vim.api.nvim_create_augroup("NativeAutoSave", { clear = true }),
	callback = function()
		-- Only save normal file buffers (ignore terminals, prompts, etc.)
		-- and only if they have changes.
		if vim.bo.buftype == "" and vim.bo.modified then
			vim.cmd("silent! update")

			-- Optional: visual feedback in command line
			-- vim.api.nvim_echo({ { "󰆓 Saved", "Normal" } }, false, {})
		end
	end,
})
--------------------------------------------------------------
-- Plugins --
--------------------------------------------------------------
---
vim.pack.add({
	{ src = "https://github.com/OXY2DEV/markview.nvim" },
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/stevearc/oil.nvim" },
	{ src = "https://github.com/stevearc/dressing.nvim" },
	{ src = "https://github.com/echasnovski/mini.pick" },
	{ src = "https://github.com/echasnovski/mini.pairs" },
	{ src = "https://github.com/echasnovski/mini.statusline" },
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/mason-org/mason.nvim" },
	{ src = "https://github.com/mason-org/mason-lspconfig.nvim" },
	{ src = "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim" },
	{
		src = "https://github.com/saghen/blink.cmp",
		branch = "v1.0.0",
		build = "cargo build --release",
	},
	{ src = "https://github.com/rafamadriz/friendly-snippets" },
	{ src = "https://github.com/nvim-flutter/flutter-tools.nvim" },
	{ src = "https://github.com/L3MON4D3/LuaSnip", branch = "master" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
	{ src = "https://github.com/ray-x/go.nvim" },
	{ src = "https://github.com/ray-x/guihua.lua" },
	{ src = "https://github.com/andymass/vim-matchup" },
	{ src = "https://github.com/ribru17/bamboo.nvim" },
	{ src = "https://github.com/nvim-neotest/nvim-nio" },
	{ src = "https://github.com/mfussenegger/nvim-dap" },
	{ src = "https://github.com/rcarriga/nvim-dap-ui" },
	{ src = "https://github.com/jay-babu/mason-nvim-dap.nvim" },

	{ src = "https://github.com/antoinemadec/FixCursorHold.nvim" },
	{ src = "https://github.com/nvim-neotest/neotest" },
	{ src = "https://github.com/nvim-neotest/nvim-nio" },
	{ src = "https://github.com/olimorris/neotest-phpunit" },
	{ src = "https://github.com/sidlatau/neotest-dart" },
	{ src = "https://github.com/fredrikaverpil/neotest-golang" },
	{ src = "https://github.com/nvim-tree/nvim-web-devicons" },
	{ src = "https://github.com/folke/trouble.nvim" },
	{ src = "https://github.com/Chaitanyabsprip/fastaction.nvim" },
	{ src = "https://github.com/oysandvik94/curl.nvim" },
	{ src = "https://github.com/toppair/peek.nvim" },
	{ src = "https://github.com/stevearc/conform.nvim" },
})

--------------------------------------------------------------
-- Plugin Setup --
--------------------------------------------------------------
-- flutter and go can be commented out, these are for my personal setup if you dont want to use them
require("markview").setup()
require("flutter-tools").setup({})
require("go").setup()
require("nvim-treesitter").setup()
require("match-up").setup({})
require("bamboo").load()
require("mason").setup()
require("mason-lspconfig").setup()
require("mini.statusline").setup({
	-- 'builtin' theme adapts to your color scheme automatically
	content = {
		-- Override content to keep it simple if desired
		active = nil,
		inactive = nil,
	},
	use_icons = true,
	set_vim_settings = false, -- We will set LastStatus manually if we want
})
local neotest = require("neotest")

neotest.setup({
	adapters = {
		require("neotest-phpunit")({
			-- Optional: Custom phpunit command or args
			filter_dirs = { "vendor" },
		}),
		require("neotest-dart")({
			command = "flutter test", -- or "dart test"
		}),
		require("neotest-golang"),
	},
	-- "Click to go to error" equivalent:
	output = {
		open_on_run = true,
	},
	status = { virtual_text = true },
	quickfix = {
		enabled = true, -- Auto-open QF list on failure if you prefer that over floating windows
	},
})

-- Keymaps (The workflow)
local map = vim.keymap.set
map("n", "<leader>tt", function()
	neotest.run.run()
end, { desc = "Run nearest test" })
map("n", "<leader>tf", function()
	neotest.run.run(vim.fn.expand("%"))
end, { desc = "Run current file" })
map("n", "<leader>ta", function()
	neotest.run.run("test")
end, { desc = "Run All Tests" })
map("n", "<leader>to", function()
	neotest.output.open({ enter = true })
end, { desc = "Show Output" })
map("n", "<leader>ts", function()
	neotest.summary.toggle()
end, { desc = "Toggle Summary Panel" })

require("peek").setup(opts)
vim.api.nvim_create_user_command("PeekOpen", require("peek").open, {})
vim.api.nvim_create_user_command("PeekClose", require("peek").close, {})
require("fastaction").setup(opts)
require("trouble").setup()
require("curl").setup()
-- vim.keymap.set(
-- 	{ "n", "x" },
-- 	"<leader>ca",
-- 	'<cmd>lua require("fastaction").code_action()<CR>',
-- 	{ desc = "Display code actions", buffer = bufnr }
-- )
-- open trouble window
vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", {})
-- Jump to next/previous trouble item
vim.keymap.set("n", "]t", function()
	require("trouble").next({ jump = true })
end, { silent = true, noremap = true, desc = "Next trouble item" })
vim.keymap.set("n", "[t", function()
	require("trouble").previous({ jump = true })
end, { silent = true, noremap = true, desc = "Previous trouble item" })
-- Run file
vim.keymap.set("n", "<leader>tf", function()
	require("neotest").run.run(vim.fn.expand("%"))
end, { desc = "[T]est [F]ile" })
-- Run nearest
vim.keymap.set("n", "<leader>tn", function()
	require("neotest").run.run()
end, { desc = "[T]est [N]earest" })
-- Show summary window
vim.keymap.set("n", "<leader>ts", function()
	require("neotest").summary.toggle()
end, { desc = "[T]est [S]ummary" })
-- Stop nearest
vim.keymap.set("n", "<leader>tx", function()
	require("neotest").run.stop()
end, { desc = "[T]est stop [X]" })

-- In your on_attach function (recommended)
local bufopts = { noremap = true, silent = true, buffer = bufnr }
vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, bufopts)

-- Or as a global fallback
vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "LSP Code Action" })

local conform = require("conform")

conform.setup({
	-- Map filetypes to formatters
	formatters_by_ft = {
		php = { "phpcbf" },
		-- You can add others here
		-- lua = { "stylua" },
		-- javascript = { "prettier" },
	},

	-- Custom config for phpcbf to prioritize local vendor/bin
	formatters = {
		phpcbf = {
			-- This utility finds the executable in the project root first, then fallback to global
			command = require("conform.util").find_executable({
				"vendor/bin/phpcbf",
				"phpcbf",
			}),
		},
	},

	-- Optional: Set default options for formatting
	default_format_opts = {
		lsp_format = "fallback", -- Use LSP if no formatter is defined above
	},
})

-- 3. Replace your keymap
vim.keymap.set("n", "<leader>cf", function()
	conform.format({ async = true })
end, { desc = "Format buffer" })

local dap_adapters = {
	"delve",
	"php-debug-adapter",
	"dart-debug-adapter",
}

local lsps_and_linters = {
	"lua_ls",
	"stylua",
	"phpactor",
	"ts_ls",
	"emmet_ls",
}

local tools_to_install = {}
vim.list_extend(tools_to_install, lsps_and_linters)
vim.list_extend(tools_to_install, dap_adapters)
require("mason-tool-installer").setup({
	ensure_installed = tools_to_install,
})
require("blink.cmp").setup({
	keymap = { preset = "super-tab" },
	appearance = { nerd_font_variant = "mono" },
	signature = { enabled = true },
	snippets = {
		preset = "luasnip",
	},
})
vim.cmd("set completeopt+=noselect")

vim.lsp.enable(lsps_and_linters)

vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true),
			},
		},
	},
})

vim.lsp.config("ts_ls", {})

vim.lsp.config("emmet_ls", {
	filetypes = {
		"html",
		"css",
		"scss",
		"less",
		"typescriptreact", --SolidJS TSX
		"javascriptreact", --SolidJS JSX
		"twig",
	},
	settings = {
		emmet = {
			jsx = {
				options = {
					["markup.attributes"] = {
						["class"] = "class",
						["class*"] = "styleName",
						["for"] = "for",
					},
				},
				syntaxProfiles = {
					typescriptreact = "html",
					javascriptreact = "html",
				},
			},
		},
	},
})

vim.lsp.config("phpactor", {})

require("mini.pick").setup()
require("mini.pairs").setup()
require("oil").setup()

vim.keymap.set("n", "<leader>ff", ":Pick files<CR>")
vim.keymap.set("n", "<leader>fh", ":Pick help<CR>")
vim.keymap.set("n", "<leader>ft", ":Pick grep<CR>")
vim.keymap.set("n", "<leader>fb", ":Pick buffers <CR>")
vim.keymap.set("n", "<leader>e", ":Oil<CR>")
vim.keymap.set("n", "<leader>o", ":update<CR> :source<CR>")
-- ===============================================================
-- DAP Setup (for nvim 0.12+)
-- ===============================================================

-- Bridge Mason and nvim-dap
require("mason-nvim-dap").setup({
	ensure_installed = dap_adapters,
	automatic_installation = true,
	handlers = {},
})

--
local dap = require("dap")
local dapui = require("dapui")

-- Setup the DAP UI
dapui.setup()

-- Add listeners to open/close the UI automatically
dap.listeners.after.event_initialized["dapui_config"] = function()
	dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
	dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
	dapui.close()
end
--
vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "DAP: Toggle Breakpoint" })
vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "DAP: Continue" })
vim.keymap.set("n", "<leader>do", dap.step_over, { desc = "DAP: Step Over" })
vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "DAP: Step Into" })
vim.keymap.set("n", "<leader>du", dap.step_out, { desc = "DAP: Step Out" })
vim.keymap.set("n", "<leader>dr", dap.repl.open, { desc = "DAP: Open REPL" })
vim.keymap.set("n", "<leader>dt", dap.terminate, { desc = "DAP: Terminate Session" })
vim.keymap.set("n", "<leader>dl", function()
	dapui.toggle()
end, { desc = "DAP: Toggle UI" })
