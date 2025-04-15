-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Save
vim.keymap.set('n', '<C-s>', '<cmd>write<CR>', { desc = 'Save file' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Flutter dev tools 관련 키 설정
vim.keymap.set('n', '<leader>Fs', ':FlutterRun <CR>', { desc = '[F]lutter [s]tart' })
vim.keymap.set('n', '<leader>Fq', ':FlutterQuit <CR>', { desc = '[F]lutter [q]uit' })
vim.keymap.set('n', '<leader>Fr', ':FlutterRestart <CR>', { desc = '[F]lutter [r]estart' })
vim.keymap.set('n', '<leader>FL', ':FlutterLspRestart <CR>', { desc = '[F]lutter [L]sp restart' })
vim.keymap.set('n', '<leader>Fd', ':FlutterDevTools <CR>', { desc = '[F]lutter [d]evtools' })
vim.keymap.set('n', '<leader>Fl', ':FlutterLogToggle <CR>', { desc = '[F]lutter [l]og toggle' })

-- Quick fix navigation
vim.keymap.set('n', ']q', ':cnext <CR>', { desc = 'Next quickfix' })
vim.keymap.set('n', '[q', ':cprev <CR>', { desc = 'Prev quickfix' })

-- Code action
vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { desc = '[C]ode [A]ction' })
