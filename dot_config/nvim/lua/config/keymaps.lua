-- Enhanced keymaps configuration for Neovim
-- Extended key mappings for better workflow

local keymap = vim.keymap.set

-- ============================================================================
-- General Keymaps
-- ============================================================================

-- Better escape
keymap("i", "jk", "<ESC>", { desc = "Exit insert mode" })
keymap("i", "kj", "<ESC>", { desc = "Exit insert mode" })

-- Save all buffers
keymap("n", "<leader>W", ":wa<CR>", { desc = "Save all buffers" })

-- Quit all
keymap("n", "<leader>qa", ":qa<CR>", { desc = "Quit all" })

-- Source current file
keymap("n", "<leader>so", ":source %<CR>", { desc = "Source current file" })

-- ============================================================================
-- Navigation Enhancements
-- ============================================================================

-- Better page navigation
keymap("n", "<C-d>", "<C-d>zz", { desc = "Half page down and center" })
keymap("n", "<C-u>", "<C-u>zz", { desc = "Half page up and center" })

-- Start and end of line
keymap({ "n", "v" }, "H", "^", { desc = "Start of line" })
keymap({ "n", "v" }, "L", "$", { desc = "End of line" })

-- Better word navigation
keymap("n", "W", "5w", { desc = "Move 5 words forward" })
keymap("n", "B", "5b", { desc = "Move 5 words backward" })

-- ============================================================================
-- Text Editing
-- ============================================================================

-- Copy to system clipboard
keymap({ "n", "v" }, "<leader>y", '"+y', { desc = "Copy to system clipboard" })
keymap("n", "<leader>Y", '"+Y', { desc = "Copy line to system clipboard" })

-- Paste from system clipboard
keymap({ "n", "v" }, "<leader>p", '"+p', { desc = "Paste from system clipboard" })

-- Delete without copying to clipboard
keymap({ "n", "v" }, "<leader>d", '"_d', { desc = "Delete without copying" })

-- Replace word under cursor
keymap("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Replace word under cursor" })

-- Make file executable
keymap("n", "<leader>x", ":!chmod +x %<CR>", { desc = "Make file executable", silent = true })

-- ============================================================================
-- Split Management
-- ============================================================================

-- Split navigation with Alt
keymap("n", "<A-h>", "<C-w>h", { desc = "Move to left split" })
keymap("n", "<A-j>", "<C-w>j", { desc = "Move to bottom split" })
keymap("n", "<A-k>", "<C-w>k", { desc = "Move to top split" })
keymap("n", "<A-l>", "<C-w>l", { desc = "Move to right split" })

-- Split resizing
keymap("n", "<C-Up>", ":resize -2<CR>", { desc = "Resize split up" })
keymap("n", "<C-Down>", ":resize +2<CR>", { desc = "Resize split down" })
keymap("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Resize split left" })
keymap("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Resize split right" })

-- Split creation
keymap("n", "<leader>sv", ":vsplit<CR>", { desc = "Vertical split" })
keymap("n", "<leader>sh", ":split<CR>", { desc = "Horizontal split" })
keymap("n", "<leader>sc", ":close<CR>", { desc = "Close split" })
keymap("n", "<leader>so", ":only<CR>", { desc = "Close other splits" })

-- ============================================================================
-- Tab Management
-- ============================================================================

keymap("n", "<leader>to", ":tabnew<CR>", { desc = "New tab" })
keymap("n", "<leader>tc", ":tabclose<CR>", { desc = "Close tab" })
keymap("n", "<leader>tn", ":tabnext<CR>", { desc = "Next tab" })
keymap("n", "<leader>tp", ":tabprevious<CR>", { desc = "Previous tab" })
keymap("n", "<leader>tm", ":tabmove<Space>", { desc = "Move tab" })

-- ============================================================================
-- Search and Replace
-- ============================================================================

-- Search in visual selection
keymap("v", "<leader>/", '"fy/\\V<C-R>f<CR>', { desc = "Search selection" })

-- Search and replace in visual selection
keymap("v", "<leader>sr", '"hy:%s/<C-r>h//gc<left><left><left>', { desc = "Replace in selection" })

-- Global search and replace
keymap("n", "<leader>S", ":%s//g<Left><Left>", { desc = "Global search and replace" })

-- ============================================================================
-- Quick Fixes and Location List
-- ============================================================================

keymap("n", "<leader>qo", ":copen<CR>", { desc = "Open quickfix" })
keymap("n", "<leader>qc", ":cclose<CR>", { desc = "Close quickfix" })
keymap("n", "<leader>qn", ":cnext<CR>", { desc = "Next quickfix" })
keymap("n", "<leader>qp", ":cprev<CR>", { desc = "Previous quickfix" })

keymap("n", "<leader>lo", ":lopen<CR>", { desc = "Open location list" })
keymap("n", "<leader>lc", ":lclose<CR>", { desc = "Close location list" })
keymap("n", "<leader>ln", ":lnext<CR>", { desc = "Next location" })
keymap("n", "<leader>lp", ":lprev<CR>", { desc = "Previous location" })

-- ============================================================================
-- Git Keymaps
-- ============================================================================

keymap("n", "<leader>gs", ":Git<CR>", { desc = "Git status" })
keymap("n", "<leader>ga", ":Git add .<CR>", { desc = "Git add all" })
keymap("n", "<leader>gc", ":Git commit<CR>", { desc = "Git commit" })
keymap("n", "<leader>gp", ":Git push<CR>", { desc = "Git push" })
keymap("n", "<leader>gl", ":Git log --oneline<CR>", { desc = "Git log" })
keymap("n", "<leader>gd", ":Gdiffsplit<CR>", { desc = "Git diff" })
keymap("n", "<leader>gb", ":Git blame<CR>", { desc = "Git blame" })

-- ============================================================================
-- Diagnostic Keymaps
-- ============================================================================

keymap("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
keymap("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
keymap("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic" })
keymap("n", "<leader>dl", vim.diagnostic.setloclist, { desc = "Diagnostic list" })

-- ============================================================================
-- Terminal Keymaps
-- ============================================================================

-- Terminal mode navigation
keymap("t", "<C-h>", "<cmd>wincmd h<cr>", { desc = "Move to left window" })
keymap("t", "<C-j>", "<cmd>wincmd j<cr>", { desc = "Move to bottom window" })
keymap("t", "<C-k>", "<cmd>wincmd k<cr>", { desc = "Move to top window" })
keymap("t", "<C-l>", "<cmd>wincmd l<cr>", { desc = "Move to right window" })

-- Terminal escape
keymap("t", "<C-\\>", "<C-\\><C-n>", { desc = "Escape terminal mode" })

-- ============================================================================
-- Utility Functions
-- ============================================================================

-- Toggle wrap
keymap("n", "<leader>tw", function()
    vim.opt.wrap = not vim.opt.wrap:get()
    print("Wrap " .. (vim.opt.wrap:get() and "enabled" or "disabled"))
end, { desc = "Toggle line wrap" })

-- Toggle spell check
keymap("n", "<leader>ts", function()
    vim.opt.spell = not vim.opt.spell:get()
    print("Spell check " .. (vim.opt.spell:get() and "enabled" or "disabled"))
end, { desc = "Toggle spell check" })

-- Toggle conceallevel
keymap("n", "<leader>tc", function()
    local conceallevel = vim.opt.conceallevel:get()
    if conceallevel == 0 then
        vim.opt.conceallevel = 2
        print("Conceal enabled")
    else
        vim.opt.conceallevel = 0
        print("Conceal disabled")
    end
end, { desc = "Toggle conceal" })

-- Reload configuration
keymap("n", "<leader>R", function()
    vim.cmd("source " .. vim.fn.stdpath("config") .. "/init.lua")
    print("Configuration reloaded")
end, { desc = "Reload config" })

-- ============================================================================
-- Plugin-specific Keymaps (conditional)
-- ============================================================================

-- These will be overridden by plugin configurations if plugins are loaded

-- Telescope (if available)
local telescope_ok, _ = pcall(require, "telescope")
if telescope_ok then
    keymap("n", "<leader>fr", ":Telescope oldfiles<CR>", { desc = "Recent files" })
    keymap("n", "<leader>fc", ":Telescope commands<CR>", { desc = "Commands" })
    keymap("n", "<leader>fk", ":Telescope keymaps<CR>", { desc = "Keymaps" })
    keymap("n", "<leader>fs", ":Telescope current_buffer_fuzzy_find<CR>", { desc = "Buffer search" })
    keymap("n", "<leader>fd", ":Telescope diagnostics<CR>", { desc = "Diagnostics" })
end

-- Neo-tree (if available)
local neotree_ok, _ = pcall(require, "neo-tree")
if neotree_ok then
    keymap("n", "<leader>nf", ":Neotree reveal<CR>", { desc = "Reveal in file tree" })
    keymap("n", "<leader>ng", ":Neotree git_status<CR>", { desc = "Git status tree" })
    keymap("n", "<leader>nb", ":Neotree buffers<CR>", { desc = "Buffer tree" })
end