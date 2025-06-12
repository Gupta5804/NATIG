# Codex Agent Instructions

When modifying any `*.sh` script within this repository, run
`shellcheck` on the modified files and address warnings where
possible.

When modifying Markdown files (`*.md`), run `markdownlint` on
changed files.

Always run these checks before committing your changes.

## Local Docker Setup

Many build scripts expect the repository root to be mounted to
`/rd2c` inside a Docker container. The helper script `rundocker.sh`
launches this container with a bind mount of the current repository
directory to `/rd2c` (see `Dockerfile` for the base image details).
Scripts therefore refer to paths such as `/rd2c/build_helics.sh`
even though `build_helics.sh` lives at the repository root.

Keep this mount in mind when running `develop.sh` or related scripts
so that path lookups succeed.

The `ns-3-dev` directory is intentionally excluded from version control
(see `.gitignore`). For builds to succeed, place your local `ns-3-dev`
checkout inside the repository root. When launched via `rundocker.sh`,
this directory will appear inside the container as `/rd2c/ns-3-dev`,
which is the location expected by `develop.sh` and other scripts.
