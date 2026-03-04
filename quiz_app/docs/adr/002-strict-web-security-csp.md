# ADR 002: Strict Web Security (CSP)

## Context
The Flutter Web application was vulnerable to XSS and data injection as it had no browser-level content restriction.

## Decision
Implement a strict Content Security Policy (CSP) via `<meta>` tag in `web/index.html`.

## Consequences
- **Positive**: Significantly reduces XSS risk; enforces a "trusted source" list.
- **Negative**: Requires careful management of third-party domains. Any new service (e.g. ad providers, analytics) must be explicitly whitelisted.
