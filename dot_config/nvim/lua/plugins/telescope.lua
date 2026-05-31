return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup()
      -- Mapeos personalizados (opcional)
      vim.keymap.set("n", "<leader>ff", ":Telescope find_files<CR>", { desc = "Find Files" })
      vim.keymap.set("n", "<leader>fg", ":Telescope live_grep<CR>", { desc = "Live Grep" })
      vim.keymap.set("n", "<leader>fb", ":Telescope buffers<CR>", { desc = "Find Buffers" })
    end,
  },
}
