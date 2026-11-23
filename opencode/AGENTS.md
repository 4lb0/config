## Git and "push"

- **"push"** = run the repo's tests, fix what fails and repeat until green (max
  5 iterations), then commit following the format the repo already uses (check
  `git log`), then push. If still red after 5 iterations: stop and report,
  without committing.
- **Multiple tasks or items** = one commit per task, in the order requested. Run
  the tests once at the end; if they fail, fix them in a separate commit after
  the last task commit.
- Commit early and incrementally: the user tests afterwards. If they report
  something is broken or there is a change, **amend** only if the commit has not
  been pushed yet; if it is already on the remote, add a new fix commit. Never
  force-push.
- **`git fetch` before any amend or rebase.** Never trust an `[ahead N]` seen
  earlier in the session: the remote may have moved and amending would rewrite
  commits that are already published. Fetch, compare with the upstream branch,
  and only then choose between amend and a new commit.
- No push on main or common branches (dev, qa, beta, prod) without an explicit
  request. Push directly when working on feature branches. If the repo has
  tests, run them before committing.

## Subagents

- **Delegate by default.** Anything that can be handed off goes to a subagent:
  searching, reading files, exploring a codebase, research, mechanical edits,
  refactors, bulk changes, writing or running checks. Keep in the main session
  only planning, decisions, wording, the user-facing answer and the final
  review. If in doubt, delegate.
- Pick by shape: `explore` to locate and read code, `general` for research and
  multi-step work that needs judgement, `operative-runner` for well-specified
  mechanical changes (edits, refactors, scripts, bulk changes).
- Decompose first. List the independent chunks of the task and launch them in
  parallel in a single round instead of one long serial run.
- Write self-contained prompts. A subagent starts with a fresh context, so give
  it the paths, the goal, the constraints, the expected output and how to verify
  it — never "as discussed above".
- The main session owns the result: review what the subagent returns, verify it,
  and keep commits and pushes for yourself. Never let a child commit, push or
  make product decisions on its own — that applies even if AGENTS.md or the task
  would otherwise allow it.
