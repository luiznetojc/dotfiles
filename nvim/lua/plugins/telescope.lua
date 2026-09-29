return {{
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        {"nvim-telescope/telescope-fzf-native.nvim", build = "make"},
        "nvim-tree/nvim-web-devicons"
    },
    config = function()
        local telescope = require("telescope")
        local builtin = require("telescope.builtin")
        local map = vim.keymap.set

        telescope.setup({
            defaults = {
                -- Move o prompt para o topo e deixa a janela flutuante
                sorting_strategy = "ascending",
                layout_strategy = "horizontal",
                layout_config = {
                    horizontal = {
                        prompt_position = "top",
                        preview_width = 0.55
                    },
                    width = 0.85,
                    height = 0.80
                },
                borderchars = {"─", "│", "─", "│", "┌", "┐", "┘", "└"}, -- Bordas finas
                prompt_prefix = "   ",
                selection_caret = "  ",
                entry_prefix = "  ",
                file_ignore_patterns = {".git/", "node_modules/", "dist/"},
                mappings = {
                    i = {
                        ["<C-j>"] = require("telescope.actions").move_selection_next,
                        ["<C-k>"] = require("telescope.actions").move_selection_previous
                    }
                }
            }
        })

        -- Carregar extensões
        pcall(telescope.load_extension, "fzf")

        map("n", "<C-p>", builtin.find_files, {
            desc = "Quick Open"
        })

        map("n", "<leader>fc", builtin.commands, {
            desc = "Commands"
        })
        map("n", "<leader>ff", builtin.find_files, {
            desc = "Find files"
        })
        map("n", "<leader>fg", builtin.live_grep, {
            desc = "Live grep"
        })
        -- ... outros mapeamentos ...
    end
}}
