return {
    -- File explorer
    -- {
    --   "nvim-neo-tree/neo-tree.nvim",
    --   dependencies = { "nvim-lua/plenary.nvim", "MunifTanjim/nui.nvim" },
    --   keys = {
    --     { "<Leader>e", "<cmd>Neotree toggle<CR>", desc = "Toggle file explorer" },
    --   },
    -- },
    -- lua/plugins/oil.lua
    --
    --
    -- Fuzzy finder
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        keys = {
            { "<Leader>ff", "<cmd>Telescope find_files<CR>", desc = "Find files" },
            { "<Leader>fg", "<cmd>Telescope live_grep<CR>",  desc = "Live grep" },
            { "<Leader>fb", "<cmd>Telescope buffers<CR>",    desc = "Buffers" },
            { "<Leader>fh", "<cmd>Telescope help_tags<CR>",  desc = "Help tags" },
        },
    },

    -- Git signs
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            current_line_blame = true,
        },
        keys = {
            { "<Leader>gs", "<cmd>Gitsigns stage_hunk<CR>", desc = "Stage hunk" },
            { "<Leader>gr", "<cmd>Gitsigns reset_hunk<CR>", desc = "Reset hunk" },
            { "<Leader>gb", "<cmd>Gitsigns blame_line<CR>", desc = "Blame line" },
            { "<Leader>gd", "<cmd>Gitsigns diffthis<CR>",   desc = "Diff this" },
        },
    },

    -- Diagnostics list
    {
        "folke/trouble.nvim",
        cmd = "Trouble",
        keys = {
            { "<Leader>tt", "<cmd>Trouble diagnostics toggle<CR>", desc = "Toggle diagnostics" },
        },
    },

    -- Which key
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {},
        keys = {
            { "<leader>?", function() require("which-key").show({ global = false }) end, desc = "Buffer Keymaps" },
        },
    },
}
