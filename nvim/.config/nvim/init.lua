--------------------------------------------------------------
---
-- 1. Globals & Options
--------------------------------------------------------------
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true

local opt = vim.opt
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.smoothscroll = true
opt.swapfile = false
opt.undofile = true
opt.updatetime = 1000
opt.ignorecase = true
opt.smartcase = true
opt.expandtab = true
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
opt.inccommand = "split"
opt.wrap = true
opt.breakindent = true
opt.splitright = true
opt.splitbelow = true
opt.winborder = "rounded"
vim.opt.conceallevel = 2
vim.opt.concealcursor = "nc"
-- vim.g.clipboard = {
-- 	name = "wl-copy",
-- 	copy = { ["+"] = "wl-copy", ["*"] = "wl-copy" },
-- 	paste = { ["+"] = "wl-paste", ["*"] = "wl-paste" },
-- 	cache_enabled = 0,
-- }
opt.clipboard = "unnamedplus"

vim.opt.spell = true
vim.opt.spelllang = { "en_us", "nl" }
--------------------------------------------------------------
-- 2. UI, Colors & Diagnostics
--------------------------------------------------------------
vim.cmd("colorscheme retrobox")

vim.fn.sign_define("DiagnosticSignError", { text = "", texthl = "DiagnosticSignError" })
vim.fn.sign_define("DiagnosticSignWarn", { text = "", texthl = "DiagnosticSignWarn" })
vim.fn.sign_define("DiagnosticSignInfo", { text = "", texthl = "DiagnosticSignInfo" })
vim.fn.sign_define("DiagnosticSignHint", { text = "💡", texthl = "DiagnosticSignHint" })

vim.diagnostic.config({
	virtual_text = { spacing = 4, prefix = "●", severity_sort = true },
	signs = true,
	underline = true,
	update_in_insert = false,
	severity_sort = true,
})

vim.api.nvim_create_autocmd("CursorHold", {
	callback = function()
		vim.diagnostic.open_float(nil, { focus = false })
	end,
})

--------------------------------------------------------------
-- 3. Package Management (0.12 Native)
--------------------------------------------------------------
vim.pack.add({
	{ src = "https://github.com/OXY2DEV/markview.nvim" },
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/stevearc/oil.nvim" },
	{ src = "https://github.com/stevearc/dressing.nvim" },
	{ src = "https://github.com/echasnovski/mini.pick" },
	{ src = "https://github.com/echasnovski/mini.pairs" },
	{ src = "https://github.com/echasnovski/mini.statusline" },
	{ src = "https://github.com/echasnovski/mini.ai" },
	{ src = "https://github.com/echasnovski/mini.snippets" },
	{ src = "https://github.com/echasnovski/mini.animate" },
	{ src = "https://github.com/echasnovski/mini.indentscope" },
	{ src = "https://github.com/echasnovski/mini.surround" },
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
	{
		src = "https://github.com/L3MON4D3/LuaSnip",
		branch = "master",
	},
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
	{ src = "https://github.com/olimorris/neotest-phpunit" },
	{ src = "https://github.com/sidlatau/neotest-dart" },
	{ src = "https://github.com/fredrikaverpil/neotest-golang" },
	{ src = "https://github.com/nvim-tree/nvim-web-devicons" },
	{ src = "https://github.com/folke/trouble.nvim" },
	{ src = "https://github.com/Chaitanyabsprip/fastaction.nvim" },
	{ src = "https://github.com/oysandvik94/curl.nvim" },
	{ src = "https://github.com/toppair/peek.nvim" },
	{ src = "https://github.com/stevearc/conform.nvim" },
	{ src = "https://github.com/NeogitOrg/neogit" },
	{ src = "https://github.com/folke/which-key.nvim" },
	{ src = "https://github.com/folke/snacks.nvim" },
	{ src = "https://github.com/A7Lavinraj/fyler.nvim.git" },
	{ src = "https://github.com/nvim-orgmode/orgmode" },

	-- Keymaps
})

--------------------------------------------------------------
-- 4. Plugin Configurations
--------------------------------------------------------------
require("markview").setup()
require("nvim-treesitter.configs").setup({
	ensure_installed = {
		"lua",
		"dart",
		"vim",
		"go",
		"php",
	},
	indent = {
		enable = true,
	},
})
require("bamboo").load()
require("mini.pairs").setup()
local ai = require("mini.ai")
ai.setup({
	n_lines = 500,
	custom_textobjects = {
		-- Key: 'F' for Function Definition
		-- Value: The TreeSitter spec
		F = ai.gen_spec.treesitter({
			a = "@function.outer", -- 'a'round: the whole function + 'end'
			i = "@function.inner", -- 'i'nside: just the body
		}),

		-- Optional: You can also enhance 'o' for Class/Object definitions
		o = ai.gen_spec.treesitter({
			a = "@class.outer",
			i = "@class.inner",
		}),
	},
})
require("mini.indentscope").setup()
require("mini.surround").setup({
	-- Defaults are clean, but note the deviation from 'vim-surround':
	-- Add: sa (Surround Add)
	-- Delete: sd (Surround Delete)
	-- Replace: sr (Surround Replace)
	mappings = {
		add = "sa", -- Add surrounding in Normal and Visual modes
		delete = "sd", -- Delete surrounding
		find = "sf", -- Find surrounding (to the right)
		find_left = "sF", -- Find surrounding (to the left)
		highlight = "sh", -- Highlight surrounding
		replace = "sr", -- Replace surrounding
		update_n_lines = "sn", -- Update `n_lines`
	},
})

require("snacks").setup({
	scratch = { enabled = true },
	-- other modules...
})
require("oil").setup()
local fyler = require("fyler")
fyler.setup({})

-- Open as an overview tree on the left side
vim.keymap.set("n", "<leader>pv", function()
	fyler.open({ kind = "split_left_most" })
end, { desc = "Open Fyler Tree View" })

-- Open as a quick floating window centered over your workspace
vim.keymap.set("n", "<leader>pf", function()
	fyler.open({ kind = "float" })
end, { desc = "Open Fyler Float" })

-- org mode
require("orgmode").setup({
	-- Centralized Org files directory structure
	org_agenda_files = { "~/orgmode/**/*" },
	org_default_notes_file = "~/orgmode/refile.org",

	-- Custom state transitions and access mappings
	org_todo_keywords = { "TODO(t)", "NEXT(n)", "WAITING(w)", "|", "DONE(d)" },

	-- Custom visual styling for task keywords
	org_todo_keyword_faces = {
		TODO = ":foreground #FF5555 :weight bold",
		NEXT = ":foreground #FFB86C :weight bold",
		WAITING = ":foreground #8BE9FD :slant italic",
		DONE = ":foreground #50FA7B :weight bold :underline on",
	},

	-- Structural property logging configurations
	org_log_into_drawer = "LOGBOOK",
	org_log_done = "time", -- Logs a CLOSED timestamp when marked DONE
	org_log_repeat = "time", -- Logs repetition metadata

	-- User interface and split-pane configurations
	win_split_mode = "horizontal", -- Split behavior for capture and agenda windows
	org_startup_folded = "overview", -- Default folding level on boot

	-- Tailored Capture Templates for the daily workflows
	org_capture_templates = {
		t = {
			description = "Work Ticket Task",
			template = "* TODO Task: %?\n  %U\n  TICKET: ",
			target = "~/orgmode/projects.org",
		},
		m = {
			description = "Meeting Notes",
			template = "* Meeting: %?\n  Captured on: %U\n  :PROPERTIES:\n  :CATEGORY: meetings\n  :END:\n  ** Agenda\n  ** Discussion Notes\n  ** Action Items [/]\n     - [ ] ",
			target = "~/orgmode/meetings.org",
		},
		h = {
			description = "Recurring Habit",
			template = "* TODO %?\n  SCHEDULED: %t\n  :PROPERTIES:\n  :CATEGORY: habits\n  :END:",
			target = "~/orgmode/habits.org",
		},
		i = {
			description = "Unstructured Idea",
			template = "* %?\n  Captured on: %u",
			target = "~/orgmode/ideas.org",
		},
		c = {
			description = "Colleague Interruption Task",
			template = "* TODO Help Colleague: %? :INTERRUPTION:\n  %U\n  TICKET: ",
			target = "~/orgmode/projects.org",
		},
	},
})
-- Experimental LSP support
vim.lsp.enable("org")

require("peek").setup()
require("fastaction").setup({})
require("trouble").setup()
require("curl").setup()
require("mini.statusline").setup({ use_icons = true, set_vim_settings = false })
require("neogit").setup({})
local wk = require("which-key")
wk.setup({})
-- Replace the wk.add block in Section 4
wk.add({
	{ "[", group = "Previous" },
	{ "]", group = "Next" },
	{ "g", group = "Go / LSP" },
	{ "<leader>c", group = "Code" },
	{ "<leader>d", group = "Debug" },
	{ "<leader>f", group = "Find (Pick)" },
	{ "<leader>l", group = "LSP" },
	{ "<leader>t", group = "Test" },
	{ "<leader>x", group = "Trouble" },
})
-- Mini Animate (Stutter Fix)
local animate = require("mini.animate")
animate.setup({
	scroll = {
		enable = true,
		timing = animate.gen_timing.linear({ duration = 250, unit = "total" }),
		subscroll = animate.gen_subscroll.equal({
			predicate = function(total_scroll)
				return total_scroll > 2
			end,
		}),
	},
	cursor = { enable = true },
})
-- Mini Snippets
local gen_loader = require("mini.snippets").gen_loader
require("mini.snippets").setup({
	snippets = {
		-- Load custom file with global snippets first (adjust for Windows)
		gen_loader.from_file("~/.config/nvim/snippets/global.lua"),

		-- Load snippets based on current language by reading files from
		-- "snippets/" subdirectories from 'runtimepath' directories.
		gen_loader.from_lang(),
	},
})
-- Conform (Formatting Fix)
local conform = require("conform")
conform.setup({
	formatters_by_ft = {
		php = { "phpcbf" },
		javascript = { "prettier" },
		typescript = { "prettier" },
	},
	formatters = {
		phpcbf = {
			command = "phpcbf",
		},
	},
	default_format_opts = { lsp_format = "fallback" },
})

-- Neotest
local neotest = require("neotest")
neotest.setup({
	adapters = {
		require("neotest-phpunit")({ filter_dirs = { "vendor" } }),
		require("neotest-dart")({ command = "flutter test" }),
		require("neotest-golang")({
			go_test_args = { "-v", "-count=1" }, -- Remove "-race" if you don't want to force CGO
			-- OR
			env = { CGO_ENABLED = "1" },
		}),
	},
	output = { open_on_run = true },
	status = { virtual_text = true },
	quickfix = { enabled = true },
})

--------------------------------------------------------------
-- 5. Completion (Blink.cmp) & LSP
--------------------------------------------------------------
local blink = require("blink.cmp")
blink.setup({
	keymap = { preset = "super-tab" },
	appearance = { nerd_font_variant = "mono" },
	signature = { enabled = true },
	snippets = { preset = "mini_snippets" },
	sources = {
		default = { "lsp", "path", "snippets", "buffer" },
		per_filetype = {
			go = { "lsp", "path", "snippets" },
			org = { "orgmode" }, -- Cleanly isolated filetype source
		},
		providers = {
			orgmode = {
				name = "Orgmode",
				module = "orgmode.org.autocompletion.blink",
				fallbacks = { "buffer" }, -- Fixed typo: 'fallbakcs' -> 'fallbacks'
			},
		},
	},
	completion = {
		documentation = { auto_show = true, auto_show_delay_ms = 500 },
		list = { selection = { preselect = false, auto_insert = true } },
	},
})

vim.cmd("set completeopt+=noselect")

-- LSP Config
local caps = blink.get_lsp_capabilities()
local lsps = { "lua_ls", "ts_ls", "emmet_ls", "phpactor", "gopls" }
local dap_adapters = { "delve", "php-debug-adapter", "dart-debug-adapter" }

require("mason").setup()
require("mason-lspconfig").setup()
require("mason-tool-installer").setup({
	ensure_installed = vim.list_extend(vim.list_extend({}, lsps), dap_adapters),
})

-- 0.12+ Native LSP Enablement with Blink Capabilities
vim.lsp.enable(lsps)

vim.lsp.config("lua_ls", {
	capabilities = caps,
	settings = { Lua = { workspace = { library = vim.api.nvim_get_runtime_file("", true) } } },
})

vim.lsp.config("gopls", {
	capabilities = caps,
	settings = {
		gopls = {
			usePlaceholders = true,
			completeUnimported = true,
			experimentalPostfixCompletions = true, -- Senior Go optimization
		},
	},
})

vim.lsp.config("phpactor", { capabilities = caps })
vim.lsp.config("ts_ls", { capabilities = caps })
vim.lsp.config("emmet_ls", {
	capabilities = caps,
	filetypes = { "html", "css", "scss", "less", "typescriptreact", "javascriptreact", "twig" },
})

-- Language Specific Tools
require("go").setup({ lsp_cfg = { capabilities = caps }, lsp_keymaps = false })
require("flutter-tools").setup({
	lsp = {
		capabilities = caps,
		color_render = true,
		settings = { showTodos = true, completeFunctionCalls = true },
	},
	-- Add this block:
	debugger = {
		enabled = true,
		run_via_dap = true,
	},
	dev_log = {
		enabled = false, -- Optional: hides the noisy default log split
	},
})

--------------------------------------------------------------
-- 6. Debugging (DAP)
--------------------------------------------------------------
local dap, dapui = require("dap"), require("dapui")
require("mason-nvim-dap").setup({
	ensure_installed = dap_adapters,
	automatic_installation = true,
})

dapui.setup()
dap.listeners.after.event_initialized["dapui_config"] = function()
	dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
	dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
	dapui.close()
end

--------------------------------------------------------------
-- 7. Keymaps
--------------------------------------------------------------
local map = vim.keymap.set

-- Config & File
-- map("n", "<leader>o", ":update<CR>:source<CR>", { desc = "Reload Config" })
map("n", "<leader>e", ":Oil<CR>", { desc = "Explorer (Oil)" })
map({ "n", "v" }, "<leader>p", '"0p', { desc = "Paste (No yank)" })

-- LSP & Formatting
map("n", "<leader>lf", vim.lsp.buf.format, { desc = "Format (LSP)" })
map("n", "<leader>k", vim.lsp.buf.hover, { desc = "Hover Documentation" })
map("n", "gd", vim.lsp.buf.definition, { desc = "Go to Definition" })
map("n", "gD", vim.lsp.buf.declaration, { desc = "Go to Declaration" })
map("n", "gr", vim.lsp.buf.references, { desc = "Go to References" })
map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })
map("n", "<leader>cf", function()
	conform.format({ async = true })
end, { desc = "Format (Conform)" })

-- Navigation (Quickfix & Trouble)
map("n", "]q", "<cmd>cnext<CR>zz", { desc = "Next QF Item" })
map("n", "[q", "<cmd>cprevious<CR>zz", { desc = "Prev QF Item" })
map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Toggle Trouble" })
map("n", "]t", function()
	require("trouble").next({ jump = true })
end, { desc = "Next Trouble" })
map("n", "[t", function()
	require("trouble").previous({ jump = true })
end, { desc = "Prev Trouble" })

-- Snacks
vim.keymap.set("n", "<leader>np", function()
	Snacks.scratch()
end, { desc = "Toggle Scratchpad" })
vim.keymap.set("n", "<leader>N", function()
	Snacks.scratch.select()
end, { desc = "Select Scratch History" })

-- Mini.Pick
require("mini.pick").setup()
map("n", "<leader>ff", ":Pick files<CR>", { desc = "Find Files" })
map("n", "<leader>ft", ":Pick grep<CR>", { desc = "Find Text (Grep)" })
map("n", "<leader>fb", ":Pick buffers<CR>", { desc = "Find Buffers" })
map("n", "<leader>fh", ":Pick help<CR>", { desc = "Find Help Tags" })

map("n", "<leader>fk", function()
	local function get_map_source(sid)
		if sid == 0 then
			return "Global"
		end
		local info = vim.fn.getscriptinfo({ sid = sid })[1]
		if not info then
			return "Unknown"
		end
		local path = info.name

		-- Fix: Check for plugin path first
		local plugin = path:match("pack/[^/]+/[^/]+/([^/]+)")
		if plugin then
			return plugin:gsub("%.nvim$", "")
		end

		if path:match("nvim/init%.lua") then
			return "Config"
		end
		return path:match("([^/]+)%.lua$") or "Runtime"
	end

	local items = {}
	local keys = vim.api.nvim_get_keymap("n")
	vim.list_extend(keys, vim.api.nvim_buf_get_keymap(0, "n"))

	for _, key in ipairs(keys) do
		local lhs = key.lhs
		-- Clean up noise
		if not lhs:match("^<Plug>") and not lhs:match("^<SNR>") then
			local source = get_map_source(key.script or 0)
			local desc = key.desc

			-- Fallback for no description
			if not desc or desc == "" then
				desc = (type(key.rhs) == "string" and key.rhs) or "<Lua Callback>"
				desc = desc:gsub("\r", ""):gsub("\n", "")
			end

			table.insert(items, string.format("%-12s │ %-15s │ %s", lhs, source, desc))
		end
	end

	require("mini.pick").start({
		source = { items = items, name = "Active Keymaps" },
		window = { config = { width = 100 } },
	})
end, { desc = "Find All Keymaps" })
-- Neotest
map("n", "<leader>tt", function()
	neotest.run.run()
end, { desc = "Run Nearest Test" })
map("n", "<leader>tf", function()
	neotest.run.run(vim.fn.expand("%"))
end, { desc = "Run File" })
map("n", "<leader>ta", function()
	neotest.run.run("test")
end, { desc = "Run Suite" })
map("n", "<leader>ts", function()
	neotest.summary.toggle()
end, { desc = "Toggle Summary" })
map("n", "<leader>to", function()
	neotest.output.open({ enter = true })
end, { desc = "Show Output" })

-- DAP
map("n", "<leader>db", dap.toggle_breakpoint, { desc = "Toggle Breakpoint" })
map("n", "<leader>dc", dap.continue, { desc = "Continue / Start" })
map("n", "<leader>dt", dap.terminate, { desc = "Terminate" })
map("n", "<leader>dl", function()
	dapui.toggle()
end, { desc = "Toggle UI" })

-- NeoGit
vim.keymap.set("n", "<leader>ng", "<cmd>Neogit<cr>", { desc = "Open Neogit" })
--------------------------------------------------------------
-- 8. Autocmds
--------------------------------------------------------------
local augroup = vim.api.nvim_create_augroup

-- Native AutoSave logic
vim.api.nvim_create_autocmd({ "CursorHold", "FocusLost", "BufLeave" }, {
	group = augroup("NativeAutoSave", { clear = true }),
	callback = function()
		if vim.bo.buftype == "" and vim.bo.modified then
			vim.cmd("silent! update")
		end
	end,
})

-- Auto Format on Save
vim.api.nvim_create_autocmd("BufWritePre", {
	group = augroup("LspFormatting", { clear = true }),
	callback = function(args)
		require("conform").format({
			bufnr = args.buf,
			lsp_fallback = true,
			async = false,
		})
	end,
})
