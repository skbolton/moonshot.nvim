--[[
Fenced code API.

Fences abstract over fenced code blocks in markdown code and give an API
into accessing their contents and telling them to display results. To
create a fence simply pass in the initial starting line and ending line
of the fence. Fence's are built using Neovim's extmarks which helps a 
fence be able to move around a file without causing any issues.

fences abstract over fenced code blocks in markdown files and give an API
into executing their contents and displaying the results. To create a fence
simply pass in the initial starting and ending lines of the fence. Fences
are built using Neovim extmarks which means that they can easily be tracked
as changes happen to a file no problem.

For example if we had a file with the given contents:
    
    ```sh
    echo 'hi'
    ```

We could build a fence by calling:

    Fence.new(1, 3)

Then later we could have the fence run its contents by calling:

    Fence.execute(fence)

Given the previous file example we would be left with:

    ```sh
    echo 'hi'
    ```
    hi
--]]
local Fence = {}

local api = vim.api

-- CONSTANTS
-- for the time being we always target the current buffer
local BUFFER = 0
-- all extmarks will be on the first column every time
local COLUMN = 0
-- namespace for all extmarks
local NS = api.nvim_create_namespace("bastille") 


-- Create a new fence based on starting and ending lines
Fence.new = function(starting_line, ending_line) 
  local open = api.nvim_buf_set_extmark(BUFFER, NS, starting_line, COLUMN, {})
  local close = api.nvim_buf_set_extmark(BUFFER, NS, ending_line, COLUMN, {})
  return {open, close}
end

-- Match against possible opening `fence` syntax
Fence.match_opening = function(line)
  return string.match(line, "^```(%w+)")
end

-- Match against possible closing `fence` syntax
Fence.match_closing = function(line)
  return string.match(line, "^```$")
end

-- returns whether a line number is in `fence`.
Fence.in_fence = function(fence, line_nr)
  local beginning = Fence.starts_at(fence)
  local ending = Fence.ends_at(fence)

  return line_nr >= beginning and line_nr <= ending
end

-- Get the inner contents of a `fence` block
Fence.contents = function(fence)
  -- extmarks return {row, col} columns don't apply to fences
  local beginning = Fence.starts_at(fence)
  local ending = Fence.ends_at(fence)
  -- extract text between the marks
  -- NOTE: This nvim api takes index based numbers
  -- due to this beginning actuall becomes the line after the fence open
  -- but close needs to be pulled back one so we don't get the closing fence
  return api.nvim_buf_get_lines(BUFFER, beginning, ending - 1, false)
end

-- Execute a `fence` block and output the results
Fence.execute = function(fence)
  local contents = Fence.contents(fence)
    -- TODO: Figure out multi line executions
  local results = vim.fn.split(vim.fn.system(contents[1]), "\n")
  Fence.add_results(fence, results)
end

-- Get the line number that a `fence` starts at
Fence.starts_at = function(fence)
  return api.nvim_buf_get_extmark_by_id(BUFFER, NS, fence[1], {})[1]
end

-- Get the line number that a `fence` ends at
Fence.ends_at = function(fence)
  return api.nvim_buf_get_extmark_by_id(BUFFER, NS, fence[2], {})[1]
end

-- Add `results` lines to `fence`
Fence.add_results = function(fence, results)
  Fence.clean_results(fence)
  table.insert(results, 1, ":RESULTS:")
  vim.fn.append(Fence.ends_at(fence), results)
end

-- Ensure that `fence` is not displaying any results
Fence.clean_results = function(fence)
  local close_line = Fence.ends_at(fence)
  local line_after_close = close_line + 1
  -- NOTE: Again an index based api so are - 1
  local results_content = api.nvim_buf_get_lines(BUFFER, close_line, line_after_close, false)[1]
  if results_content ~= "" and results_content ~= nil then
    -- TODO: Find better way of deleting a paragraph at an area w/o moving cursor
    -- In the meantime the caller stores where the cursor was and returns it
    api.nvim_win_set_cursor(BUFFER, {line_after_close, COLUMN})
    api.nvim_command("normal d}")
  end
end

-- Destroy a fence
Fence.destroy = function(fence)
  api.nvim_buf_del_extmark(BUFFER, NS, fence[1])
  api.nvim_buf_del_extmark(BUFFER, NS, fence[2])
end


return Fence

