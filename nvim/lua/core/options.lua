local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.breakindent = true
opt.undofile = true
opt.ignorecase = true
opt.smartcase = true
opt.signcolumn = "yes"
opt.updatetime = 250
opt.timeoutlen = 350
opt.ttimeoutlen = 10
opt.splitright = true
opt.splitbelow = true
opt.list = true
opt.listchars = {
    tab = "» ",
    trail = "·",
    nbsp = "␣"
}
opt.inccommand = "split"
opt.cursorline = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.termguicolors = true
opt.expandtab = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.smartindent = true
opt.completeopt = {"menu", "menuone", "noselect"}

opt.relativenumber = false
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Deixa as janelas de ajuda do LSP e janelas flutuantes com bordas arredondadas
local _border = "rounded"

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
    border = _border
})

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
    border = _border
})

vim.diagnostic.config({
    float = {
        border = _border
    }
})
