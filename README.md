# dotfiles

Config for my Macs (a laptop and a desktop), applied with
[mise bootstrap](https://mise.jdx.dev/bootstrap.html). `mise.toml` declares
everything: which files get linked into `~`, which settings get merged into app
config files, Homebrew/App Store packages, and macOS preferences.

Most changes here are made by an LLM. This file is written so one can make them
correctly; humans should find it useful too.

## Day to day

```sh
cd ~/p/dotfiles
git pull && mise bootstrap   # bring this machine up to date
mise bootstrap --dry-run     # preview what bootstrap would change
mise bootstrap status        # drift between this machine and the config
mise dot status              # dotfile entries only
mise run settings-drift      # app settings that changed locally (see below)
```

After changing anything, commit, push, and run `git pull && mise bootstrap` on
the other Mac.

## How each kind of config is managed

| Kind | Examples | Mechanism | To change it |
|---|---|---|---|
| Linked files | `.emacs`, `.emacs.d`, `.gitignore`, `.inputrc`, `.psqlrc`, `bundle/config`, `ghostty/config`, `zed/*.json`, `claude/CLAUDE.md` | `[dotfiles]` entry, symlink into `~` | Edit the file in the repo (or in the app; it's the same file) |
| Shell and git config | `.zshrc`, `.bashrc`, `.shrc`, `.gitconfig` | Not linked. `~/.zshrc`, `~/.bashrc` and `~/.gitconfig` are machine-local files; mise owns only a marked `mise:dotfiles` block at the top of each (from `snippets/zshrc` etc.) that loads the repo version | Edit the repo file |
| Merged app settings | Claude Code, Codex, Gemini | `merge` entries: mise owns only the keys in `snippets/*-settings*.json` / `snippets/codex-config*.toml`; the app owns the rest of the file | Edit the snippet, not the app |
| Packages | `[bootstrap.packages]` | `brew:`, `brew-cask:`, `mas:` entries | `mise bootstrap packages use brew:foo` from this directory |
| macOS settings | `[bootstrap.macos.*]` | Named keys plus raw `[bootstrap.macos.defaults."<domain>"]` | Edit `mise.toml` |
| mise activation | `[bootstrap.mise_shell_activate]` | mise writes `mise:activate` blocks into `~/.zprofile` (shims) and `~/.zshrc` | Edit `mise.toml` |

Shell layout: `.shrc` holds what bash and zsh share (aliases, env vars, PATH);
`.zshrc` and `.bashrc` source it and add shell-specific setup. In zsh,
`typeset -U PATH path` removes duplicate PATH entries.

Not managed: `.xprofile` (Linux only) and `iterm2-profile.json` (an old iTerm2
profile, imported by hand).

### Machine-local files

`~/.zshrc`, `~/.bashrc`, `~/.gitconfig`, `~/.zprofile`, `~/.zshenv` and
`~/.profile` are not in the repo on purpose. Installers append PATH lines to
them, and `git config --global` writes to `~/.gitconfig`; keeping them local
means none of that dirties the repo. If a line there should be on both Macs,
move it into `.shrc` (shell) or `.gitconfig` (git) and delete it from the
local file. Never put the managed block's contents anywhere else, and never
edit between `# >>> mise:… >>>` markers.

### Merged app settings

Each app rewrites its own settings file, so a symlink would get clobbered.
Instead:

- `merge = true` snippets (`snippets/claude-settings.json`,
  `snippets/codex-config.toml`, `snippets/gemini-settings.json`) are enforced:
  if the app changes one of these keys, the next bootstrap changes it back.
- `merge = "missing"` snippets (`*-defaults.*`) are defaults: only filled in
  when the key is unset, so the app (e.g. `/model`) can change them.

`mise run settings-drift` (`bin/settings-drift`) compares the live files to the
snippets and lists keys the app changed, defaults that differ, and keys that
exist only on this machine. Run it before `mise bootstrap` when you've changed
app settings, then either copy keys into a snippet or add them to `IGNORE` at
the top of the script. Never share keys that hold machine paths, per-project
state, or anything sensitive (Claude Code's `autoMode` describes production
systems; keep it out).

## Recipes

**Add a dotfile.** Copy it into the repo (use a plain directory name; see
naming rules below), add `"~/path" = { source = "repo/path" }` to `[dotfiles]`,
confirm the copy is identical (`cmp`), then
`mise dot apply --force ~/path` to replace the original with a link.

**Add app settings that the app also writes.** Put only the keys you want to
share in `snippets/<app>.json|toml|yaml` (no comments; JSONC can't be merged)
and add `"~/path/to/file/dotfiles" = { source = "snippets/…", merge = true }`.

**Add a package.** `mise bootstrap packages use brew:<formula>` (or
`brew-cask:<cask>`, `mas:<numeric id>`; find IDs with `mas search`). It writes
the entry into `mise.toml` and installs it. To find things installed with plain
`brew`, run `mise bootstrap packages import --manager brew --dry-run`.
`[bootstrap.brew] adopt = true` is set, so a cask whose app was already
installed by hand takes that copy over instead of replacing it (keeping its
macOS permissions and version); add `adopt = false` to a cask to replace it.

**Add a macOS setting.** Change it in System Settings and compare
`defaults read <domain>` before and after (or run `defaults export <domain> -`
on the likely domains) to find the key. Prefer a named key from
[the docs](https://mise.jdx.dev/bootstrap/macos-defaults.html); otherwise add it
under `[bootstrap.macos.defaults."<domain>"]`. Use `[[bootstrap.macos.defaults_entries]]`
with `host = "current"` for `-currentHost` preferences. Check with
`mise bootstrap macos defaults apply --dry-run`, apply, then
`killall Dock Finder SystemUIServer`.

**Make the two Macs differ.** Machine-specific setup goes in a module file,
`mise.<name>.toml`, which loads only on Macs that select it in the
machine-local `~/.config/mise/miserc.local.toml` (never in the repo):

```toml
# ~/.config/mise/miserc.local.toml on the desktop
env = ["desktop"]
```

`mise.desktop.toml` holds desktop-only setup (f.lux and the Logitech apps;
see below). To add a
laptop-only module, create `mise.laptop.toml` and set `env = ["laptop"]` on the
laptop. Check with `mise config` (lists the files that loaded) and preview the
other machine with `mise -E <name> bootstrap status`. Dropping a module from
`env` stops applying it but leaves its files and settings in place;
`mise bootstrap unapply <name> --dry-run` shows what it would remove.

**Logitech G HUB (desktop).** G HUB (`lghub.app`, the `logitech-g-hub` cask
in `mise.desktop.toml`) configures the G502 X mouse and the C920 webcam,
including the camera's exposure, focus, and crop. Its settings are one JSON
document in a SQLite database that it rewrites constantly, so instead of a
dotfile there's a snapshot, `logitech/ghub-settings.json`, managed by
`bin/ghub-settings`:

- after changing anything in G HUB: `mise run ghub-save`, review `git diff`,
  commit;
- on a fresh desktop, after bootstrap installs G HUB: open G HUB once so it
  creates its database, then `mise run ghub-restore` (quits G HUB, backs up
  `settings.db`, writes the snapshot, reopens G HUB).

The snapshot leaves out G HUB's `analytics` host ID but keeps device serial
numbers, which G HUB needs to match profiles to devices. Logi Tune isn't
managed: G HUB covers the webcam, and Logi Tune's settings are encrypted per
machine and can't be carried over anyway.

**Set up a new Mac.** Install Homebrew and mise, then run the line for its
role. It records the role in `~/.config/mise/miserc.local.toml` (so every later
`mise bootstrap` uses it) and bootstraps from the repo:

```sh
# desktop
mkdir -p ~/.config/mise && echo 'env = ["desktop"]' > ~/.config/mise/miserc.local.toml && mise bootstrap --from git@github.com:michaelfairley/dotfiles.git --from-dir ~/p/dotfiles

# laptop
mkdir -p ~/.config/mise && echo 'env = ["laptop"]' > ~/.config/mise/miserc.local.toml && mise bootstrap --from git@github.com:michaelfairley/dotfiles.git --from-dir ~/p/dotfiles
```

A `pre-packages` hook in `mise.toml` stops any bootstrap, before it changes
anything, unless exactly one of `desktop` or `laptop` is selected. A role with
no module file (there's no `mise.laptop.toml` yet) just loads nothing extra.
Hooks don't see `$MISE_ENV`; the hook reads the `mise_env` template variable
instead.

If files already exist where links should go, bootstrap refuses them: check
`mise dot diff`, keep whichever version you want in the repo, then run
`mise bootstrap --force-dotfiles`. `mas:` entries need an App Store sign-in.

## Rules and gotchas

- **Check the mise docs for the installed version, not from memory.** These
  features are new and change between releases. Raw docs live at
  `https://raw.githubusercontent.com/jdx/mise/v<version>/docs/` (see
  `docs/bootstrap/` and `docs/dotfiles/`); `mise --version` gives the version.
  Keep both Macs on the same mise (`brew upgrade mise`).
- **Nothing is undone by deleting config.** Removing a package, macOS setting,
  merge snippet, or shell-activation key from `mise.toml` leaves the machine
  as it is. Reset a setting with `defaults delete <domain> <key>`; remove a
  block by hand.
- **Never run `mise bootstrap packages prune` without `--dry-run`.** It
  uninstalls every formula not declared here, including `mise` itself.
- **`.gitignore` is the global gitignore** (linked to `~/.gitignore`, set as
  `core.excludesfile`). Don't add ignores meant only for this repo to it; use
  `.git/info/exclude` or a nested `.gitignore`. `~/.config/git/ignore` is
  never read, because `core.excludesfile` replaces it.
- **Don't name repo directories after config dirs that tools read from a
  project:** `.claude/`, `.codex/`, `.bundle/`, `mise/`, `.config/mise*`. That
  is why the sources live in `claude/`, `bundle/`, etc.
- **Block templates can't see `config_root`** (despite the docs). Use
  `{{ vars.dotfiles_dir }}` (defined in `[vars]`) for the repo path. The repo
  isn't always at `~/p/dotfiles`.
- **Type matters for macOS defaults.** An integer doesn't match a stored real
  (e.g. the Dock stores `tilesize` as a real, so it's declared as `56.0` in the
  raw section).
- **Some apps replace symlinks when they save.** If `mise dot status` says a
  target "is not a symlink" (Zed is the likely one), move the change into the
  repo copy and run `mise dot apply --force <target>`.
- **Secrets stay out of the repo:** `~/.netrc`, `~/.pgpass`, `~/.ssh/id_*`,
  `~/.b2_account_info`, `~/.honeybadger-cli.yaml`, `~/.papertrail.yml`, and the
  auth files under `~/.codex`, `~/.gemini`, and `~/.config/raycast`.
- **Claude Code may refuse to edit its own config** (`~/.claude/…`). If it
  does, ask the user to run the command themselves with a `!` prefix.

## Verifying a change

```sh
# A fresh login shell, without this session's environment:
env -i HOME=$HOME TERM=xterm USER=$USER zsh -lic 'print -l $path; command -v node git'
mise bootstrap --dry-run   # should list nothing unexpected
git config --show-origin --get <key>
```
