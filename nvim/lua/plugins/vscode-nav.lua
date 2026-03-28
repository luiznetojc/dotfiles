return {
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
    config = function(_, opts)
      require("trouble").setup(opts)
      vim.keymap.set("n", "<leader>t", "<cmd>Trouble diagnostics toggle<CR>", { desc = "Toggle trouble" })
      vim.keymap.set("n", "<leader>cs", "<cmd>Trouble symbols toggle focus=false<CR>", { desc = "Document symbols" })
    end,
  },
}
