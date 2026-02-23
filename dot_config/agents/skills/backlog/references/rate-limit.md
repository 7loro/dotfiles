# Rate Limit API

## Table of Contents
- [Get Rate Limit](#get-rate-limit)

---

## Get Rate Limit

- **Method**: GET
- **Path**: `/api/v2/rateLimit`
- **Scope**: All user roles

### Parameters

None.

### Response
- **Status**: 200 OK
- **Content-Type**: application/json; charset=utf-8

| Field | Type | Description |
|-------|------|-------------|
| rateLimit | Object | Container for all rate limit data |
| rateLimit.read | Object | Read operation limits |
| rateLimit.read.limit | Number | Maximum read requests allowed per window |
| rateLimit.read.remaining | Number | Remaining read requests in current window |
| rateLimit.read.reset | Number | Unix timestamp when the read limit resets |
| rateLimit.update | Object | Update operation limits |
| rateLimit.update.limit | Number | Maximum update requests allowed per window |
| rateLimit.update.remaining | Number | Remaining update requests in current window |
| rateLimit.update.reset | Number | Unix timestamp when the update limit resets |
| rateLimit.search | Object | Search operation limits |
| rateLimit.search.limit | Number | Maximum search requests allowed per window |
| rateLimit.search.remaining | Number | Remaining search requests in current window |
| rateLimit.search.reset | Number | Unix timestamp when the search limit resets |
| rateLimit.icon | Object | Icon operation limits |
| rateLimit.icon.limit | Number | Maximum icon requests allowed per window |
| rateLimit.icon.remaining | Number | Remaining icon requests in current window |
| rateLimit.icon.reset | Number | Unix timestamp when the icon limit resets |

```json
{
    "rateLimit": {
        "read": {
            "limit": 600,
            "remaining": 600,
            "reset": 1603881873
        },
        "update": {
            "limit": 150,
            "remaining": 150,
            "reset": 1603881873
        },
        "search": {
            "limit": 150,
            "remaining": 150,
            "reset": 1603881873
        },
        "icon": {
            "limit": 60,
            "remaining": 60,
            "reset": 1603881873
        }
    }
}
```
