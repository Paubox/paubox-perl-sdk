# Paubox Perl SDK

Official Perl SDK for the Paubox Email API and Paubox Forms API.

## Repository Structure

```
lib/
  Paubox_Email_SDK.pm          # Email API: sendMessage, getEmailDisposition
  Paubox_Email_SDK/
    ApiHelper.pm               # HTTP layer (REST::Client GET/POST)
    Message.pm                 # Email message object
  Paubox_Forms_SDK.pm          # Forms API: getForm, submitForm
t/
  Paubox_Email_SDK.t           # Test runner entry point
  SendMessage_TestData.csv     # CSV-driven test data for email tests
  lib/
    Paubox_Email_SDK/Test.pm   # Email API test cases (Test::Class)
    Paubox_Forms_SDK/Test.pm   # Forms API test cases (Test::Class)
Makefile.PL                    # CPAN build config
cpanfile                       # Perl dependency declarations
CHANGES                        # Changelog
```

## Setup

### Install dependencies

```bash
cpanm --installdeps .
```

Or install from `cpanfile` directly:

```bash
cpanm JSON Config::General REST::Client TryCatch String::Util MIME::Base64
cpanm Test::Class Test::More Text::CSV
```

### Configure credentials (Email API only)

Create `config.cfg` in the project root:

```
API_KEY = YOUR_API_KEY
API_USERNAME = YOUR_ENDPOINT_NAME
```

The Forms API is public and does not require credentials.

## Running Tests

```bash
perl Makefile.PL
make test
```

## Key Architecture Patterns

- **HTTP layer:** All requests go through `Paubox_Email_SDK::ApiHelper`, which wraps `REST::Client`. Both `getForm`/`submitForm` and email methods reuse this helper; Forms calls pass an empty auth header which is now conditionally omitted.
- **Error handling:** `TryCatch` is used throughout; methods die on unexpected responses.
- **JSON:** All request bodies are `encode_json` encoded; responses are parsed with `from_json` / `decode_json`.
- **Base64:** HTML email content is base64-encoded before transmission (`MIME::Base64`). Form attachment content must also be base64-encoded by the caller.
- **Config:** Email credentials are read from `config.cfg` using `Config::General`. No config file is needed for the Forms SDK.

## APIs

### Email API (`Paubox_Email_SDK`)
- Base URL: `https://api.paubox.net/v1/{apiUsername}`
- Auth: `Token token=<apiKey>`
- Methods: `sendMessage`, `getEmailDisposition`

### Forms API (`Paubox_Forms_SDK`)
- Base URL: `https://apx.paubox.com/forms`
- Auth: None (public endpoints)
- Methods: `getForm`, `submitForm`

See [api.md](api.md) for full API reference.
