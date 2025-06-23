Snacks = require "snacks"

return {
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      local bufferline = require "bufferline"
      bufferline.setup {
        options = {
          separator_style = "slant", -- "slant" | "slope" | "thick" | "thin" | { 'any', 'any' },
          diagnostics = "nvim_lsp",
          indicator = {
            icon = "▎", -- this should be omitted if indicator style is not 'icon'
            style = "icon",
          },
          offsets = {
            {
              filetype = "NvimTree",
              text = "File Explorer",
              highlight = "Directory",
              text_align = "left",
              separator = true, -- use a "true" to enable the default, or set your own character
            },
          },
          close_command = function(n) Snacks.bufdelete(n) end,
          right_mouse_command = function(n) Snacks.bufdelete(n) end,
          show_buffer_close_icons = false,
          always_show_bufferline = true,
          style_preset = bufferline.style_preset.no_italic,
          custom_filter = function(buf_number)
            -- filter out filetypes you don't want to see
            if vim.bo[buf_number].filetype ~= "qf" then return true end
          end,
          -- offsets = {
          --   {
          --     filetype = "snacks_layout_box",
          --     text = "",
          --     highlight = "EcovimNvimTreeTitle",
          --     text_align = "center",
          --     separator = true,
          --   },
          -- },
        },
      }
    end,
    keys = {
      -- { "<A-1>", "<cmd>BufferLineGoToBuffer 1<CR>" },
      -- { "<A-2>", "<cmd>BufferLineGoToBuffer 2<CR>" },
      -- { "<A-3>", "<cmd>BufferLineGoToBuffer 3<CR>" },
      -- { "<A-4>", "<cmd>BufferLineGoToBuffer 4<CR>" },
      -- { "<A-5>", "<cmd>BufferLineGoToBuffer 5<CR>" },
      -- { "<A-6>", "<cmd>BufferLineGoToBuffer 6<CR>" },
      -- { "<A-7>", "<cmd>BufferLineGoToBuffer 7<CR>" },
      -- { "<A-8>", "<cmd>BufferLineGoToBuffer 8<CR>" },
      -- { "<A-9>", "<cmd>BufferLineGoToBuffer 9<CR>" },
      { "<Leader>bl", "<cmd>BufferLineCloseLeft<CR>", desc = "Close Left" },
      { "<Leader>bd", "<cmd>BufferLinePickClose<CR>", desc = "Close Pick Close" },
      { "<Leader>br", "<cmd>BufferLineCloseRight<CR>", desc = "Close Right" },
      { "<Leader>bn", "<cmd>BufferLineMoveNext<CR>", desc = "Move next" },
      { "<Leader>bb", "<cmd>BufferLinePick<CR>", desc = "Pick Buffer" },
      { "<Leader>bP", "<cmd>BufferLineTogglePin<CR>", desc = "Pin/Unpin Buffer" },
      { "<Leader>bsd", "<cmd>BufferLineSortByDirectory<CR>", desc = "Sort by directory" },
      { "<Leader>bse", "<cmd>BufferLineSortByExtension<CR>", desc = "Sort by extension" },
      { "<Leader>bsr", "<cmd>BufferLineSortByRelativeDirectory<CR>", desc = "Sort by relative dir" },
    },
  },
}
