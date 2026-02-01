-- init.lua - Neovim Configuration
-- Modern Lua-based Neovim configuration for development environments

-- ============================================================================
-- Basic Settings
-- ============================================================================

-- Set leader key early
vim.g.mapleader = ","
vim.g.maplocalleader = " "

-- Disable some built-in plugins we don't want
local disabled_built_ins = {
    "2html_plugin",
    "getscript",
    "getscriptPlugin",
    "gzip",
    "logipat",
    "netrw",
    "netrwPlugin",
    "netrwSettings",
    "netrwFileHandlers",
    "matchit",
    "tar",
    "tarPlugin",
    "rrhelper",
    "spellfile_plugin",
    "vimball",
    "vimballPlugin",
    "zip",
    "zipPlugin",
}

for _, plugin in pairs(disabled_built_ins) do
    vim.g["loaded_" .. plugin] = 1
end

-- Basic options
local options = {
    -- File handling
    backup = true,
    backupdir = vim.fn.expand("~/.local/share/nvim/backup//"),
    undofile = true,
    undodir = vim.fn.expand("~/.local/share/nvim/undo//"),
    swapfile = true,
    directory = vim.fn.expand("~/.local/share/nvim/swap//"),
    
    -- Search
    ignorecase = true,
    smartcase = true,
    incsearch = true,
    hlsearch = true,
    
    -- Indentation
    expandtab = true,
    shiftwidth = 4,
    tabstop = 4,
    softtabstop = 4,
    autoindent = true,
    smartindent = true,
    
    -- UI
    number = true,
    relativenumber = true,
    cursorline = true,
    wrap = false,
    scrolloff = 8,
    sidescrolloff = 8,
    colorcolumn = "80",
    signcolumn = "yes",
    cmdheight = 2,
    updatetime = 300,
    
    -- Splits
    splitright = true,
    splitbelow = true,
    
    -- Other
    mouse = "a",
    clipboard = "unnamedplus",
    hidden = true,
    showmode = false,
    showtabline = 2,
    laststatus = 3,
    pumheight = 10,
    pumblend = 10,
    winblend = 0,
    
    -- Performance
    lazyredraw = true,
    ttyfast = true,
    timeoutlen = 1000,
    ttimeoutlen = 0,
    
    -- Completion
    completeopt = "menuone,noselect",
    
    -- Folding
    foldmethod = "indent",
    foldlevel = 99,
    
    -- Whitespace
    list = true,
    listchars = "tab:→ ,trail:·,extends:>,precedes:<,nbsp:+",
    
    -- Terminal colors
    termguicolors = true,
}

-- Apply options
for option, value in pairs(options) do
    vim.opt[option] = value
end

-- Create necessary directories
local function ensure_dir(path)
    if vim.fn.isdirectory(path) == 0 then
        vim.fn.mkdir(path, "p")
    end
end

ensure_dir(vim.fn.expand("~/.local/share/nvim/backup"))
ensure_dir(vim.fn.expand("~/.local/share/nvim/undo"))
ensure_dir(vim.fn.expand("~/.local/share/nvim/swap"))

-- ============================================================================
-- Plugin Management (Lazy.nvim)
-- ============================================================================

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- Plugin specifications
local plugins = {
    -- Essential plugins
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        config = function()
            require("which-key").setup()
        end,
    },
    
    -- File explorer
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
        },
        config = function()
            require("neo-tree").setup({
                filesystem = {
                    filtered_items = {
                        hide_dotfiles = false,
                        hide_gitignored = false,
                    },
                },
            })
        end,
    },
    
    -- Fuzzy finder
    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.4",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("telescope").setup({
                defaults = {
                    prompt_prefix = "🔍 ",
                    selection_caret = "➤ ",
                    layout_config = {
                        horizontal = {
                            preview_width = 0.6,
                        },
                    },
                },
            })
        end,
    },
    
    -- Syntax highlighting
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = {
                    "lua", "vim", "vimdoc", "query",
                    "javascript", "typescript", "python", "go", "rust",
                    "html", "css", "json", "yaml", "toml", "markdown",
                    "bash", "dockerfile", "gitignore"
                },
                auto_install = true,
                highlight = { enable = true },
                indent = { enable = true },
            })
        end,
    },
    
    -- LSP Configuration
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "folke/neodev.nvim",
        },
        config = function()
            require("neodev").setup()
            require("mason").setup()
            require("mason-lspconfig").setup({
                ensure_installed = {
                    "lua_ls", "tsserver", "pyright", "gopls", "rust_analyzer"
                },
            })
            
            local lspconfig = require("lspconfig")
            local capabilities = require("cmp_nvim_lsp").default_capabilities()
            
            -- Configure LSP servers
            local servers = {
                "lua_ls", "tsserver", "pyright", "gopls", "rust_analyzer",
                "html", "cssls", "jsonls", "yamlls"
            }
            
            for _, server in ipairs(servers) do
                lspconfig[server].setup({
                    capabilities = capabilities,
                })
            end
        end,
    },
    
    -- Completion
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
        },
        config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")
            
            cmp.setup({
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-f>"] = cmp.mapping.scroll_docs(4),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<C-e>"] = cmp.mapping.abort(),
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                }, {
                    { name = "buffer" },
                }),
            })
        end,
    },
    
    -- Git integration
    {
        "lewis6991/gitsigns.nvim",
        config = function()
            require("gitsigns").setup()
        end,
    },
    
    {
        "tpope/vim-fugitive",
    },
    
    -- Status line
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("lualine").setup({
                options = {
                    theme = "gruvbox",
                    component_separators = { left = "|", right = "|" },
                    section_separators = { left = "", right = "" },
                },
            })
        end,
    },
    
    -- Color scheme
    {
        "morhetz/gruvbox",
        priority = 1000,
        config = function()
            vim.cmd.colorscheme("gruvbox")
        end,
    },
    
    -- Editing enhancements
    {
        "tpope/vim-surround",
    },
    
    {
        "tpope/vim-commentary",
    },
    
    {
        "windwp/nvim-autopairs",
        config = function()
            require("nvim-autopairs").setup()
        end,
    },
    
    {
        "kylechui/nvim-surround",
        version = "*",
        event = "VeryLazy",
        config = function()
            require("nvim-surround").setup()
        end,
    },
    
    -- Formatting
    {
        "stevearc/conform.nvim",
        config = function()
            require("conform").setup({
                formatters_by_ft = {
                    lua = { "stylua" },
                    python = { "black" },
                    javascript = { "prettier" },
                    typescript = { "prettier" },
                    html = { "prettier" },
                    css = { "prettier" },
                    json = { "prettier" },
                    yaml = { "prettier" },
                    markdown = { "prettier" },
                },
            })
        end,
    },
    
    -- Linting
    {
        "mfussenegger/nvim-lint",
        config = function()
            require("lint").linters_by_ft = {
                python = { "flake8" },
                javascript = { "eslint" },
                typescript = { "eslint" },
            }
        end,
    },
    
    -- Terminal
    {
        "akinsho/toggleterm.nvim",
        version = "*",
        config = function()
            require("toggleterm").setup({
                size = 20,
                open_mapping = [[<c-\>]],
                direction = "horizontal",
            })
        end,
    },
    
    -- Dashboard
    {
        "goolord/alpha-nvim",
        config = function()
            require("alpha").setup(require("alpha.themes.dashboard").config)
        end,
    },
    
    -- Indentation guides
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        opts = {},
    },
    
    -- Comments
    {
        "numToStr/Comment.nvim",
        config = function()
            require("Comment").setup()
        end,
    },
}

-- Setup lazy.nvim
require("lazy").setup(plugins, {
    change_detection = {
        notify = false,
    },
})

-- ============================================================================
-- Key Mappings
-- ============================================================================

local keymap = vim.keymap.set

-- Quick save and quit
keymap("n", "<leader>w", ":w<CR>", { desc = "Save file" })
keymap("n", "<leader>q", ":q<CR>", { desc = "Quit" })
keymap("n", "<leader>Q", ":q!<CR>", { desc = "Force quit" })

-- Clear search highlighting
keymap("n", "<leader>/", ":nohl<CR>", { desc = "Clear search highlight" })

-- Buffer navigation
keymap("n", "<leader>bn", ":bnext<CR>", { desc = "Next buffer" })
keymap("n", "<leader>bp", ":bprevious<CR>", { desc = "Previous buffer" })
keymap("n", "<leader>bd", ":bdelete<CR>", { desc = "Delete buffer" })

-- Window navigation
keymap("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
keymap("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
keymap("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
keymap("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Window resizing
keymap("n", "<leader>+", ":resize +5<CR>", { desc = "Increase height" })
keymap("n", "<leader>-", ":resize -5<CR>", { desc = "Decrease height" })
keymap("n", "<leader>>", ":vertical resize +5<CR>", { desc = "Increase width" })
keymap("n", "<leader><", ":vertical resize -5<CR>", { desc = "Decrease width" })

-- Move lines
keymap("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
keymap("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
keymap("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
keymap("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Indentation
keymap("v", "<", "<gv", { desc = "Indent left" })
keymap("v", ">", ">gv", { desc = "Indent right" })

-- Better center on search
keymap("n", "n", "nzz", { desc = "Next search result" })
keymap("n", "N", "Nzz", { desc = "Previous search result" })

-- Plugin keymaps
keymap("n", "<leader>e", ":Neotree toggle<CR>", { desc = "Toggle file explorer" })
keymap("n", "<leader>ff", ":Telescope find_files<CR>", { desc = "Find files" })
keymap("n", "<leader>fg", ":Telescope live_grep<CR>", { desc = "Live grep" })
keymap("n", "<leader>fb", ":Telescope buffers<CR>", { desc = "Find buffers" })
keymap("n", "<leader>fh", ":Telescope help_tags<CR>", { desc = "Help tags" })

-- LSP keymaps
keymap("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
keymap("n", "gr", vim.lsp.buf.references, { desc = "Go to references" })
keymap("n", "K", vim.lsp.buf.hover, { desc = "Hover documentation" })
keymap("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol" })
keymap("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })

-- Format
keymap("n", "<leader>fm", function()
    require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "Format buffer" })

-- ============================================================================
-- Auto Commands
-- ============================================================================

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Highlight on yank
augroup("YankHighlight", { clear = true })
autocmd("TextYankPost", {
    group = "YankHighlight",
    callback = function()
        vim.highlight.on_yank({ higroup = "IncSearch", timeout = 300 })
    end,
})

-- Remove trailing whitespace on save
augroup("TrimWhitespace", { clear = true })
autocmd("BufWritePre", {
    group = "TrimWhitespace",
    pattern = "*",
    callback = function()
        local save_cursor = vim.fn.getpos(".")
        vim.cmd([[%s/\s\+$//e]])
        vim.fn.setpos(".", save_cursor)
    end,
})

-- Return to last edit position
augroup("RestoreCursor", { clear = true })
autocmd("BufReadPost", {
    group = "RestoreCursor",
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local lcount = vim.api.nvim_buf_line_count(0)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

-- Language-specific settings
augroup("LanguageSettings", { clear = true })

-- Python
autocmd("FileType", {
    group = "LanguageSettings",
    pattern = "python",
    callback = function()
        vim.opt_local.tabstop = 4
        vim.opt_local.shiftwidth = 4
        vim.opt_local.expandtab = true
        vim.opt_local.colorcolumn = "79"
    end,
})

-- JavaScript/TypeScript
autocmd("FileType", {
    group = "LanguageSettings",
    pattern = { "javascript", "typescript", "json" },
    callback = function()
        vim.opt_local.tabstop = 2
        vim.opt_local.shiftwidth = 2
        vim.opt_local.expandtab = true
    end,
})

-- Go
autocmd("FileType", {
    group = "LanguageSettings",
    pattern = "go",
    callback = function()
        vim.opt_local.tabstop = 4
        vim.opt_local.shiftwidth = 4
        vim.opt_local.expandtab = false
    end,
})

-- YAML
autocmd("FileType", {
    group = "LanguageSettings",
    pattern = "yaml",
    callback = function()
        vim.opt_local.tabstop = 2
        vim.opt_local.shiftwidth = 2
        vim.opt_local.expandtab = true
    end,
})

-- ============================================================================
-- Custom Functions
-- ============================================================================

-- Toggle relative line numbers
local function toggle_relative_number()
    if vim.opt.relativenumber:get() then
        vim.opt.relativenumber = false
        vim.opt.number = true
    else
        vim.opt.relativenumber = true
    end
end

keymap("n", "<leader>ln", toggle_relative_number, { desc = "Toggle relative numbers" })

-- Format JSON
local function format_json()
    vim.cmd("%!python -m json.tool")
end

vim.api.nvim_create_user_command("FormatJSON", format_json, {})

-- ============================================================================
-- Load Local Configuration
-- ============================================================================

-- Load local init.lua if it exists
local local_config = vim.fn.stdpath("config") .. "/init.local.lua"
if vim.fn.filereadable(local_config) == 1 then
    dofile(local_config)
end