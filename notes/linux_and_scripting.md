# Linux, Git, and scripting

Most operations work involves finding out what a machine is doing and turning a repeated procedure into a reliable command. Learn to inspect the system before changing it, and keep the scripts and configuration in version control.

## Read the system

Understand the filesystem, users and groups, file ownership, permissions, processes, signals, environment variables, standard input/output, and exit codes. Learn how packages are installed and how services start on your distribution.

Useful questions are: which process owns a listener, which user runs it, where its configuration comes from, where logs go, and what survives a restart? On Linux systems using systemd, `systemctl` and `journalctl` help inspect services. Other systems use different service managers.

```bash
pwd
ls -lah
id
ps -ef
df -h
du -sh ./
```

These commands inspect location, files, identity, processes, and disk usage. `du` can take time on a large tree. Add [network checks](networking.md) when a service is running but unreachable.

## Use Git for review and recovery

Learn the difference between the working tree, staging area, commits, branches, and remote references. Before committing, inspect both unstaged and staged changes:

```bash
git status --short
git diff
git diff --cached
git log --oneline -5
```

Keep commits focused and describe why the change is needed. Practice merging and resolving a conflict in a disposable repository. Use `git revert` to record an inverse change on a shared branch when appropriate. Understand the impact before rewriting shared history.

Commit source code, scripts, and non-secret configuration. Exclude generated files and credentials. A `.gitignore` rule does not remove a secret that has already been committed; exposed credentials must be revoked or replaced.

## Write scripts that can be rerun

Choose Bash for short shell-oriented tasks, PowerShell for its object-oriented environment, or a language such as Python when parsing and logic grow. Make inputs, required tools, side effects, and outputs clear.

A small Bash example writes a report for the filesystem holding a chosen directory:

```bash
#!/usr/bin/env bash
set -euo pipefail

report_dir=${1:-./reports}
mkdir -p -- "$report_dir"
df -h -- "$report_dir" > "$report_dir/disk.txt"
printf 'Wrote %s/disk.txt\n' "$report_dir"
```

The script creates the directory if needed and overwrites its own report on each run. Quote variable expansions, check failure paths, and avoid logging secrets. `set -e` has exceptions in shell control flow; it is not a substitute for handling expected errors explicitly.

Test automation on a disposable target first. For changes to remote systems, add explicit target selection, useful logs, timeouts, and a plan for partial failure. Use configuration-management modules when they already provide the desired behavior.

References: [Bash manual](https://www.gnu.org/software/bash/manual/bash.html) and [Pro Git](https://git-scm.com/book/en/v2). Continue with [small-company servers](server_in_small_company.md).
