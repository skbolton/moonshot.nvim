local Fence = require'fence'
local api = vim.api

local Moonshot = {}

local fences = {}

-- Parse lines in buffer to build Fences from markdown fence blocks
Moonshot.build_fences = function()
  Moonshot.destroy_fences()
  local lines = vim.fn.readfile(api.nvim_buf_get_name(0))
  local opens = {}
  local closes = {}
  for line_number, line in pairs(lines) do
    if Fence.match_opening(line) then
      table.insert(opens, line_number)
    elseif Fence.match_closing(line) then
      table.insert(closes, line_number)
    end
  end

  for idx, line_number in pairs(opens) do
    table.insert(fences, Fence.new(line_number, closes[idx]))
  end
end

-- Run code in fences and output the results
Moonshot.run_all = function()
  for _, fence in pairs(fences) do
    Fence.execute(fence)
  end
end

-- Run code only at cursor location
Moonshot.run_cursor = function()
  local cursor_line = api.nvim_win_get_cursor(0)[1]
  for _, fence in pairs(fences) do
    if Fence.in_fence(fence, cursor_line) then
      local start_cursor = api.nvim_win_get_cursor(0)
      Fence.execute(fence)
      api.nvim_win_set_cursor(0, start_cursor)
    end
  end
end

-- Remove results from all fences
Moonshot.clean_all = function()
  -- TODO: Figure out a better of deleting without Fence needing to move the cursor
  -- until then get a reference to where cursor was before job
  local start_cursor = api.nvim_win_get_cursor(0)
  for _, fence in pairs(fences) do
    Fence.clean_results(fence)
  end
  -- put cursor back in old spot or closest to it
  -- buffer might have gotten smaller so that old cursor
  -- position wouldn't be available and we just place at bottom
  local new_line_count = api.nvim_buf_line_count(0)
  local new_cursor_row = math.min(start_cursor[1], new_line_count)
  api.nvim_win_set_cursor(0, {new_cursor_row, 0})
end

-- Remove result from fence under cursor
Moonshot.clean_cursor = function()
  local cursor_line = api.nvim_win_get_cursor(0)[1]
  for _, fence in pairs(fences) do
    if Fence.in_fence(fence, cursor_line) then
      Fence.clean_results(fence)
    end
  end
end

Moonshot.destroy_fences = function()
  for _, fence in pairs(fences) do
    Fence.destroy(fence)
  end

  fences = {}
end

return Moonshot
