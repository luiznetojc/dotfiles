return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    -- Isso substitui o visual do vim.ui.select (menus de escolha)
    -- e do vim.ui.input (caixas de texto)
    input = { enabled = true },
    select = { enabled = true },
    -- Opcional: Um dashboard bonitão ao abrir o Neovim
    dashboard = { enabled = true },
    -- Notificações modernas estilo VS Code
    notifier = { enabled = true },
  },
  keys = {
    -- Atalho para ver o histórico de notificações (estilo central de notificações)
    { "<leader>un", function() Snacks.notifier.show_history() end, desc = "Histórico de Notificações" },
  },
}