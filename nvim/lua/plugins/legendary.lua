return {{
    "mrjones2014/legendary.nvim",
    dependencies = {
        "kkharji/sqlite.lua",
        "folke/which-key.nvim"
    }, -- sqlite para histórico e which-key para auto-registro
    priority = 10000,
    lazy = false,
    keys = {
        {"<leader>p", "<cmd>Legendary<cr>", desc = "Legendary Command Palette"}
    },
    config = function()
        require("legendary").setup({
            extensions = {
                -- Integração com o que você já tem
                lazy_nvim = true,
                which_key = {
                    auto_register = true
                }
            }
        })
    end
}}
