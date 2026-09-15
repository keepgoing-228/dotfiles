@RTK.md

# General guidelines

- Never use the em dash "—", use plain dash "-" instead.
- When making technical decisions, do not give much weight to development cost. Instead, prefer quality, simplicity, rebustness, scalability, and long term maintainability.
- When doing bug fixes, always starts with reproducing the bug in an E2E setting as closely aligned with how an end user would experience it as possible. This makes sure you find the real problem so your fix will actually solvle it.
- Everything published to GitHub must be in English. Quoted non-English strings (UI labels, user-facing copy, data samples) may stay in their original language; the surrounding prose must be English.
- Write all git commit messages in Conventional Commits format — `<type>[optional scope]: <description>` (e.g. `feat:`, `fix:`, `build(deps):`, `chore:`, `docs:`, `refactor:`, `test:`). Use `!` or a `BREAKING CHANGE:` footer for breaking changes.


# Knowledge Base

- Cross-project engineering knowledge lives in ~/Github/engineering-notes/ (rocm.md, vllm.md, docker.md). When working on GPU, inference, or deployment issues, read the relevant topic file before debugging from scratch.
- Always remind me if ~/Github/engineering-notes/ need to update.

