# CLAUDE.md — Business::UPS

## What this is

A Perl module on CPAN providing UPS shipping utilities:
- **`UPStrack()`** — Track packages via UPS JSON tracking API (functional)
- **`getUPS()`** — Quote shipping rates (deprecated, endpoint retired by UPS)

Maintained under the [cpan-authors](https://github.com/cpan-authors) GitHub org.
CPAN distribution: [Business-UPS](https://metacpan.org/pod/Business::UPS)

## Project layout

```
lib/Business/UPS.pm   — Main module (both functions + POD)
t/00-load.t           — Basic load test
t/getups.t            — getUPS() tests (mocked HTTP)
t/upstrack.t          — UPStrack() tests (mocked HTTP)
examples/test.pl      — Live tracking example script
Makefile.PL           — Build system (ExtUtils::MakeMaker)
cpanfile              — Dependencies for CI
MANIFEST              — Files included in CPAN tarball
MANIFEST.SKIP         — Exclusion patterns for MANIFEST
Changes               — Release history
```

## Commands

```bash
perl Makefile.PL && make test     # Run test suite
make disttest                      # Test the distribution tarball
make manifest                      # Regenerate MANIFEST
pod2markdown lib/Business/UPS.pm > README.md   # Regenerate README.md from POD
```

## Architecture

Single-file module (`lib/Business/UPS.pm`), procedural design, two exported functions:

- **`UPStrack($tracking_number)`** — POST to UPS JSON API, returns hash with tracking details. Dies on error (caller uses `eval {}`). Optional keys are omitted (not undef) when data is missing.
- **`getUPS($product, $origin, $dest, $weight, ...)`** — Deprecated. Emits `warnings::warnif('deprecated', ...)`. The endpoint it hits (`qcostcgi.cgi`) no longer exists.
- **`Error($msg)`** — Internal helper, calls `die "$msg\n"`.

## Dependencies

- `LWP::UserAgent` — HTTP requests
- `JSON::PP` — JSON encode/decode (core since Perl 5.14)
- Minimum Perl: 5.014

## Testing conventions

- All HTTP is mocked via `*LWP::UserAgent::post` / `::get` redefinition — no live API calls
- Mock responses use a `MockResponse` class defined in each test file
- Test behavior, not implementation: assert on return values and exceptions
- `getUPS()` tests suppress deprecation warnings via `$SIG{__WARN__}`

## CPAN distribution rules

- **MANIFEST** is generated — run `make manifest` to regenerate it. Do not manually edit or sort this file.
- **README.md** is generated — run `pod2markdown lib/Business/UPS.pm > README.md` to regenerate from POD. Do not edit README.md directly.
- **Releases are human-only** — never update `Changes` or bump `$VERSION`. The maintainer handles versioning and changelog entries.
- **Version** lives in `$VERSION` in `lib/Business/UPS.pm` — `VERSION_FROM` in Makefile.PL reads it
- Use `=for markdown` directive in POD for content that should only appear in markdown output (e.g., CI badges)

## CI

GitHub Actions workflow at `.github/workflows/testsuite.yml`:
- Runs on push to all branches and on PRs
- Tests on ubuntu, macOS, windows (Strawberry Perl)
- Dynamic Perl version matrix from 5.14+ (via `perl-actions/perl-versions`)
- Includes `make disttest` job

## Code style

- `use strict; use warnings;` everywhere
- Exporter-based API (`@EXPORT`)
- No OO — this is a utility module
- Error handling via `die` (not `exit`), caller catches with `eval {}`
- Deprecation via `warnings::warnif('deprecated', ...)`

## Known issues

- `getUPS()` is non-functional (UPS retired the endpoint). Kept for backward compatibility with deprecation warning. Will be removed in a future release.
- The UPS Rating API (replacement for `getUPS()`) requires OAuth2 client credentials — significantly larger effort than the tracking rewrite.
