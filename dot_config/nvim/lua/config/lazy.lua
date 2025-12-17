-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out,                            "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

-- Leader keys
vim.g.mapleader = " "       -- Space as leader key
vim.g.maplocalleader = "\\" -- Backslash as local leader


-- Setup lazy.nvim
require("lazy").setup({
    spec = {
        -- Import your plugins
        { import = "plugins" },
        { import = "themes" },
    },
    defaults = {
        version = "*",
    },
    -- install = { colorscheme = { "habamax" } },
    install = { colorscheme = { "kanagawa" } },
    checker = { enabled = true },
    rocks = {
        enabled = true,
        hererocks = false -- использует системный luarocks
    }                     -- отключить luarocks полностью
})


require("config.options")

require("config.keymaps")
