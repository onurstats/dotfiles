-- init.lua
local M = {}

-- Only load dependencies in setup to avoid circular references
local function load_dependencies()
  local ok, curl = pcall(require, 'plenary.curl')
  if not ok then
    vim.notify('plenary.nvim is required for claude.nvim', vim.log.levels.ERROR)
    return nil
  end
  return curl
end

-- Configuration
M.config = {
  api_key = vim.env.ANTHROPIC_API_KEY,
  base_url = 'https://api.anthropic.com/v1/messages',
  model = 'claude-3-haiku-20240307',
}

local function update_buffer_content(buf, lines)
  vim.schedule(function()
    -- Safe buffer check inside scheduled context
    if buf and vim.api.nvim_buf_is_valid(buf) then
      vim.api.nvim_buf_set_option(buf, 'modifiable', true)
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
      vim.api.nvim_buf_set_option(buf, 'modifiable', false)
    end
  end)
end

local function create_claude_buffer()
  -- Create new window
  vim.cmd 'vsplit'
  local win = vim.api.nvim_get_current_win()

  -- Create buffer
  local buf = vim.api.nvim_create_buf(false, true)

  -- Basic buffer setup
  local buf_options = {
    buftype = 'nofile',
    swapfile = false,
    bufhidden = 'wipe',
    modifiable = true,
  }

  for k, v in pairs(buf_options) do
    vim.api.nvim_buf_set_option(buf, k, v)
  end

  -- Set the buffer in the window
  vim.api.nvim_win_set_buf(win, buf)

  -- Set window options
  local win_options = {
    wrap = true,
    number = false,
    relativenumber = false,
    signcolumn = 'no',
  }

  for k, v in pairs(win_options) do
    vim.api.nvim_win_set_option(win, k, v)
  end

  return buf, win
end

function M.send_to_claude(text)
  local curl = load_dependencies()
  if not curl then
    return
  end

  if not M.config.api_key then
    vim.notify('Error: ANTHROPIC_API_KEY not set', vim.log.levels.ERROR)
    return
  end

  -- Debug: Print first few characters of API key
  local api_key = M.config.api_key
  if api_key then
    vim.notify('API Key starts with: ' .. string.sub(api_key, 1, 8) .. '...', vim.log.levels.INFO)
  else
    vim.notify('No API key found!', vim.log.levels.ERROR)
    return
  end

  -- Create buffer and get window
  local buf, win = create_claude_buffer()

  -- Set initial content
  update_buffer_content(buf, {
    'Sending request to Claude...',
    '',
    'Query: ' .. text,
  })

  local headers = {
    ['x-api-key'] = M.config.api_key,
    ['anthropic-version'] = '2023-06-01',
    ['content-type'] = 'application/json',
  }

  local data = {
    messages = {
      {
        role = 'user',
        content = text,
      },
    },
    model = M.config.model,
    max_tokens = 1024,
  }

  -- Make the API request
  curl.post(M.config.base_url, {
    headers = headers,
    body = vim.fn.json_encode(data),
    callback = function(response)
      local lines
      if response.status == 200 then
        local ok, result = pcall(vim.fn.json_decode, response.body)
        if ok and result and result.content and result.content[1] then
          local content = result.content[1].text
          lines = vim.split(content, '\n', true)
        else
          lines = {
            'Error: Failed to parse response',
            'Raw response: ' .. vim.inspect(response),
          }
        end
      else
        lines = {
          'Error: ' .. response.status,
          'Message: ' .. (response.body or 'No error message'),
        }
      end

      -- Update buffer content safely
      update_buffer_content(buf, lines)

      -- Set filetype after content is set
      vim.schedule(function()
        if buf and vim.api.nvim_buf_is_valid(buf) then
          vim.api.nvim_buf_set_option(buf, 'filetype', 'markdown')
        end
      end)
    end,
  })
end

function M.send_visual_selection()
  local start_pos = vim.fn.getpos "'<"
  local end_pos = vim.fn.getpos "'>"
  local lines = vim.api.nvim_buf_get_lines(0, start_pos[2] - 1, end_pos[2], false)
  local text = table.concat(lines, '\n')
  M.send_to_claude(text)
end

function M.setup(opts)
  -- Merge configs
  M.config = vim.tbl_deep_extend('force', M.config, opts or {})

  -- Create commands
  vim.api.nvim_create_user_command('ClaudeSend', function()
    M.send_visual_selection()
  end, { range = true, desc = 'Send selection to Claude AI' })

  vim.api.nvim_create_user_command('ClaudeAsk', function(opts)
    M.send_to_claude(opts.args)
  end, { nargs = 1, desc = 'Ask Claude AI a question' })

  vim.notify('Claude.nvim initialized!', vim.log.levels.INFO)
end

return M
