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
vim.opt.listchars:append({ tab = "⧽⧽", nbsp = "⊙", trail = "∙" })
vim.opt.path:append("**") -- e.g. :find *.txt<tab>
vim.opt.diffopt:append("vertical") -- :diffsplit
vim.opt.shortmess:append("I") -- :intro only flickering on startup due to lualine
vim.opt.title = true

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

-- open netrw with -
vim.keymap.set("n", "<leader>-", ":edit %:p:h<cr>")

-- Allow gf to open non-existent files
vim.keymap.set("n", "gf", ":edit <cfile><CR>")

-- keep cursor in a useful position
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "<leader>[", "[[zt", { remap = true }) -- how to map this to [[ ?
vim.keymap.set("n", "<leader>]", "]]zt", { remap = true }) -- how to map this to ]] ?

-- move code
vim.keymap.set("v", "<M-j>", ":m '>+1<cr>gv=gv")
vim.keymap.set("v", "<M-k>", ":m '<-2<cr>gv=gv")

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
-- NB: will be overridden later for tmux integration
vim.keymap.set("t", "<C-h>", "<C-\\><C-N><C-w>h")
vim.keymap.set("t", "<C-j>", "<C-\\><C-N><C-w>j")
vim.keymap.set("t", "<C-k>", "<C-\\><C-N><C-w>k")
vim.keymap.set("t", "<C-l>", "<C-\\><C-N><C-w>l")

-- Copy/Paste to/from tmux paste buffer
-- https://stackoverflow.com/questions/45206818/pipe-partial-line-selection-through-external-command-in-vim
local function get_selection(type)
    -- https://github.com/neovim/neovim/pull/21115
    -- https://stackoverflow.com/questions/1533565/how-to-get-visually-selected-text-in-vimscript
    -- possible alternatives: getpos('v'), getpos('.'), getpos("'<"), getpos("'>")
    local start, stop, text
    if type == 'char' then
        -- range defined by motion in mormal mode
        start = vim.api.nvim_buf_get_mark(0, '[')
        stop = vim.api.nvim_buf_get_mark(0, ']')
        text = vim.api.nvim_buf_get_text(0, start[1]-1, start[2], stop[1]-1, stop[2]+1, {})
    else
        -- range defined by visual mode selection
        start = vim.api.nvim_buf_get_mark(0, '<')
        stop = vim.api.nvim_buf_get_mark(0, '>')
        if type == 'v' then
            text = vim.api.nvim_buf_get_text(0, start[1]-1, start[2], stop[1]-1, stop[2]+1, {})
        elseif type == 'V' then
            text = vim.api.nvim_buf_get_lines(0, start[1]-1, stop[1], false)
        elseif type == '' then
            text = {}
            local startline = math.min(start[1], stop[1])
            local stopline = math.max(start[1], stop[1])
            local startcol = math.min(start[2], stop[2])
            local stopcol = math.max(start[2], stop[2])
            for line = startline-1, stopline-1 do
                table.insert(text, vim.api.nvim_buf_get_text(0, line, startcol, line, stopcol+1, {})[1])
            end
        else
            return nil
        end
    end
    return table.concat(text, "\n")
end
--local set_opfunc = vim.fn[vim.api.nvim_exec2([[
--    " https://github.com/neovim/neovim/issues/14157
--    func s:set_opfunc(val)
--        let &operatorfunc = a:val
--    endfunc
--    echon get(function('s:set_opfunc'), 'name')
--]], { output = true }).output]
_G.YankTmux = function(type)
    if type == nil then
        -- https://learnvimscriptthehardway.stevelosh.com/chapters/33.html
        -- https://github.com/neovim/neovim/issues/14680
        local old_func = vim.go.operatorfunc
        _G.YankTmuxWrapper = function(t)
            _G.YankTmux(t)
            vim.go.operatorfunc = old_func
            _G.YankTmuxWrapper = nil
        end
        vim.go.operatorfunc = "v:lua.YankTmuxWrapper"
        vim.api.nvim_feedkeys("g@", "n", false)
    else
        local selection = get_selection(type)
        if selection ~= nil then
            vim.fn.system("tmux load-buffer -", selection)
        end
    end
end
--vim.keymap.set("n", "<leader>ty", ":set operatorfunc=v:lua.YankTmux<cr>g@", { silent = true })
vim.keymap.set("n", "<leader>ty", _G.YankTmux, { silent = true })
--vim.keymap.set("v", "<leader>ty", function() _G.YankTmux(vim.fn.mode()) end, { silent = true })
vim.keymap.set("v", "<leader>ty", ":<C-u>call v:lua.YankTmux(visualmode())<cr>", { silent = true })
vim.keymap.set("n", "<leader>tp", "a<C-r>=system('tmux save-buffer -')<cr><esc>")
vim.keymap.set("n", "<leader>tP", "i<C-r>=system('tmux save-buffer -')<cr><esc>")

-- }}} key bindings

-- put auto-commands in augroup after clearing it
-- so that the auto-commands are attached only once,
-- even if this file is re-sourced
local g = vim.api.nvim_create_augroup("my-augroup", { clear = true })

vim.opt.equalalways = true
vim.api.nvim_create_autocmd("VimResized", { group = g, callback = function()
    vim.cmd.wincmd "="
end })

vim.api.nvim_create_autocmd("BufEnter", { group = g, callback = function()
    vim.opt_local.formatoptions:remove("o")
end })

vim.api.nvim_create_autocmd("FileType", { pattern = "text", group = g, callback = function()
    vim.opt_local.linebreak = true
    vim.opt_local.showbreak = "NONE"
    vim.opt_local.listchars:append({ eol = "¶" })
    vim.opt_local.formatoptions:append("r")
    vim.opt_local.comments:remove({ "fb:-", "fb:*" })
    vim.opt_local.comments:append({ "b:-", "b:*" })
end })

vim.api.nvim_create_autocmd("FileType", { pattern = "markdown", group = g, callback = function()
    vim.opt_local.linebreak = true
end })

vim.api.nvim_create_autocmd("FileType", { pattern = "make,gitconfig", group = g, callback = function()
    vim.opt_local.listchars = { tab = "  ", lead = "∙", trail = "∙", nbsp = "⊙" }
    vim.opt_local.expandtab = false
    vim.opt_local.tabstop = 8
    vim.opt_local.shiftwidth = 8
end })

-- {{{ custom highlighting
-- https://github.com/nvim-treesitter/nvim-treesitter/blob/master/queries/rust/highlights.scm
-- colors from: https://github.com/NvChad/base46/blob/v2.0/lua/base46/themes/decay.lua
-- which is based on: https://github.com/decaycs/decay.nvim
-- :help treesitter-highlight-groups
-- ~/.config/nvim/queries/rust/highlights.scm
vim.api.nvim_create_autocmd("ColorScheme", { group = g, callback = function()
    vim.api.nvim_set_hl(0, "@storageclass.lifetime.rust", { fg = "#e26c7c" }) -- lifetimes
    vim.api.nvim_set_hl(0, "@operator.questionmark.rust", { fg = "#e26c7c" }) -- postfix ?
    vim.api.nvim_set_hl(0, "@operator.ref.rust",          { fg = "#e9a180" }) -- &, *
    vim.api.nvim_set_hl(0, "@type.qualifier.rust",        { fg = "#e9a180" }) -- ref, mut
end })
-- }}} custom highlighting

vim.opt.packpath:prepend("~/.nix-profile")

require('packer').startup(function(use)
    -- Packer can manage itself
    use "wbthomason/packer.nvim"

    use "dstein64/vim-startuptime"

    -- {{{ theme
    use {
        "nordtheme/vim", as = "nord",
        config = function()
            vim.opt.termguicolors = true
            vim.cmd.colorscheme "nord"
            vim.api.nvim_create_autocmd("ColorScheme", { callback = function()
                if vim.g.colors_name ~= "nord" then return end
                vim.api.nvim_set_hl(0, "Normal", { bg = "#1d1f21" }) -- background (Alacritty default)
                vim.api.nvim_set_hl(0, "NormalFloat", { link = "Normal" })
                vim.api.nvim_set_hl(0, "VertSplit", { fg = "#4C566A", bg = "#1d1f21" })
                vim.api.nvim_set_hl(0, "SignColumn", { fg = "#4C566A", bg = "#21262e" })
                vim.api.nvim_set_hl(0, "Folded", { fg = "#D8DEE9", bg = "#4C566A" })
                vim.api.nvim_set_hl(0, "ColorColumn", { bg = "#21262e" })
                vim.api.nvim_set_hl(0, "TabLineFill", { bg = "#3B4252" })
                vim.api.nvim_set_hl(0, "TabLine", { fg = "#88C0D0", bg = "#3B4252", italic = true })
                vim.api.nvim_set_hl(0, "TabLineSel", { bg = "#88C0D0", fg = "#3B4252", bold = true })
                vim.api.nvim_set_hl(0, "Title", { fg = "#D8DEE9" }) -- window counter in tab
                vim.api.nvim_set_hl(0, "mailcapSpecial", { link = "SpecialChar" })
                vim.api.nvim_set_hl(0, "CurSearch", { bg = "#EBCB8B", fg = "#3B4252" })
            end })
        end,
    }
    use { disable = true, "catppuccin/nvim", as = "catppuccin" }
    use { disable = true, "rose-pine/neovim", as = "rose-pine" }
    use { disable = true, "sainnhe/everforest" }
    use { disable = true, "sainnhe/sonokai" }
    -- }}} theme

    -- {{{ #rrggbb colorizer
    use {
        "NvChad/nvim-colorizer.lua",
        config = function()
            require("colorizer").setup {
                filetypes = { "*" },
                buftypes = { },
                user_default_options = {
                    names = false,
                    RGB = false,
                    RRGGBB = true,
                    RRGGBBAA = true,
                    mode = "virtualtext",
                    always_update = false, -- even if buffer is not focussed
                }
            }
        end,
    }
    -- }}} #rrggbb colorizer

    -- {{{ indentation guides
    use {
        "lukas-reineke/indent-blankline.nvim",
        config = function()
            local hooks = require("ibl.hooks")
            hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
                vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#333333" })
            end)
            require("ibl").setup {
                indent = { highlight = { "RainbowRed" } },
            }
        end,
    }
    -- }}} indentation guides

    -- {{{ status line
    use {
        "nvim-lualine/lualine.nvim",
        requires = {
            {"nvim-tree/nvim-web-devicons"},
            {"arkav/lualine-lsp-progress"},
        },
        config = function()
            vim.go.showmode = false
            vim.go.laststatus = 3 -- config.globalstatus doesn't seem to work
            require("lualine").setup({
                globalstatus = true,
                icons_enabled = true,
                sections = {
                    lualine_a = {
                        { "mode", fmt = function(str) return str:sub(1,1) end }
                    },
                    lualine_b = {
                        { "branch", icon = " " },
                        "diff",
                        "diagnostics",
                    },
                    lualine_c = {
                        {
                            "filename",
                            path = 1,
                            file_status = true,
                            newfile_status = true,
                            symbols = {
                                modified = "⚪",
                                readonly = "🔒",
                                unnamed = "◌",
                                newfile = "✳",
                            },
                        },
                    },
                    lualine_x = {
                        {
                            "lsp_progress",
                            display_components = { "spinner", { "title", "percentage" } },
                            spinner_symbols = { "🌑 ", "🌒 ", "🌓 ", "🌔 ", "🌕 ", "🌖 ", "🌗 ", "🌘 " },
                        },
                        --"encoding",
                        function()
                            local enc = vim.opt.fileencoding:get()
                            return enc ~= "utf-8" and enc or ""
                        end,
                        {
                            "fileformat",
                            symbols = {
                                unix = "", --"", -- e712
                                dos = " ", -- e70f
                                mac = " ", -- e711
                            },
                        },
                        {
                            "filetype",
                            icon_only = true,
                            --icons_enabled = true,
                        },
                    },
                    lualine_y = {  },
                    lualine_z = { "location" },
                },
            })
        end,
    }
    -- }}} status line

    -- {{{ scroll bar
    -- shows diagnostics etc, but
    -- - currently doesn't work well with splits
    -- - currently doesn't support mouse
    --use {
    --    "petertriho/nvim-scrollbar",
    --    config = function()
    --        require("scrollbar").setup({
    --            handle = {
    --                color = "white",
    --            },
    --        })
    --    end,
    --}
    use {
        "dstein64/nvim-scrollview",
        config = function()
            require('scrollview').setup({
                column = 1,
                winblend = 50,
            })
            vim.api.nvim_create_autocmd("ColorScheme", { callback = function()
                vim.api.nvim_set_hl(0, "ScrollView", { bg = "white" })
            end })
        end,
    }
    -- }}} scroll bar

    -- {{{ nvim-tree
    use {
        disable = true,
        "nvim-tree/nvim-tree.lua",
        requires = "nvim-tree/nvim-web-devicons", -- optional
        config = function()
            require("nvim-tree").setup()
            vim.keymap.set("n", "<C-n>", ":NvimTreeToggle<cr>", { silent = true })
        end
    }
    -- }}} nvim-tree

    -- {{{ VimWiki
    use {
        "vimwiki/vimwiki",
        config = function()
            vim.g.vimwiki_autowriteall = 0
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
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "vimwiki",
                callback = function()
                    vim.keymap.set("i", "<Tab>", "<Plug>VimwikiIncreaseLvlSingleItem", { buffer = 0 })
                    vim.keymap.set("i", "<S-Tab>", "<Plug>VimwikiDecreaseLvlSingleItem", { buffer = 0 })
                end,
            })
        end,
    }
    -- }}} VimWiki

    -- {{{ markdown preview
    use {
        "iamcco/markdown-preview.nvim",
        run = "cd app && npm install",
        setup = function() vim.g.mkdp_filetypes = { "markdown" } end,
        ft = { "markdown" },
    }
    -- }}} markdown preview

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

    -- {{{ telescope
    use {
        "nvim-telescope/telescope.nvim",
        branch = "0.1.x",
        requires = {
            -- :checkhealth telescope
            -- programs: rg, fd
            {"nvim-lua/plenary.nvim"},
            {"nvim-treesitter/nvim-treesitter"}, -- optional
            {"nvim-tree/nvim-web-devicons"}, -- optional
        },
        config = function()
            local builtin = require('telescope.builtin')
            vim.keymap.set('n', '<leader>ff', builtin.find_files)
            vim.keymap.set('n', '<leader>fg', builtin.live_grep)
            vim.keymap.set('n', '<leader>fb', builtin.buffers)
            vim.keymap.set('n', '<leader>fh', builtin.help_tags)
        end,
    }
    -- }}} telescope

    -- {{{ tmux
    use {
        "aserowy/tmux.nvim",
        config = function ()
            local tmux = require("tmux")
            tmux.setup({
                copy_sync = {
                    enable = false,
                },
                navigation = {
                    enable_default_keybindings = true,
                    cycle_navigation = false,
                },
                resize = {
                    enable_default_keybindings = false,
                },
            })
            vim.keymap.set("t", "<C-h>", tmux.move_left)
            vim.keymap.set("t", "<C-j>", tmux.move_bottom)
            vim.keymap.set("t", "<C-k>", tmux.move_top)
            vim.keymap.set("t", "<C-l>", tmux.move_right)
        end
    }
    -- }}} tmux

    -- {{{ Emmet-vim
    vim.g.user_emmet_leader_key = "<A-m>"
    use "mattn/emmet-vim"
    -- }}} Emmet-vim

    -- {{{ comments
    use {
        "numToStr/Comment.nvim",
        config = function()
            require("Comment").setup({
                padding = false,
            })
        end
    }
    -- }}} comments

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
    use {
        "nvim-treesitter/playground",
        cmd = {"TSPlaygroundToggle"},
        config = function()
            require "nvim-treesitter.configs".setup({
                playground = {
                    enable = true,
                    disable = {},
                    updatetime = 25, -- Debounced time for focussing in the playground from source
                    persist_queries = false, -- Whether the query persists across vim sessions
                    keybindings = {
                        toggle_query_editor = 'o',
                        toggle_hl_groups = 'i',
                        toggle_injected_languages = 't',
                        toggle_anonymous_nodes = 'a',
                        toggle_language_display = 'I',
                        focus_language = 'f',
                        unfocus_language = 'F',
                        update = 'R',
                        goto_node = '<cr>',
                        show_help = '?',
                    },
                }
            })
        end,
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
            local lsp = require("lsp-zero").preset({
                manage_nvim_cmp = {
                    set_extra_mappings = true,
                },
            })

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

            vim.api.nvim_create_autocmd("ColorScheme", { callback = function()
                vim.api.nvim_set_hl(0, "DapBreakpoint", { fg="#ff0000" })
                vim.api.nvim_set_hl(0, "DapLogPoint", { fg="#0000ff" })
                vim.api.nvim_set_hl(0, "DapStopped", { fg="#ffffff" })
            end })

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
            dap.listeners.after.event_initialized["dapui_config"] =
                function() dapui.open { reset = true } end -- cf. issue #145
            dap.listeners.before.event_terminated["dapui_config"] = dapui.close
            dap.listeners.before.event_exited["dapui_config"] = dapui.close
            vim.api.nvim_create_autocmd("ColorScheme", { callback = function()
                vim.api.nvim_set_hl(0, "DapUINormal", { link = "Normal" })
            end })
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

    -- {{{ neotest
    use {
        "nvim-neotest/neotest",
        requires = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            "antoinemadec/FixCursorHold.nvim",
            --"nvim-neotest/neotest-vim-test", "vim-test/vim-test",
            "nvim-neotest/neotest-plenary",
            "rouge8/neotest-rust",
        },
        config = function()
            require("neotest").setup({
                adapters = {
                    --require("neotest-vim-test") { allow_file_types = { "rust" } },
                    require("neotest-plenary"),
                    require("neotest-rust") { dap_adapter = "lldb" },
                },
            })
            local neotest = require("neotest")
            vim.keymap.set("n", "<leader>tt", neotest.run.run)
            vim.keymap.set("n", "<leader>tT", function() neotest.run.run({strategy = "dap"}) end)
            vim.keymap.set("n", "<leader>tl", neotest.run.run_last)
            vim.keymap.set("n", "<leader>tL", function() neotest.run.run_last({strategy = "dap"}) end)
            vim.keymap.set("n", "<leader>tf", function() neotest.run.run(vim.fn.expand("%")) end)
            vim.keymap.set("n", "<leader>tF", function() neotest.run.run({vim.fn.expand("%"), strategy = "dap"}) end)
            vim.keymap.set("n", "<leader>to", neotest.output_panel.toggle)
            vim.keymap.set("n", "<leader>ta", neotest.run.attach)
            vim.keymap.set("n", "<leader>ts", neotest.run.stop)
        end,
    }
    -- }}} neotest
end)
