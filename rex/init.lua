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

-- The root of the git repository containing dir, or dir itself when it isn't
-- in one. From a linked worktree (such as a Claude one under
-- .claude/worktrees/), this is the main repository's root: the common git dir
-- is the main repo's .git. A submodule's common dir is under its
-- superproject's .git/modules/, so that case falls back to --show-toplevel.
local function git_root(dir)
  local r = rex.exec({ "git", "rev-parse", "--path-format=absolute",
    "--git-common-dir", "--show-toplevel" }, { cwd = dir, timeout = 5 })
  if r == nil or not r.ok then return dir end
  local common, toplevel = r.stdout:match("^([^\n]+)\n([^\n]+)")
  if common == nil then return dir end
  return common:match("^(.+)/%.git$") or toplevel
end

rex.action{
  name  = "claude_worktree_session",
  title = "New Claude Worktree Session",
  description = "Open a session at the git root (the main repo's, from a worktree) of the focused pane's directory and run claude -w with a name you type.",
  keywords = "claude worktree session",
  run   = function(ctx, args)
    local dir = git_root(focused_dir(ctx) or claude_session_fallback_dir)
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
      -- Over a remote connection the app may not have heard about the new
      -- session yet, and session.select fails with "not found on this
      -- server". Refreshing first makes it fetch the session list.
      rex.client.queue("session.refresh")
      rex.client.queue("session.select", { session_id = s.session_id })
    end
    return { session_id = s.session_id, cwd = dir }
  end,
}
rex.bind("shift+cmd+h", "claude_worktree_session")
