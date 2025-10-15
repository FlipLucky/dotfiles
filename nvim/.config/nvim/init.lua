--------------------------------------------------------------
-- Globals --
--------------------------------------------------------------
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.opt.clipboard:append { 'unnamed', 'unnamedplus' }

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
vim.opt.signcolumn = 'yes'
-- No swapfile
vim.opt.swapfile = false
-- Cursorline
vim.opt.cursorline = true

-- show whitespace characters
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Preview substitutions
vim.opt.inccommand = 'split'

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
vim.opt.winborder = 'rounded'

-- Virtual text for errors
vim.fn.sign_define('DiagnosticSignError', { text = '', texthl = 'DiagnosticSignError' })
vim.fn.sign_define('DiagnosticSignWarn', { text = '', texthl = 'DiagnosticSignWarn' })
vim.fn.sign_define('DiagnosticSignInfo', { text = '', texthl = 'DiagnosticSignInfo' })
vim.fn.sign_define('DiagnosticSignHint', { text = '💡', texthl = 'DiagnosticSignHint' })

vim.diagnostic.config({
    -- Show diagnostics as virtual text
    virtual_text = {
        spacing = 4, -- Add some space between the code and the text
        prefix = '●', -- Or use '»' or any other character
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

local opts = { noremap = true, silent = true, buffer = bufnr, }
vim.keymap.set('n', '<leader>o', ':update<CR> :source<CR>')
vim.keymap.set('n', '<leader>lf', vim.lsp.buf.format)
vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
vim.keymap.set('n', '<leader>k', vim.lsp.buf.hover, opts)
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, opts)
vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)

--------------------------------------------------------------
-- Plugins --
--------------------------------------------------------------
---
vim.pack.add({
    { src = 'https://github.com/OXY2DEV/markview.nvim' },
    { src = 'https://github.com/nvim-lua/plenary.nvim' },
    { src = 'https://github.com/stevearc/oil.nvim' },
    { src = 'https://github.com/stevearc/dressing.nvim' },
    { src = 'https://github.com/echasnovski/mini.pick' },
    { src = 'https://github.com/echasnovski/mini.pairs' },
    { src = 'https://github.com/neovim/nvim-lspconfig' },
    { src = 'https://github.com/mason-org/mason.nvim' },
    { src = 'https://github.com/mason-org/mason-lspconfig.nvim' },
    { src = 'https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim' },
    {
        src = 'https://github.com/saghen/blink.cmp',
        branch = 'v1.0.0',
        build = 'cargo build --release'
    },
    { src = 'https://github.com/rafamadriz/friendly-snippets' },
    { src = 'https://github.com/nvim-flutter/flutter-tools.nvim' },
    { src = 'https://github.com/nvim-treesitter/nvim-treesitter' },
    { src = 'https://github.com/ray-x/go.nvim' },
    { src = 'https://github.com/ray-x/guihua.lua' },
    { src = 'https://github.com/andymass/vim-matchup' },
    { src = 'https://github.com/ribru17/bamboo.nvim' },
    { src = 'https://github.com/nvim-neotest/nvim-nio' },
    { src = 'https://github.com/mfussenegger/nvim-dap' },
    { src = 'https://github.com/rcarriga/nvim-dap-ui' },
    { src = 'https://github.com/jay-babu/mason-nvim-dap.nvim' },

    { src = 'https://github.com/antoinemadec/FixCursorHold.nvim' },
    { src = 'https://github.com/nvim-neotest/neotest' },
    { src = 'https://github.com/nvim-neotest/nvim-nio' },
    { src = 'https://github.com/olimorris/neotest-phpunit' },

})

--------------------------------------------------------------
-- Plugin Setup --
--------------------------------------------------------------
-- flutter and go can be commented out, these are for my personal setup if you dont want to use them
require("markview").setup()
require('flutter-tools').setup()
require('go').setup()
require('nvim-treesitter').setup()
require('match-up').setup({})
require('bamboo').load()
require('mason').setup()
require('mason-lspconfig').setup()
require('neotest').setup({
    phpunit_cmd = function()
        return 'vendor/bin/phpunit'
    end
})

-- Run file
vim.keymap.set('n', '<leader>tf', function() require('neotest').run.run(vim.fn.expand('%')) end,
    { desc = '[T]est [F]ile' })
-- Run nearest
vim.keymap.set('n', '<leader>tn', function() require('neotest').run.run() end, { desc = '[T]est [N]earest' })
-- Show summary window
vim.keymap.set('n', '<leader>ts', function() require('neotest').summary.toggle() end, { desc = '[T]est [S]ummary' })
-- Stop nearest
vim.keymap.set('n', '<leader>tx', function() require('neotest').run.stop() end, { desc = '[T]est stop [X]' })
local lsps_and_linters = {
    "lua_ls",
    "stylua",
    "phpactor",
}

local dap_adapters = {
    "delve",
    "php-debug-adapter",
    "dart-debug-adapter",
}

local tools_to_install = {}
vim.list_extend(tools_to_install, lsps_and_linters)
vim.list_extend(tools_to_install, dap_adapters)
require('mason-tool-installer').setup({
    ensure_installed = tools_to_install
})
require('blink.cmp').setup({
    keymap = { preset = 'super-tab' },
    appearance = { nerd_font_variant = 'mono' },
    signature = { enabled = true }
})


-- vim.api.nvim_create_autocmd("LspAttach", {
--     callback = function(ev)
--         local client = vim.lsp.get_client_by_id(ev.data.client_id)
--         if client:supports_method("textDocument.completion") then
--             vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
--         end
--     end
--
-- })

vim.cmd("set completeopt+=noselect")


require "mini.pick".setup()
require "mini.pairs".setup()
require "oil".setup()

vim.keymap.set('n', '<leader>ff', ":Pick files<CR>")
vim.keymap.set('n', '<leader>fh', ":Pick help<CR>")
vim.keymap.set('n', '<leader>ft', ":Pick grep<CR>")
vim.keymap.set('n', '<leader>fb', ":Pick buffers <CR>")
vim.keymap.set('n', '<leader>e', ":Oil<CR>")
vim.keymap.set('n', '<leader>o', ':update<CR> :source<CR>')


vim.lsp.enable({ "lua_ls", "phpactor" })

vim.lsp.config(
    "lua_ls", {
        settings = {
            Lua = {
                workspace = {
                    library = vim.api.nvim_get_runtime_file("", true),
                }
            }
        }
    }
)

-- ===============================================================
-- DAP Setup (for nvim 0.12+)
-- ===============================================================


-- Bridge Mason and nvim-dap
require('mason-nvim-dap').setup({
    ensure_installed = dap_adapters,
    automatic_installation = true,
    handlers = {},
})

--
local dap = require('dap')
local dapui = require('dapui')

-- Setup the DAP UI
dapui.setup()

-- Add listeners to open/close the UI automatically
dap.listeners.after.event_initialized['dapui_config'] = function()
    dapui.open()
end
dap.listeners.before.event_terminated['dapui_config'] = function()
    dapui.close()
end
dap.listeners.before.event_exited['dapui_config'] = function()
    dapui.close()
end
--
vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint, { desc = 'DAP: Toggle Breakpoint' })
vim.keymap.set('n', '<leader>dc', dap.continue, { desc = 'DAP: Continue' })
vim.keymap.set('n', '<leader>do', dap.step_over, { desc = 'DAP: Step Over' })
vim.keymap.set('n', '<leader>di', dap.step_into, { desc = 'DAP: Step Into' })
vim.keymap.set('n', '<leader>du', dap.step_out, { desc = 'DAP: Step Out' })
vim.keymap.set('n', '<leader>dr', dap.repl.open, { desc = 'DAP: Open REPL' })
vim.keymap.set('n', '<leader>dt', dap.terminate, { desc = 'DAP: Terminate Session' })
vim.keymap.set('n', '<leader>dl', function() dapui.toggle() end, { desc = 'DAP: Toggle UI' })
