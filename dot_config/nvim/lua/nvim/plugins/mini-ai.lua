return {
  'echasnovski/mini.ai',
  version = false,
  opts = {
    -- How visit tracking is done
    track = {
      -- Start visit register timer at this event
      -- Supply empty string (`''`) to not do this automatically
      event = 'BufEnter',

      -- Debounce delay after event to register a visit
      delay = 1000,
    },
  },
  config = function()
    require('mini.ai').setup()
  end
}

