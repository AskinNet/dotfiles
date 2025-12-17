return {
    "stevearc/oil.nvim",
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },

    config = function()
        -- winbar с путём текущей директории
        function _G.get_oil_winbar()
            local bufnr = vim.api.nvim_win_get_buf(vim.g.statusline_winid)
            local dir = require("oil").get_current_dir(bufnr)
            if dir then
                return vim.fn.fnamemodify(dir, ":~")
            else
                return vim.api.nvim_buf_get_name(0)
            end
        end

        require("oil").setup({
            default_file_explorer = true,
            view_options = { show_hidden = true },
            buf_options = { buflisted = false },
            win_options = {
                winbar = "%!v:lua.get_oil_winbar()",
            },
            keymaps = {
                ["-"]    = "actions.parent", -- вверх
                ["<BS>"] = "actions.parent", -- вверх по Backspace (только в oil)
                ["q"]    = "actions.close",  -- ← вот это добавляет выход по q:
            },
        })
    end,
}
