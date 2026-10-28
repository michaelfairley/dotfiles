-- Clear the terminal and its scrollback, like Cmd+K in other terminals.
rex.bind("cmd+k", "com.superlogical.terminal.clear")
-- The session picker that Rex binds to Cmd+K by default.
rex.bind("cmd+shift+k", "session.switch")
