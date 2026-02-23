# Watching API

## Table of Contents
- [Get Watching List](#get-watching-list)
- [Count Watching](#count-watching)
- [Get Watching](#get-watching)
- [Add Watching](#add-watching)
- [Update Watching](#update-watching)
- [Delete Watching](#delete-watching)
- [Mark Watching as Read](#mark-watching-as-read)

---

## Get Watching List

- **Method**: GET
- **Path**: `/api/v2/users/:userId/watchings`
- **Scope**: All

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| userId | Number | Yes | User ID (URL parameter) |
| order | String | No | Sort direction: `"asc"` or `"desc"` (default: `"desc"`) |
| sort | String | No | Sort field: `"created"`, `"updated"`, `"issueUpdated"` (default: `"issueUpdated"`) |
| count | Number | No | Records per request (1-100, default: 20) |
| offset | Number | No | Pagination offset (default: 0) |
| resourceAlreadyRead | Boolean | No | Filter by read status: `true` = read only, `false` = unread only, `null` = all |
| issueId[] | Number | No | Filter by specific issue IDs (multiple allowed) |

### Response
- **Status**: 200 OK

```json
[
    {
        "id": 1,
        "resourceAlreadyRead": true,
        "note": "watching note",
        "type": "issue",
        "issue": {
            "id": 1,
            "projectId": 1,
            "issueKey": "TEST-1",
            "keyId": 1,
            "issueType": {
                "id": 2,
                "projectId": 1,
                "name": "Bug",
                "color": "#990000",
                "displayOrder": 0
            },
            "summary": "test issue",
            "description": "",
            "priority": {
                "id": 3,
                "name": "Normal"
            },
            "status": {
                "id": 1,
                "name": "Open"
            },
            "assignee": {},
            "category": [],
            "versions": [],
            "milestone": [],
            "startDate": null,
            "dueDate": null,
            "estimatedHours": null,
            "actualHours": null,
            "parentIssueId": null,
            "createdUser": {},
            "created": "2013-02-07T08:09:49Z",
            "updatedUser": {},
            "updated": "2013-02-07T08:09:49Z",
            "customFields": [],
            "attachments": [],
            "sharedFiles": [],
            "stars": []
        },
        "lastContentUpdated": "2013-02-07T08:09:49Z",
        "created": "2013-02-07T08:09:49Z",
        "updated": "2013-02-07T08:09:49Z"
    }
]
```

---

## Count Watching

- **Method**: GET
- **Path**: `/api/v2/users/:userId/watchings/count`
- **Scope**: All

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| userId | Number | Yes | User ID (URL parameter) |
| resourceAlreadyRead | Boolean | No | `false` for unread count, `true` for already-read count |
| alreadyRead | Boolean | No | `false` for unread since last check, `true` for already-read count (supersedes `resourceAlreadyRead`) |

### Response
- **Status**: 200 OK

```json
{
    "count": 138
}
```

---

## Get Watching

- **Method**: GET
- **Path**: `/api/v2/watchings/:watchingId`
- **Scope**: All

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| watchingId | Number | Yes | Watching record ID (URL parameter) |

### Response
- **Status**: 200 OK

```json
{
    "id": 1,
    "alreadyRead": false,
    "note": "watching note",
    "type": "issue",
    "issue": {
        "id": 1,
        "projectId": 1,
        "issueKey": "TEST-1",
        "keyId": 1,
        "issueType": {
            "id": 2,
            "projectId": 1,
            "name": "Bug",
            "color": "#990000",
            "displayOrder": 0
        },
        "summary": "test issue",
        "description": "",
        "priority": {
            "id": 3,
            "name": "Normal"
        },
        "status": {
            "id": 1,
            "name": "Open"
        },
        "assignee": {},
        "category": [],
        "versions": [],
        "milestone": [],
        "startDate": null,
        "dueDate": null,
        "estimatedHours": null,
        "actualHours": null,
        "parentIssueId": null,
        "createdUser": {},
        "created": "2013-02-07T08:09:49Z",
        "updatedUser": {},
        "updated": "2013-02-07T08:09:49Z",
        "customFields": [],
        "attachments": [],
        "sharedFiles": [],
        "stars": []
    },
    "lastContentUpdated": "2013-02-07T08:09:49Z",
    "created": "2013-02-07T08:09:49Z",
    "updated": "2013-02-07T08:09:49Z"
}
```

---

## Add Watching

- **Method**: POST
- **Path**: `/api/v2/watchings`
- **Scope**: All
- **Content-Type**: `application/x-www-form-urlencoded`

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| issueIdOrKey | String | Yes | Issue ID or Issue Key |
| note | String | No | Note for the watching |

### Response
- **Status**: 201 Created

```json
{
    "id": 1,
    "note": "watching note",
    "type": "issue",
    "issue": {
        "id": 1,
        "projectId": 1,
        "issueKey": "TEST-1",
        "keyId": 1,
        "issueType": {
            "id": 2,
            "projectId": 1,
            "name": "Bug",
            "color": "#990000",
            "displayOrder": 0
        },
        "summary": "test issue",
        "description": "",
        "priority": {
            "id": 3,
            "name": "Normal"
        },
        "status": {
            "id": 1,
            "name": "Open"
        },
        "assignee": {},
        "category": [],
        "versions": [],
        "milestone": [],
        "startDate": null,
        "dueDate": null,
        "estimatedHours": null,
        "actualHours": null,
        "parentIssueId": null,
        "createdUser": {},
        "created": "2013-02-07T08:09:49Z",
        "updatedUser": {},
        "updated": "2013-02-07T08:09:49Z",
        "customFields": [],
        "attachments": [],
        "sharedFiles": [],
        "stars": []
    },
    "lastContentUpdated": "2013-02-07T08:09:49Z",
    "created": "2013-02-07T08:09:49Z",
    "updated": "2013-02-07T08:09:49Z"
}
```

---

## Update Watching

- **Method**: PATCH
- **Path**: `/api/v2/watchings/:watchingId`
- **Scope**: All
- **Content-Type**: `application/x-www-form-urlencoded`

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| watchingId | Number | Yes | Watching record ID (URL parameter) |
| note | String | No | Note text to update |

### Response
- **Status**: 200 OK

```json
{
    "id": 1,
    "note": "updated note",
    "type": "issue",
    "issue": {
        "id": 1,
        "projectId": 1,
        "issueKey": "TEST-1",
        "keyId": 1,
        "issueType": {
            "id": 2,
            "projectId": 1,
            "name": "Bug",
            "color": "#990000",
            "displayOrder": 0
        },
        "summary": "test issue",
        "description": "",
        "priority": {
            "id": 3,
            "name": "Normal"
        },
        "status": {
            "id": 1,
            "name": "Open"
        },
        "assignee": {},
        "category": [],
        "versions": [],
        "milestone": [],
        "startDate": null,
        "dueDate": null,
        "estimatedHours": null,
        "actualHours": null,
        "parentIssueId": null,
        "createdUser": {},
        "created": "2013-02-07T08:09:49Z",
        "updatedUser": {},
        "updated": "2013-02-07T08:09:49Z",
        "customFields": [],
        "attachments": [],
        "sharedFiles": [],
        "stars": []
    },
    "lastContentUpdated": "2013-02-07T08:09:49Z",
    "created": "2013-02-07T08:09:49Z",
    "updated": "2013-02-07T08:09:49Z"
}
```

> Note: Users can only modify their own watching records.

---

## Delete Watching

- **Method**: DELETE
- **Path**: `/api/v2/watchings/:watchingId`
- **Scope**: All

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| watchingId | Number | Yes | Watching record ID (URL parameter) |

### Response
- **Status**: 200 OK

Returns the deleted watching object (same structure as Get Watching response).

> Note: Users can only delete their own watching records.

---

## Mark Watching as Read

- **Method**: POST
- **Path**: `/api/v2/watchings/:watchingId/markAsRead`
- **Scope**: All

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| watchingId | Number | Yes | Watching record ID (URL parameter) |

### Response
- **Status**: 204 No Content
