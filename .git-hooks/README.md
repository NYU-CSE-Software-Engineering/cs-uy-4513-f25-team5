# Git Hooks

This directory contains version-controlled Git hooks for the project.

## Available Hooks

### pre-commit
Runs RSpec and Cucumber test suites before allowing commits.

**Purpose**: Prevents "fix tests" commits by ensuring all tests pass before code is committed.

**What it does**:
1. Checks if `bundle` command is available
2. Runs `bundle exec rspec` (unit/request tests)
3. Runs `bundle exec cucumber` (acceptance tests)
4. Blocks commit if any tests fail

**Exit codes**:
- `0`: All tests passed, commit proceeds
- `1`: Tests failed or bundle not available, commit blocked

**Bypass**: Use `git commit --no-verify` to skip the hook (use sparingly)

## Installation

Run the installation script to install all hooks:

```bash
bin/install-hooks
```

This creates symlinks from `.git/hooks/` to this directory, keeping your hooks automatically updated with the repository.

## Development

To modify a hook:
1. Edit the file in this directory (`.git-hooks/`)
2. Test your changes
3. Commit the modified hook (it's version controlled)
4. The symlink ensures changes are immediately active

To add a new hook:
1. Create the hook file in this directory
2. Make it executable: `chmod +x .git-hooks/<hook-name>`
3. Run `bin/install-hooks` to install it
4. Commit the new hook file

## Hook Execution Time

The pre-commit hook runs the full test suite, which takes approximately **5 seconds**.

## Troubleshooting

**Hook not running**: Run `bin/install-hooks` to ensure hooks are properly installed.

**Permission errors**: Make sure the hook is executable: `chmod +x .git-hooks/pre-commit`

**Bundle not found**: Ensure you've run `bundle install` and bundler is in your PATH.

**Want to commit anyway**: Use `git commit --no-verify` (but consider fixing the tests first!).
