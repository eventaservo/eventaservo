# Project Instructions

Please refer to [AGENTS.md](AGENTS.md) for project-wide instructions, code style, and architectural guidelines.

## Development & Local Testing Links

The developer uses a private Tailscale network (Tailnet) with `tailscale serve` terminating HTTPS:
- **HTTPS Tailnet URL**: `https://home1.eland-neon.ts.net:3003/<path>` (terminates HTTPS and proxies to `127.0.0.1:3002`)
- **HTTP Direct Tailnet IP**: `http://100.81.15.87:3002/<path>`

Always provide the HTTPS Tailnet link (`https://home1.eland-neon.ts.net:3003`) when giving URLs to test. Do not give `https` on port 3002 (causes `ERR_SSL_PROTOCOL_ERROR`) and do not provide only `localhost`.

## Skills

Skills are available in `.agents/skills/`. Each skill has a `SKILL.md` with instructions for specific tasks (testing, YARD docs, PR creation, code review, issue creation).
