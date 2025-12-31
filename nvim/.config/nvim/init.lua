--------------------------------------------------------------
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
opt.clipboard:append({ "unnamed", "unnamedplus" })

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
})

--------------------------------------------------------------
-- 4. Plugin Configurations
--------------------------------------------------------------
require("markview").setup()
require("nvim-treesitter").setup()
require("match-up").setup({})
require("bamboo").load()
require("mini.pairs").setup()
require("mini.ai").setup()
require("mini.indentscope").setup()
require("oil").setup()
require("peek").setup()
require("fastaction").setup({})
require("trouble").setup()
require("curl").setup()
require("mini.statusline").setup({ use_icons = true, set_vim_settings = false })
require("neogit").setup({})

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
	formatters_by_ft = { php = { "phpcbf" } },
	formatters = {
		phpcbf = {
			command = function()
				return require("conform.util").find_executable({ "vendor/bin/phpcbf", "phpcbf" }, "phpcbf")
			end,
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
		require("neotest-golang"),
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
require("go").setup({ lsp_cfg = { capabilities = caps } })
require("flutter-tools").setup({
	lsp = {
		capabilities = caps,
		color_render = true,
		settings = { showTodos = true, completeFunctionCalls = true },
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
map("n", "<leader>o", ":update<CR>:source<CR>", { desc = "Reload Config" })
map("n", "<leader>e", ":Oil<CR>", { desc = "Oil" })
map({ "n", "v" }, "<leader>p", '"0p', { desc = "Paste from Yank" })

-- LSP & Formatting
map("n", "<leader>lf", vim.lsp.buf.format)
map("n", "<leader>k", vim.lsp.buf.hover)
map("n", "gd", vim.lsp.buf.definition)
map("n", "gD", vim.lsp.buf.declaration)
map("n", "gr", vim.lsp.buf.references)
map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action)
map("n", "<leader>cf", function()
	conform.format({ async = true })
end)

-- Navigation (Quickfix & Trouble)
map("n", "]q", "<cmd>cnext<CR>zz")
map("n", "[q", "<cmd>cprevious<CR>zz")
map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>")
map("n", "]t", function()
	require("trouble").next({ jump = true })
end)
map("n", "[t", function()
	require("trouble").previous({ jump = true })
end)

-- Mini.Pick
require("mini.pick").setup()
map("n", "<leader>ff", ":Pick files<CR>")
map("n", "<leader>ft", ":Pick grep<CR>")
map("n", "<leader>fb", ":Pick buffers<CR>")
map("n", "<leader>fh", ":Pick help<CR>")

-- Neotest
map("n", "<leader>tt", function()
	neotest.run.run()
end)
map("n", "<leader>tf", function()
	neotest.run.run(vim.fn.expand("%"))
end)
map("n", "<leader>ta", function()
	neotest.run.run("test")
end)
map("n", "<leader>ts", function()
	neotest.summary.toggle()
end)
map("n", "<leader>to", function()
	neotest.output.open({ enter = true })
end)

-- DAP
map("n", "<leader>db", dap.toggle_breakpoint)
map("n", "<leader>dc", dap.continue)
map("n", "<leader>dt", dap.terminate)
map("n", "<leader>dl", function()
	dapui.toggle()
end)
-- NeoGit
vim.keymap.set("n", "<leader>ng", "<cmd>Neogit<cr>", { desc = "Open Neogit UI" })
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
		vim.lsp.buf.format({ bufnr = args.buf })
	end,
})
