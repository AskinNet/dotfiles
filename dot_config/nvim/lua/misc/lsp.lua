return {
    -- Mason (package manager for LSP/formatters/linters)
    {
        "williamboman/mason.nvim",
        opts = {},
        keys = {
            { "<leader>m", "<cmd>Mason<CR>", desc = "Open Mason" },
        },
    },

    -- Mason LSP config
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = { "williamboman/mason.nvim" },
        opts = {
            ensure_installed = { "lua_ls", "pyright", "ts_ls" },
            automatic_installation = true,
        },
    },

    -- LSP config
    {
        "neovim/nvim-lspconfig",
        dependencies = { "williamboman/mason-lspconfig.nvim" },
        config = function()
            local lspconfig = require("lspconfig")

            local on_attach = function(_, bufnr)
                local opts = { buffer = bufnr, silent = true }
                vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
                vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
                vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
                vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
                vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
                vim.keymap.set("n", "<Leader>rn", vim.lsp.buf.rename, opts)
                vim.keymap.set("n", "<Leader>ca", vim.lsp.buf.code_action, opts)
                vim.keymap.set("n", "<Leader>d", vim.diagnostic.open_float, opts)
                vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
                vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
            end

            -- Setup servers
            local servers = { "lua_ls", "pyright", "ts_ls" }
            for _, server in ipairs(servers) do
                lspconfig[server].setup({ on_attach = on_attach })
            end
        end,
    },

    -- Formatting
    {
        "stevearc/conform.nvim",
        event = "BufWritePre",
        opts = {
            formatters_by_ft = {
                lua = { "stylua" },
                python = { "black" },
                javascript = { "prettier" },
                typescript = { "prettier" },
            },
            format_on_save = { timeout_ms = 500, lsp_fallback = true },
        },
        keys = {
            { "<Leader>cf", function() require("conform").format({ async = true }) end, desc = "Format buffer" },
        },
    },

    -- Linting
    {
        "mfussenegger/nvim-lint",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            local lint = require("lint")
            lint.linters_by_ft = {
                python = { "ruff" },
                javascript = { "eslint_d" },
                typescript = { "eslint_d" },
            }
            vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
                callback = function() lint.try_lint() end,
            })
        end,
    },
}
