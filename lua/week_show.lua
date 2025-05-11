local M = {}

-- 建立一個專屬 namespace 用來管理虛擬文字
M.ns = vim.api.nvim_create_namespace("WeekdayNS")

-- 抓取 yyyy-MM-dd 格式的日期
local function get_date_from_line(line)
  return string.match(line, "%d%d%d%d%-%d%d%-%d%d")
end

-- 使用系統 date 指令取得星期幾
local function get_weekday(date_str)
  local handle = io.popen("date -d " .. date_str .. " '+%A'")
  if handle then
    local result = handle:read("*a")
    handle:close()
    return vim.trim(result)
  end
  return nil
end

-- 每次游標移動就執行這個函式
function M.update_weekday()
  local bufnr = vim.api.nvim_get_current_buf()
  local row = vim.api.nvim_win_get_cursor(0)[1] - 1
  local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1]

  -- 每次都清除整個 buffer 的虛擬文字
  vim.api.nvim_buf_clear_namespace(bufnr, M.ns, 0, -1)

  local date_str = get_date_from_line(line)
  if date_str then
    local weekday = get_weekday(date_str)
    if weekday then
      vim.api.nvim_buf_set_extmark(bufnr, M.ns, row, 0, {
        virt_text = { { "⇨ " .. weekday, "Comment" } },
        virt_text_pos = "eol",
      })
    end
  end
end

-- 綁定 CursorMoved 事件，即時反應
vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
  callback = M.update_weekday,
})

return M
