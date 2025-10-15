vim.pack.add({
    {src = "https://github.com/stevearc/oil.nvim"},
    {src = "https://github.com/echasnovski/mini.pick"},
    {src = "https://github.com/neovim/nvim-lspconfig"},
})

vim.lsp.enable({"lua_ls"})
