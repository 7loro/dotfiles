return {
  'echasnovski/mini.hipatterns',
  version = false,
  config = function()
    -- 1. require를 통해 모듈을 가져와 로컬 변수에 할당합니다.
    local hipatterns = require('mini.hipatterns')

    -- 2. 로컬 변수 'hipatterns'를 사용하여 setup 함수를 호출합니다.
    hipatterns.setup({
      highlighters = {
        -- Highlight standalone 'FIXME', 'HACK', 'TODO', 'NOTE'
        fixme = { pattern = '%f[%w]()FIXME()%f[%W]', group = 'MiniHipatternsFixme' },
        hack  = { pattern = '%f[%w]()HACK()%f[%W]',  group = 'MiniHipatternsHack'  },
        todo  = { pattern = '%f[%w]()TODO()%f[%W]',  group = 'MiniHipatternsTodo'  },
        note  = { pattern = '%f[%w]()NOTE()%f[%W]',  group = 'MiniHipatternsNote'  },

        -- Highlight hex color strings (`#rrggbb`) using that color
        -- 3. 로컬 변수 'hipatterns'를 통해 gen_highlighter에 접근합니다.
        hex_color = hipatterns.gen_highlighter.hex_color(),
      },
    })
  end
}
