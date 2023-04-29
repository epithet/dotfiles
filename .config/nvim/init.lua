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
vim.keymap.set("n", "<Esc>", function()
    vim.cmd("nohlsearch")
    vim.cmd("cclose")
end, { silent = true })

-- Allow gf to open non-existent files
vim.keymap.set("n", "gf", ":edit <cfile><CR>")

-- keep cursor centered
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzz")
vim.keymap.set("n", "N", "Nzz")

-- Insertion/removal of a trailing ; or ,
for _, x in pairs({ ";", "," }) do
    vim.keymap.set("n", "<leader>"..x..x, function()
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

    -- {{{ tree-sittter
    use {
        "nvim-treesitter/nvim-treesitter",
        run = function()
            local ts_update = require("nvim-treesitter.install").update({ with_sync = true })
            ts_update()
        end,
        config = function()
            require'nvim-treesitter.configs'.setup {
                ensure_installed = {
                    "c", "lua", "vim", "vimdoc", "query", -- these 5 are mandatory
                    "rust",
                    "javascript",
                    "typescript",
                },
                sync_install = false,
                auto_install = false,
                highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = false,
                },
            }
        end
    }
    -- }}} tree-sittter

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

    -- {{{ DAP
    use {
        "mfussenegger/nvim-dap",
        config = function()
            local dap = require("dap")
            dap.adapters.lldb = {
                type = "executable",
                command = "/home/seb/.nix-profile/bin/lldb-vscode", -- adjust as needed
                name = "lldb",
            }

            local function lldb(get_program)
                return {
                    name = "Launch lldb",
                    type = "lldb", -- matches the adapter
                    request = "launch", -- could also attach to a currently running process
                    program = get_program or function()
                        return vim.fn.input(
                            "Path to executable: ",
                            vim.fn.getcwd() .. "/",
                            "file"
                        )
                    end,
                    cwd = "${workspaceFolder}",
                    stopOnEntry = false,
                    args = {},
                    runInTerminal = false,
                }
            end

            dap.configurations.rust = {
                lldb(function()
                    local json = ""
                    vim.fn.jobwait({
                        vim.fn.jobstart("cargo read-manifest", {
                            cwd = vim.fn.getcwd(),
                            stdout_buffered = true,
                            on_stdout = function(_, data)
                                json = vim.fn.json_decode(data)
                            end
                        })
                    })
                    return vim.fs.dirname(json["manifest_path"]).."/target/debug/"..json["name"]
                end),
            }

            vim.keymap.set("n", "<F5>", function() dap.continue() end)
            vim.keymap.set("n", "<F6>", function() dap.disconnect(); dap.close(); end)
            vim.keymap.set("n", "<F9>", dap.toggle_breakpoint)
            vim.keymap.set("n", "<F10>", dap.step_over)
            vim.keymap.set("n", "<F11>", dap.step_into)
            vim.keymap.set("n", "<F12>", dap.step_out)

            vim.api.nvim_set_hl(0, "DapBreakpoint", { ctermbg=0, fg="#ff0000" })
            vim.api.nvim_set_hl(0, "DapLogPoint", { ctermbg=0, fg="#0000ff" })
            vim.api.nvim_set_hl(0, "DapStopped", { ctermbg=0, fg="#ffffff" })

            vim.fn.sign_define("DapBreakpoint", { text="", texthl="DapBreakpoint", linehl="", numhl="" })
            vim.fn.sign_define("DapBreakpointCondition", { text="ﳁ", texthl="DapBreakpoint", linehl="", numhl="" })
            vim.fn.sign_define("DapBreakpointRejected", { text="", texthl="DapBreakpoint", linehl="", numhl= "" })
            vim.fn.sign_define("DapLogPoint", { text="", texthl="DapLogPoint", linehl="", numhl= "" })
            vim.fn.sign_define("DapStopped", { text="", texthl="DapStopped", linehl="", numhl= "" })
        end,
    }
    -- }}} DAP

    -- {{{ DAP UI
    use {
        "rcarriga/nvim-dap-ui",
        requires = "mfussenegger/nvim-dap",
        config = function()
            local dapui = require("dapui")
            dapui.setup()
            local dap = require("dap")
            dap.listeners.after.event_initialized["dapui_config"] = dapui.open
            dap.listeners.before.event_terminated["dapui_config"] = dapui.close
            dap.listeners.before.event_exited["dapui_config"] = dapui.close
        end
    }
    -- }}} DAP UI

    -- {{{ DAP virtual text
    use {
        "theHamsta/nvim-dap-virtual-text",
        requires = {
            {"mfussenegger/nvim-dap"},
            {"nvim-treesitter/nvim-treesitter"},
        },
        config = function()
            require("nvim-dap-virtual-text").setup()
        end,
    }
    -- }}} DAP virtual text
end)
