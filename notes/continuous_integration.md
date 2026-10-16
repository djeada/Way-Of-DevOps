# Continuous integration

Continuous integration means integrating small changes frequently and checking the combined result automatically. A CI server helps run the checks; the practice also depends on developers keeping changes small and responding to failures quickly.

## What to check

Start with the fastest useful feedback: formatting, linting, static checks, and unit tests. Add integration tests for important boundaries such as the database or an external API. Keep slower end-to-end tests focused on essential user journeys.

Use a clean environment, pinned runtime versions, and dependency lockfiles. Tests should set up their own data and avoid relying on execution order, production services, or another developer's machine.

Coverage can reveal untested code, but a percentage does not show whether tests catch meaningful failures. Test important behavior and failure paths. If a coverage threshold is useful, agree on one that supports the project and review it as the code changes.

## A workable feedback loop

1. Run the relevant checks locally before pushing.
2. Open a small pull request and run required checks on its changes.
3. Review the code and resolve failed checks before merging.
4. Verify the integrated main branch too; individually passing changes can interact badly.
5. Repair or revert a change that breaks main so other work can continue.

Protect the main branch with review and required checks appropriate to the project. A check that did not run is not evidence that a test passed. Investigate flaky tests and make their owner and repair plan visible.

## Keep feedback useful

Show a clear failing command and enough logs to diagnose it. Parallelize independent checks when that improves feedback time. Cancel superseded CI runs where appropriate, while ensuring required checks still report a result.

Keep setup and test commands in the repository so anyone can reproduce a failure. A local test and a CI test should exercise the same behavior with differences in environment made explicit.

Related: [CI/CD](ci_cd.md) explains what happens after verification; [GitHub Actions](github_actions.md) shows one implementation.
