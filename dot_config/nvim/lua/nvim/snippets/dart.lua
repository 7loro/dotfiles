-- vim.fn.stdpath('config')는 Neovim 설정 디렉토리 (~/.config/nvim) 경로를 가져옵니다.
local config_path = vim.fn.stdpath('config')
local flutter_snippets_dir = config_path .. "/lua/nvim/snippets/flutter"

-- Lua의 'require' 함수가 사용할 기본 경로 정의
local base_require_path = "nvim.snippets.flutter"

-- 디버그: 스니펫 디렉토리 경로 출력
-- print("DEBUG: Flutter Snippet Directory: " .. flutter_snippets_dir)

local files_processed = 0 -- 디버그: 처리된 파일 수 카운트
-- 디렉토리 내 파일 목록을 순회 (vim.fs.dir 사용)
for filename, filetype in vim.fs.dir(flutter_snippets_dir) do
  -- 파일 타입이 'file'이고 '.lua'로 끝나는지 확인
  if filetype == 'file' and filename:match('%.lua$') then
    files_processed = files_processed + 1 -- 카운트 증가
    local module_name = filename:gsub('%.lua$', '')
    -- 전체 'require' 경로를 조합합니다. (예: "nvim.snippets.flutter.widgets")
    local require_path = base_require_path .. "." .. module_name

    -- 디버그: require 시도 경로 출력
    -- print("DEBUG: Attempting to require: " .. require_path)

    -- pcall (protected call)을 사용하여 안전하게 모듈 로드 시도
    local ok, loaded_module = pcall(require, require_path)

    if ok then
      -- 디버그: 로드 성공 출력 및 로드된 모듈 타입 확인
      -- print("DEBUG: Successfully required: " .. require_path .. " (Type: " .. type(loaded_module) .. ")")

      -- *** 중요: 여기서 로드된 'loaded_module' (스니펫 정의 테이블)을 사용하시는 스니펫 엔진에 전달해야 합니다. ***
      -- 예시 (LuaSnip 사용 시):
      -- 로드된 모듈이 유효한 테이블인지 확인 후
      if type(loaded_module) == 'table' then
          -- 'dart' 파일 타입에 대해 로드된 스니펫을 LuaSnip에 추가
          -- 이 코드는 사용하시는 LuaSnip 설정에 따라 달라집니다.
          require("luasnip").add_snippets("dart", loaded_module, { name = module_name })
      end

    else
      -- 모듈 로딩 중 오류가 발생한 경우 에러 메시지 표시 (기존 코드)
      vim.notify("Error loading snippet module: " .. require_path .. "\n" .. tostring(loaded_module), vim.log.levels.ERROR)
       -- 디버그: 로드 실패 출력
      print("DEBUG: Error requiring: " .. require_path .. "\n" .. tostring(loaded_module))
    end
  end
end

-- 디버그: 디렉토리 순회 완료 및 파일 수 출력
-- print("DEBUG: Finished iterating snippet directory. Processed " .. files_processed .. " lua files.")
