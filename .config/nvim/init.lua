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

-- Navigate windows from terminal mode (:help terminal-mode)
-- TODO: to be integrated with tmux
vim.keymap.set("t", "<C-h>", "<C-\\><C-N><C-w>h")
vim.keymap.set("t", "<C-j>", "<C-\\><C-N><C-w>j")
vim.keymap.set("t", "<C-k>", "<C-\\><C-N><C-w>k")
vim.keymap.set("t", "<C-l>", "<C-\\><C-N><C-w>l")

-- }}} key bindings

vim.opt.packpath:prepend("~/.nix-profile")

require('packer').startup(function(use)
    -- Packer can manage itself
    use "wbthomason/packer.nvim"

    -- {{{ VimWiki
    use {
        "vimwiki/vimwiki",
        config = function()
            vim.g.vimwiki_list = {{
                path = "~/docs",
                syntax = "markdown",
                ext = ".md",
            }}
            vim.keymap.set("n", "<leader>ww", function()
                --"<cmd>cd `=vimwiki_list[0]['path']`<cr><cmd>VimwikiIndex<cr>",
                --"<cmd>exe 'cd' fnameescape(vimwiki_list[0]['path'])<cr><cmd>VimwikiIndex<cr>",
                vim.api.nvim_set_current_dir(vim.g.vimwiki_list[1]["path"])
                vim.api.nvim_command("VimwikiIndex")
            end)
        end,
    }
    -- }}} VimWiki

    -- {{{ harpoon
    use {
        "ThePrimeagen/harpoon",
        requires = {
            {"nvim-lua/plenary.nvim"},
            {
                "NvChad/nvterm",
                config = function()
                    require("nvterm").setup()
                    local t = require("nvterm.terminal")
                    vim.keymap.set({ "n", "t" }, "<A-i>", function() t.toggle "float" end)
                    vim.keymap.set({ "n", "t" }, "<A-h>", function() t.toggle "horizontal" end)
                    vim.keymap.set({ "n", "t" }, "<A-v>", function() t.toggle "vertical" end)
                end,
            },
        },
        config = function()
            local mark = require("harpoon.mark")
            local ui = require("harpoon.ui")
            vim.keymap.set("n", "<leader>a", mark.add_file)
            vim.keymap.set("n", "<leader>o", ui.toggle_quick_menu)
            vim.keymap.set("n", "<A-j>", function() ui.nav_file(1) end)
            vim.keymap.set("n", "<A-k>", function() ui.nav_file(2) end)
            vim.keymap.set("n", "<A-l>", function() ui.nav_file(3) end)
            vim.keymap.set("n", "<A-;>", function() ui.nav_file(4) end)
            local cmd_ui = require("harpoon.cmd-ui")
            vim.keymap.set("n", "<leader>i", cmd_ui.toggle_quick_menu)
            --local term = require("harpoon.term")
            --vim.keymap.set("n", "<A-n>", function() term.gotoTerminal(1) end)
            --local t = { idx = 1, create_with = ":lua require('nvterm.terminal').send('', 'horizontal')" }
            --vim.keymap.set("n", "<A-m>", function() term.sendCommand(t, 1); term.sendCommand(1, "\n") end)
            local harpoon = require('harpoon')
            local function send_cmd(idx)
                local cmd = harpoon.get_term_config().cmds[idx]
                require('nvterm.terminal').send(cmd, 'horizontal')
            end
            vim.keymap.set({ "n", "t" }, "<A-m>", function() send_cmd(1) end)
            vim.keymap.set({ "n", "t" }, "<A-,>", function() send_cmd(2) end)
            vim.keymap.set({ "n", "t" }, "<A-.>", function() send_cmd(3) end)
            vim.keymap.set({ "n", "t" }, "<A-/>", function() send_cmd(4) end)
        end,
    }
    -- }}} harpoon

    use "mattn/emmet-vim"

    -- {{{ LSP
    use {
        "VonHeikemen/lsp-zero.nvim",
        branch = "v2.x",
        requires = {
            -- lsp support
            {"neovim/nvim-lspconfig"}, -- required
            -- mason is not recommended on NixOS:
            -- https://nixos.wiki/wiki/Packaging/Binaries
            --{"williamboman/mason.nvim"},
            --{"williamboman/mason-lspconfig.nvim"},

            -- autocompletion
            {"hrsh7th/nvim-cmp"}, -- required
            {"hrsh7th/cmp-nvim-lsp"}, -- required
            {"hrsh7th/cmp-nvim-lua"},
            {"hrsh7th/cmp-buffer"},
            --{"hrsh7th/cmp-path"},
            --{"saadparwaiz1/cmp_luasnip"},

            -- snippets
            {"L3MON4D3/LuaSnip"}, -- required
            --{"rafamadriz/friendly-snippets"},
        },
        config = function()
            local lsp = require("lsp-zero").preset({})

            lsp.on_attach(function(_, bufnr)
                lsp.default_keymaps({buffer = bufnr})
            end)

            -- When you don't have mason.nvim installed
            -- You'll need to list the servers installed in your system
            lsp.setup_servers({
                "rnix",
                "clangd",
                "rust_analyzer",
            })

            require("lspconfig").lua_ls.setup(lsp.nvim_lua_ls())

            lsp.setup()

            local cmp = require("cmp")
            cmp.setup({
                mapping = {
                    ["<CR>"] = cmp.mapping.confirm({select = false}),
                },
                sources = {
                    --{name = "path"},
                    {name = "nvim_lsp"},
                    {name = "buffer", keyword_length = 3},
                    {name = "luasnip", keyword_length = 2},
                },
            })

            vim.opt.signcolumn = "auto"
        end
    }
    -- }}} LSP
end)
