lua <<EOF
  require('lualine').setup { 
    options = { 
      theme = 'ayu_mirage',
      component_separators = {left = '|', right = '|'},
      section_separators = {left = '░', right = '░'},
░
    },
    tabline = {
      lualine_a = {'buffers'},
      lualine_b = {},
      lualine_c = {},
      lualine_x = {},
      lualine_y = {},
      lualine_z = {'tabs'}
    }
  }
EOF
