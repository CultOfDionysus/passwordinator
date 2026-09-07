# Passwordinator

A Perl script that generates several character-password options and two word-password variants, with ANSI colours in interactive terminals.

## Installation

Requires Perl 5.14 or later and `Crypt::Random`:

```sh
cpan Crypt::Random
```

`Term::ANSIColor`, `Getopt::Long`, `HTTP::Tiny`, and `JSON::PP` are included with supported Perl versions. Online word generation also requires HTTPS support for `HTTP::Tiny` (typically `IO::Socket::SSL` and `Net::SSLeay`) and a working CA certificate store. If HTTPS or the service is unavailable, character passwords still work.

## Usage

```sh
perl passwordinator.pl
perl passwordinator.pl --offline
perl passwordinator.pl --no-color
perl passwordinator.pl --help
perl passwordinator.pl --version
```

- `--offline` generates character passwords without contacting any service.
- `--no-color` (also `--no-colour`) disables colours. Colours are automatically disabled when output is redirected or piped, or `NO_COLOR` is set.
- Unknown options and unexpected positional arguments return a nonzero exit status.

The default output includes 32- and 12-character passwords drawn from mixed-case letters, digits and symbols, plus two 8-character options with restricted alphabets. Character types are sampled independently: every category is not guaranteed to appear. Prefer longer passwords; the shorter options are for systems with restrictive requirements.

Online mode requests three words from `https://random-word.ryanrk.com/api/en/word/random/3`. Requests use TLS verification and a five-second socket timeout. Failed requests or malformed word lists produce a warning on stderr while preserving the character passwords. The API provider knows the words it supplies; word variants are suggestions, not locally generated secret passphrases. Letter substitutions do not provide independent randomness for each character.

## Tests

```sh
perl -c passwordinator.pl
prove -v t
```

The CLI tests use deterministic random and HTTP doubles to exercise formatting, offline operation, validation, and service failures without network access. They do not test the entropy source or live API connectivity.
