-- Clear the terminal and its scrollback, like Cmd+K in other terminals.
rex.bind("cmd+k", "com.superlogical.terminal.clear")
-- The session picker that Rex binds to Cmd+K by default.
rex.bind("cmd+shift+k", "session.switch")

-- A new session that asks for a name, then runs `claude -w NAME` there and
-- names the session NAME. The asking happens in the new session's shell
-- (`claude-session` in .shrc), since Rex has no text prompt for actions.
local claude_session_fallback_dir = os.getenv("HOME") .. "/p/dekudeals"

-- The working directory of the focused pane's foreground program (or its
-- shell), or nil when it isn't a terminal or has none.
local function focused_dir(ctx)
  if ctx.block_id == nil then return nil end
  local p = rex.block.call("com.superlogical.terminal", "process",
    { block_id = ctx.block_id })
  if p == nil then return nil end
  if p.foreground and p.foreground.cwd then return p.foreground.cwd end
  for _, proc in ipairs(p.ancestors or {}) do
    if proc.cwd then return proc.cwd end
  end
  return nil
end

rex.action{
  name  = "claude_worktree_session",
  title = "New Claude Worktree Session",
  description = "Open a session in the focused pane's directory and run claude -w with a name you type.",
  keywords = "claude worktree session",
  run   = function(ctx, args)
    local dir = focused_dir(ctx) or claude_session_fallback_dir
    local s, err = rex.call("session.create", {
      label = "claude",
      initial_windows = { {
        layout = rex.layout.block{
          flavor  = "com.superlogical.terminal.shell",
          options = { cwd = dir, initial_input = "claude-session\n" },
        },
      } },
    })
    if err ~= nil then error(err, 0) end
    if ctx.client_id ~= nil then
      rex.client.queue("session.select", { session_id = s.session_id })
    end
    return { session_id = s.session_id, cwd = dir }
  end,
}
rex.bind("shift+cmd+h", "claude_worktree_session")
