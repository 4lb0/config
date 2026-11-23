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
