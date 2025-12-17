return {
    -- Escape
    {
        "max397574/better-escape.nvim",
        lazy = false, -- работает сразу при запуске
        config = function()
            require("better_escape").setup({
                -- mapping = { "jk", "kj" }, -- jk ИЛИ kj → Esc
                -- timeout = 200,            -- мс на последовательность
                -- keys = { "i", "c", "s" }, -- режимы: insert, command, select
            })
        end,
    }

}
