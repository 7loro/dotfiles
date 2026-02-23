# Authentication & General

## Table of Contents
- [Base URL](#base-url)
- [API Key Authentication](#api-key-authentication)
- [OAuth 2.0 Authentication](#oauth-20-authentication)
- [Error Responses](#error-responses)

---

## Base URL

```
https://{spaceKey}.backlog.com/api/v2
https://{spaceKey}.backlog.jp/api/v2
```

The API supports Cross Origin Resource Sharing (CORS).

---

## API Key Authentication

Append `apiKey` as a query parameter:

```
GET https://{spaceKey}.backlog.com/api/v2/users/myself?apiKey=YOUR_API_KEY
```

---

## OAuth 2.0 Authentication

Implements "Authorization Code Grant" (RFC 6749).

### 1. Register Application

Register at the Backlog Developer Site to obtain `client_id` and `client_secret`.

### 2. Authorization Request

- **Method**: GET
- **Path**: `/OAuth2AccessRequest.action`

| Name | Type | Required | Description |
|------|------|----------|-------------|
| response_type | String | Yes | Must be `"code"` |
| client_id | String | Yes | Application client ID |
| redirect_uri | String | Yes | Must match registered URI |
| state | String | No | CSRF protection |

User approves → redirected to `redirect_uri` with `code` parameter.

### 3. Token Request

- **Method**: POST
- **Path**: `/api/v2/oauth2/token`
- **Content-Type**: `application/x-www-form-urlencoded`

| Name | Type | Required | Description |
|------|------|----------|-------------|
| grant_type | String | Yes | `"authorization_code"` |
| code | String | Yes | Authorization code |
| redirect_uri | String | Yes | Must match registered URI |
| client_id | String | Yes | Application client ID |
| client_secret | String | Yes | Application client secret |

```json
{
    "access_token": "YOUR_ACCESS_TOKEN",
    "token_type": "Bearer",
    "expires_in": 3600,
    "refresh_token": "YOUR_REFRESH_TOKEN"
}
```

### 4. API Request with Token

```
GET /api/v2/space
Host: {spaceKey}.backlog.com
Authorization: Bearer YOUR_ACCESS_TOKEN
```

### 5. Token Refresh

POST to `/api/v2/oauth2/token`:

| Name | Type | Required | Description |
|------|------|----------|-------------|
| grant_type | String | Yes | `"refresh_token"` |
| refresh_token | String | Yes | Refresh token value |
| client_id | String | Yes | Application client ID |
| client_secret | String | Yes | Application client secret |

### Authentication Errors

- Invalid token: `401` with `Bearer error="invalid_token", error_description="The access token is invalid"`
- Expired token: `401` with `Bearer error="invalid_token", error_description="The access token expired"`

---

## Error Responses

### Format

```json
{
    "errors": [
        {
            "message": "No project.",
            "code": 6,
            "moreInfo": ""
        }
    ]
}
```

### Error Codes

| Code | Type | Description |
|------|------|-------------|
| 1 | InternalError | API Server internal error |
| 2 | LicenceError | API not available in current licence |
| 3 | LicenceExpiredError | Space licence expired |
| 4 | AccessDeniedError | Access denied from restricted IP |
| 5 | UnauthorizedOperationError | Operation denied |
| 6 | NoResourceError | Resource does not exist |
| 7 | InvalidRequestError | Invalid parameters |
| 8 | SpaceOverCapacityError | Exceeds space capacity |
| 9 | ResourceOverflowError | Exceeds resource limit |
| 10 | TooLargeFileError | Attachment exceeds size limit |
| 11 | AuthenticationError | Not registered on target space |
| 12 | RequiredMFAError | MFA required but not enabled |
| 13 | TooManyRequestsError | Rate limit exceeded |
