require("config.lazy")

-- 간단한 메시지 출력 테스트 (VSCode 내에서 Neovim이 로드되었는지 확인)
vim.cmd([[autocmd VimEnter * echom "VSCode Neovim 설정이 로드되었습니다."]])
