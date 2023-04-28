-- vim:foldmethod=marker

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 0
vim.opt.smarttab = true
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.scrolloff = 3
vim.opt.breakindent = true
vim.opt.showbreak = ">"
vim.opt.colorcolumn = "80,100"
vim.opt.list = true
vim.opt.listchars:append({ tab = "» ", nbsp = "⊙", trail = "∙" })
vim.opt.path:append("**") -- e.g. :find *.txt<tab>
vim.opt.diffopt:append("vertical") -- :diffsplit

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = false

vim.opt.guifont = "JetBrains Mono:h7"

-- {{{ key bindings

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.keymap.set("x", "<leader>p", [["_dP]])
vim.keymap.set({"n", "v"}, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])
vim.keymap.set({"n", "v"}, "<leader>d", [["_d]])

-- clear highlights and close quickfix
vim.keymap.set("n", "<Esc>", ":noh<cr> | :ccl<cr> | :echo<cr>")

-- Allow gf to open non-existent files
vim.keymap.set("n", "gf", ":edit <cfile><CR>")

-- Reselect visual selection after indenting
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- keep cursor centered
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzz")
vim.keymap.set("n", "N", "Nzz")

-- Insertion/removal of a trailing ; or ,
for _, x in pairs({ ";", "," }) do
    vim.keymap.set("n", x..x, function()
        vim.cmd.norm("$")
        if string.byte(x) == string.byte(vim.fn.getline("."), vim.fn.col(".")) then
            vim.cmd.norm("x")
        else
            vim.cmd.norm("A"..x)
        end
    end)
end

-- When text is wrapped, move by terminal rows, not lines when using arrow keys
vim.keymap.set("n", "<Up>", "gk")
vim.keymap.set("n", "<Down>", "gj")

-- Resize with arrows
vim.keymap.set("n", "<C-Up>", ":resize -1<CR>")
vim.keymap.set("n", "<C-Down>", ":resize +1<CR>")
vim.keymap.set("n", "<C-Left>", ":vertical resize -2<CR>")
vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>")

-- }}} key bindings

vim.opt.packpath:prepend("~/.nix-profile")

require("lsp")
