return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      spec = {
        { "<leader>f", group = "find" },
        { "<leader>s", group = "split" },
        { "<leader>b", group = "buffer" },
        { "<leader>x", group = "diagnostics" },
      },
    },
  },
}
