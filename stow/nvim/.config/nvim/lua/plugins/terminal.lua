return {
  "akinsho/toggleterm.nvim",
  version = "*",
  config = function()
    require("toggleterm").setup {
      -- General options
      size = 20, -- Can be a number or a function
      open_mapping = [[<C-t>]], -- Key to toggle the terminal
      direction = "float", -- 'float', 'horizontal', or 'vertical'
      terminal_mappings = true, -- Enable mappings in terminal mode
      insert_mappings = true, -- Enable mappings in insert mode
      -- Other options...
    }

    -- Create a specific terminal for bottom
    local btm_term = require("toggleterm.terminal").Terminal:new {
      cmd = "btm",
      direction = "float", -- Or 'horizontal', 'vertical'
      hidden = true, -- Keep it hidden until toggled
      -- Other options specific to this terminal
    }

    -- Keybinding to toggle the bottom terminal
    vim.keymap.set("n", "<leader>terminal btm", function() btm_term:toggle() end, { desc = "Toggle Bottom terminal" })
  end,
}
