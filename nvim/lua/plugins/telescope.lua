return {
  "nvim-telescope/telescope.nvim",
  opts = function()
    require("telescope").setup {
      defaults = {
        layout_strategy = "vertical",
        layout_config = {
          vertical = {
            height = 0.99,
            preview_cutoff = 0,
            prompt_position = "bottom",
            width = 0.9,
          },
        },
        file_ignore_patterns = {
          "node_modules/.*",
          "%.git/.*",
          "build/.*",
          "target/.*",
          ".*%.lock",
        },
        mappings = {
          i = {
            ["<CR>"] = "select_default_no_preview",
          },
        },
      },
    }
  end,
}
