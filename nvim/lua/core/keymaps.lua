local map = vim.keymap.set

map("n", "<Esc>", "<cmd>nohlsearch<CR><Esc>", { desc = "Clear highlights" })
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

map("n", "<C-h>", "<C-w><C-h>", { desc = "Focus left split" })
map("n", "<C-l>", "<C-w><C-l>", { desc = "Focus right split" })
map("n", "<C-j>", "<C-w><C-j>", { desc = "Focus lower split" })
map("n", "<C-k>", "<C-w><C-k>", { desc = "Focus upper split" })

map("n", "<leader>w", "<cmd>w<CR>", { desc = "Save file" })
map("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit window" })
map("n", "<leader>Q", "<cmd>qa!<CR>", { desc = "Quit all" })

map("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete buffer" })

map("n", "<leader>sv", "<cmd>vsplit<CR>", { desc = "Vertical split" })
map("n", "<leader>sh", "<cmd>split<CR>", { desc = "Horizontal split" })

map({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to system clipboard" })
map("n", "<leader>Y", [["+Y]], { desc = "Yank line to system clipboard" })
map({ "n", "v" }, "<leader>d", [["_d]], { desc = "Delete without yanking" })

local goto_line = function()
  local line = tonumber(vim.fn.input("Go to line: "))
  if not line then
    return
  end

  local max_line = vim.api.nvim_buf_line_count(0)
  line = math.max(1, math.min(line, max_line))
  vim.api.nvim_win_set_cursor(0, { line, 0 })
end

map("n", "<C-g>", goto_line, { desc = "Go to line" })
map("n", "<leader>gl", goto_line, { desc = "Go to line" })

map('n', '<leader>n', function()
  vim.opt.relativenumber = not vim.opt.relativenumber:get()
end, { desc = "Alternar números de linha relativos" })
