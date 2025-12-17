--
--
-- General Settings
local opt = vim.opt

-- Enable mouse mode, can be useful for resizing splits for example!
opt.mouse = "a"
-- opts.rocks.hererocks = false
-- opts.rocks.enabled = false

-- Store undos between sessions
opt.undofile = true
opt.smarttab = true
opt.smartindent = true
opt.autoindent = true -- Keep identation from previous line

-- Enable break indent
opt.breakindent = true

-- Always show relative line numbers
opt.relativenumber = true

-- Editor behavior
opt.number = true       -- Show line number
opt.swapfile = false    -- Don't use swapfile
opt.writebackup = false -- Don't write backup files
opt.updatetime = 100    -- Faster CursorHold events (LSP)
opt.timeoutlen = 500    -- Time to wait for mapped sequence

-- Splits
opt.splitright = true -- Vertical split to the right
opt.splitbelow = true -- Horizontal split to the bottom

-- Search
opt.ignorecase = true -- Ignore case when searching
opt.smartcase = true  -- Override ignorecase if search has capitals

-- Indentation
opt.expandtab = true -- Use spaces instead of tabs
opt.shiftwidth = 4   -- Shift 4 spaces when tab
opt.tabstop = 4      -- 1 tab == 4 spaces

-- Display
-- opt.colorcolumn = '80' -- Line length marker
opt.cursorline = true -- Highlight cursor line
opt.scrolloff = 2     -- Lines above/below cursor
opt.sidescrolloff = 5 -- Columns left/right of cursor
opt.pumheight = 15    -- Popup menu height
opt.showmode = false  -- Don't show mode (lualine handles it)
opt.list = true       -- Show invisible characters
opt.listchars = 'tab:» ,trail:·,extends:→,precedes:←'

-- Completion
opt.completeopt = 'menu,menuone,noinsert' -- Completion options (for nvim-cmp)

-- Folding (treesitter-based)
opt.foldmethod = 'expr'
opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
opt.foldlevelstart = 99 -- Start with all folds open

-- Wildmenu
opt.wildignorecase = true
opt.wildignore = '.git,.hg,.svn,*.pyc,*.o,*.out,*.jpg,*.jpeg,*.png,*.gif,*.zip,**/tmp/**,*.DS_Store,**/node_modules/**'

vim.opt.termguicolors = true
require("bufferline").setup {}
