# Contributing

Ways to get involved, roughly in order of how much commitment they take:

- **Join the mailing lists.** The best way to reach the community, offer help, or get advice. See [Support](https://www.xquartz.org/Support.html).
- **Bug triage.** Screening incoming reports, spotting regressions and duplicates, and flagging anything serious is genuinely useful and doesn't require writing code.
- **Website fixes.** The [xquartz.org](https://www.xquartz.org/) site is its own GitHub-hosted, Jekyll-based repo — fork it and send a pull request there for content/doc fixes.
- **Code contributions** to this repository.

## Reporting bugs

If in doubt, just file a ticket on [GitHub Issues](https://github.com/XQuartz/XQuartz/issues) — see [Bug Reporting](https://www.xquartz.org/Bug-Reporting.html). You may get redirected: issues specific to a bundled component (Mesa, Cairo, fontconfig, FreeType, XCB, the X server, `quartz-wm`) sometimes belong on that component's own tracker on freedesktop.org instead.

## Building

See [README.md](README.md#building) for the commands. In short: this is a shell-script-based build (`compile.sh`) driving a tree of git submodules, one per component, not an IDE project. There is no automated test suite — verification means building the `.pkg`, installing it, and exercising the actual behavior you changed.

Full manual build/environment setup (Xcode version, avoiding conflicts with other package managers when rebuilding an individual component by hand, `pkg-config`/`aclocal` paths) is documented at [Developer Info](https://www.xquartz.org/Developer-Info.html); some of it predates Apple Silicon and the current MacPorts-based toolchain bootstrap (`install-or-update-macports.sh`) and is being kept up to date incrementally rather than all at once.

## Patches

The traditional path, per [Developer Info](https://www.xquartz.org/Developer-Info.html) and [x.org's contributing guide](https://www.x.org/guide/contributing/): generate patches with `git format-patch` (or `diff -Naurp`), send them to the `xquartz-dev` mailing list, and get a freedesktop.org account for git commit access once you're sending substantial or repeated contributions. Their stated bar for anything landing in the X server itself is blunt: *"we refuse to commit your untested patches."*

In practice, plenty of people find this repo through GitHub rather than the mailing list, and a GitHub pull request is also a valid way to propose a change here — you don't need a freedesktop.org account for that. Treat the "no untested patches" standard as the goal, not a hard gate on a first draft: a work-in-progress PR, a build-system fix, or a patch you've only verified by re-reading the diff rather than running it is fine to open. Just say plainly what you have and haven't actually tested, in the PR description, so a reviewer doesn't assume more confidence than exists yet. Patches under `src/*.patches/` should also note which upstream commit they were generated against (`git -C src/<project> rev-parse HEAD`), since they're plain `patch -p1` files, not a tracked branch, and silently stop applying once the submodule and the patch drift apart.

## License

Contributions are licensed under the same terms as the file(s) they modify — see [LICENSE](LICENSE).
