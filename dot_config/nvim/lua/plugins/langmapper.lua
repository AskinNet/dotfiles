return {
    "Wansmer/langmapper.nvim",
    lazy = false,
    config = function()
        local langmapper = require("langmapper")
        -- Простая конфигурация без явных layouts
        langmapper.setup()
        -- Это главное — патчит Neovim для корректной работы раскладок
        langmapper.hack_get_keymap()
    end,
}
