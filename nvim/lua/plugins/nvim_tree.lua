return {
  "nvim-tree/nvim-tree.lua",
  config = function()
    require("nvim-tree").setup {
      -- Your personal nvim-tree settings here
      update_focused_file = {
        enable = true, -- highlights the file in the tree that matches your current buffer
        update_cwd = false, -- if true, changes tree root to the buffer's directory
        ignore_list = {},
      },
    }
  end,
}
