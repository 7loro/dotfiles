-- ── LazyGit (터미널 Git UI) ─────────────────────────────

vim.pack.add({
  { src = "https://github.com/nvim-lua/plenary.nvim", name = "plenary" },
  { src = "https://github.com/kdheepak/lazygit.nvim", name = "lazygit" },
})

-- lazygit 안에서 `e` 키로 파일 열면 현재 Neovim 인스턴스에 열리도록 보장.
-- (lazygit config 의 `os.editPreset: nvim-remote` 와 함께 동작)
vim.g.lazygit_floating_window_use_plenary = 1

-- lazygit 의 `e` 키로 파일을 열면 --remote-tab 으로 새 탭이 만들어지지만,
-- lazygit.nvim 이 floating window 를 닫으면서 원래 탭으로 복귀시키기 때문에
-- 결과적으로 새 탭으로 포커스가 안 옮겨감.
-- LazyGit 호출 직후 그 터미널 buffer 에 TermClose 콜백을 직접 부착해
-- floating window 닫힘 처리가 끝난 뒤(`defer_fn`)에 마지막 탭으로 점프시킴.
function _G.lazygit_with_focus()
  local before = vim.fn.tabpagenr("$")
  vim.cmd("LazyGit")
  vim.schedule(function()
    local term_buf = vim.api.nvim_get_current_buf()
    if not vim.api.nvim_buf_is_valid(term_buf) then return end
    vim.api.nvim_create_autocmd("TermClose", {
      buffer = term_buf,
      once = true,
      callback = function()
        -- floating window 가 닫히고 원래 탭으로 복귀하는 동작이 끝난 뒤에 점프
        vim.defer_fn(function()
          if vim.fn.tabpagenr("$") > before then
            vim.cmd("tablast")
          end
        end, 50)
      end,
    })
  end)
end
