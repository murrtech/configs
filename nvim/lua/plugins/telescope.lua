return {
  "nvim-telescope/telescope.nvim",
  opts = function()
    local actions = require "telescope.actions"

    require("telescope").setup {
      defaults = {
        layout_strategy = "vertical",
        style = "border",
        layout_config = {
          vertical = {
            height = 0.99,
            preview_cutoff = 0,
            prompt_position = "bottom",
            width = 0.9,
          },
        },

        -- Improved file sorting and searching
        file_sorter = require("telescope.sorters").get_fzf_sorter,
        generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,

        -- Better matching
        path_display = { "truncate" },
        selection_caret = "  ",

        -- Improved searching
        vimgrep_arguments = {
          "rg",
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
          "--hidden",
          "--glob=!.git/",
        },

        file_ignore_patterns = {
          "node_modules/.*",
          "%.git/.*",
          "build/.*",
          "target/.*",
          ".*%.lock",
          "%.DS_Store",
          "%.class",
          "%.pdf",
          "%.mkv",
          "%.mp4",
          "%.zip",
        },

        mappings = {
          i = {
            ["<CR>"] = "select_default_no_preview",
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
            ["<C-u>"] = false,
            ["<C-d>"] = false,
          },
        },

        -- Performance settings
        cache_picker = {
          num_pickers = 10,
          limit_entries = 1000,
        },

        -- Better searching
        find_command = {
          "fd",
          "--type",
          "f",
          "--strip-cwd-prefix",
          "--hidden",
          "--exclude",
          ".git",
        },
      },

      pickers = {
        find_files = {
          hidden = true,
          no_ignore = false,
          follow = true,
        },
        live_grep = {
          additional_args = function()
            return { "--hidden" }
          end,
        },
      },

      extensions = {
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = "smart_case",
        },
      },
    }
  end,
  dependencies = {
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
    },
  },
}
