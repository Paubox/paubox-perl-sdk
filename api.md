# Paubox Perl SDK — API Reference

## Email API

**Module:** `Paubox_Email_SDK`  
**Base URL:** `https://api.paubox.net/v1/{apiUsername}`  
**Authentication:** `Token token=<apiKey>` — credentials read from `config.cfg`

---

### `Paubox_Email_SDK->new()`

Loads `apiKey` and `apiUsername` from `config.cfg` in the current working directory.

```
API_KEY = YOUR_API_KEY
API_USERNAME = YOUR_ENDPOINT_NAME
```

Dies with an error message if either credential is missing.

---

### `$service->sendMessage($messageObj)`

Sends a HIPAA-compliant email message.

**Endpoint:** `POST /messages`

**Parameter:** A `Paubox_Email_SDK::Message` object.

| Message Field           | Type     | Required | Description                                        |
|-------------------------|----------|----------|----------------------------------------------------|
| `from`                  | String   | Yes      | Sender email address                               |
| `to`                    | ArrayRef | Yes      | Array of recipient email addresses                 |
| `subject`               | String   | Yes      | Email subject line                                 |
| `text_content`          | String   | No       | Plain-text body                                    |
| `html_content`          | String   | No       | HTML body (base64-encoded before transmission)     |
| `replyTo`               | String   | No       | Reply-to address                                   |
| `cc`                    | ArrayRef | No       | CC recipients                                      |
| `bcc`                   | ArrayRef | No       | BCC recipients                                     |
| `allowNonTLS`           | Boolean  | No       | `1` to allow delivery without TLS (default: `0`)  |
| `forceSecureNotification` | String | No      | `"true"` or `"false"` to override org default     |
| `attachments`           | ArrayRef | No       | Array of attachment hashrefs (see below)           |

**Attachment hashref fields:**

| Field         | Type   | Description                              |
|---------------|--------|------------------------------------------|
| `fileName`    | String | Filename shown to recipient              |
| `contentType` | String | MIME type (e.g. `"application/pdf"`)     |
| `content`     | String | Base64-encoded file content              |

**Returns:** JSON string. On success, contains `data` and `sourceTrackingId`. On
failure, contains `errors`.

**Example:**

```perl
my $msg = new Paubox_Email_SDK::Message(
    'from'         => 'sender@domain.com',
    'to'           => ['recipient@example.com'],
    'subject'      => 'Hello',
    'text_content' => 'Hello World!',
    'html_content' => '<html><body><h1>Hello World!</h1></body></html>',
);

my $service  = Paubox_Email_SDK->new();
my $response = $service->sendMessage($msg);
```

---

### `$service->getEmailDisposition($sourceTrackingId)`

Retrieves delivery and open status for a previously sent message.

**Endpoint:** `GET /message_receipt?sourceTrackingId={id}`

**Parameter:** `$sourceTrackingId` — String returned by `sendMessage`.

**Returns:** JSON string. On success, contains `data.message.message_deliveries`
with per-recipient status. Unopened messages have `openedStatus` set to
`"unopened"`. On failure, contains `errors`.

**Example:**

```perl
my $service  = Paubox_Email_SDK->new();
my $response = $service->getEmailDisposition("1aed91d1-f7ce-4c3d-8df2-85ecd225a7fc");
```

---

## Forms API

**Module:** `Paubox_Forms_SDK`  
**Base URL:** `https://next.paubox.com`  
**Authentication:** None — all Forms API endpoints are public.

---

### `Paubox_Forms_SDK->new()`

Creates a new Forms client. No credentials or configuration file required.

---

### `$forms->getForm($formId)`

Retrieves a form's metadata, HTML, JSON schema, and CSS by UUID.

**Endpoint:** `GET /public/form_data/{formId}`

**Parameter:** `$formId` — UUID string of the form to retrieve.

**Returns:** JSON string containing form definition fields:

| Field       | Type   | Description                              |
|-------------|--------|------------------------------------------|
| `id`        | String | Form UUID                                |
| `title`     | String | Form title                               |
| `form_html` | String | Rendered HTML of the form                |
| `form_json` | Object | JSON schema of form fields               |
| `form_css`  | String | CSS styles for the form                  |

Dies if `formId` is empty or the response contains neither `id` nor `errors`.

**Example:**

```perl
my $forms    = Paubox_Forms_SDK->new();
my $response = $forms->getForm("your-form-uuid");
```

---

### `$forms->submitForm($formId, \%formData [, \@attachments])`

Submits a respondent's answers for a form, with optional file attachments.

**Endpoint:** `POST /api/forms/{formId}/submissions`

**Parameters:**

| Parameter      | Type     | Required | Description                                        |
|----------------|----------|----------|----------------------------------------------------|
| `$formId`      | String   | Yes      | UUID of the target form                            |
| `\%formData`   | HashRef  | Yes      | Key-value pairs matching the form's field schema   |
| `\@attachments`| ArrayRef | No       | Array of attachment hashrefs (see below)           |

**Attachment hashref fields:**

| Field     | Type   | Description                    |
|-----------|--------|--------------------------------|
| `name`    | String | Filename                       |
| `content` | String | Base64-encoded file content    |

Maximum total request size: **250 MB**.

**Returns:** Empty string on success (HTTP 201). Dies on error.

**Example:**

```perl
my $forms    = Paubox_Forms_SDK->new();
my $response = $forms->submitForm(
    "your-form-uuid",
    { first_name => "Jane", last_name => "Doe", email => "jane\@example.com" }
);
```

**With attachment:**

```perl
use MIME::Base64;

open(my $fh, '<:raw', 'consent.pdf') or die $!;
local $/;
my $encoded = encode_base64(<$fh>);
close($fh);

my $response = $forms->submitForm(
    "your-form-uuid",
    { first_name => "Jane" },
    [ { name => "consent.pdf", content => $encoded } ]
);
```
