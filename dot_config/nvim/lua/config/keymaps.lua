-- Telescope Поиск в корне проекта
vim.keymap.set("n", "<leader>fp", function()
    require("telescope.builtin").find_files({
        cwd = vim.fn.getcwd()
    })
end, { desc = "Find files in project root" })

-- Telescope Поиск с интерактивным вводом пути
vim.keymap.set("n", "<leader>fc", function()
    vim.ui.input({ prompt = "Enter path: " }, function(input)
        if input then
            require("telescope.builtin").find_files({ cwd = input })
        end
    end)
end, { desc = "Find files in custom directory" })

-- Telescope Grep в конкретной папке
vim.keymap.set("n", "<leader>gd", function()
    require("telescope.builtin").live_grep({
        search_dirs = { vim.fn.expand("%:p:h") }
    })
end, { desc = "Grep in current directory" })

-- Bufferline
vim.keymap.set("n", "<Tab>", "<Cmd>BufferLineCycleNext<CR>")
vim.keymap.set("n", "<leader>bb", "<Cmd>BufferLinePick<CR>")

-- Oil, file manager
vim.keymap.set("n", "E", "<cmd>Oil<CR>", { desc = "Oil (current window)" })
