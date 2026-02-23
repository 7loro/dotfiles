# Space API

## Table of Contents
- [Get Space](#get-space)
- [Get Recent Updates](#get-recent-updates)
- [Get Space Logo](#get-space-logo)
- [Get Space Notification](#get-space-notification)
- [Update Space Notification](#update-space-notification)
- [Get Space Disk Usage](#get-space-disk-usage)
- [Post Attachment File](#post-attachment-file)

> **Note**: "Get Space Activities" (`/api/v2/space/activities`) returned 404 on the documentation site. It appears to be the same endpoint as "Get Recent Updates" documented below.

---

## Get Space

- **Method**: GET
- **Path**: `/api/v2/space`
- **Scope**: All user roles

### Parameters

None.

### Response
- **Status**: 200 OK
- **Content-Type**: application/json; charset=utf-8

| Field | Type | Description |
|-------|------|-------------|
| spaceKey | String | Unique identifier for the workspace |
| name | String | Display name of the organization/space |
| ownerId | Number | User ID of the space owner |
| lang | String | Language setting (e.g., `"ja"`) |
| timezone | String | Timezone configuration (e.g., `"Asia/Tokyo"`) |
| reportSendTime | String | Time when reports are sent (HH:MM:SS format) |
| textFormattingRule | String | Markup language used (e.g., `"markdown"`) |
| created | String | ISO 8601 timestamp of space creation |
| updated | String | ISO 8601 timestamp of last modification |

```json
{
    "spaceKey": "nulab",
    "name": "Nulab Inc.",
    "ownerId": 1,
    "lang": "ja",
    "timezone": "Asia/Tokyo",
    "reportSendTime": "08:00:00",
    "textFormattingRule": "markdown",
    "created": "2008-07-06T15:00:00Z",
    "updated": "2013-06-18T07:55:37Z"
}
```

---

## Get Recent Updates

- **Method**: GET
- **Path**: `/api/v2/space/activities`
- **Scope**: All user roles

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| activityTypeId[] | Number | No | Activity type filter (1-26); supports multiple values |
| minId | Number | No | Minimum activity ID threshold |
| maxId | Number | No | Maximum activity ID threshold |
| count | Number | No | Number of records to retrieve (1-100, default: 20) |
| order | String | No | Sort direction: `"asc"` or `"desc"` (default: `"desc"`) |

#### Activity Type IDs

| ID | Description |
|----|-------------|
| 1 | Issue Created |
| 2 | Issue Updated |
| 3 | Issue Commented |
| 4 | Issue Deleted |
| 5 | Wiki Created |
| 6 | Wiki Updated |
| 7 | Wiki Deleted |
| 8 | File Added |
| 9 | File Updated |
| 10 | File Deleted |
| 11 | SVN Committed |
| 12 | Git Pushed |
| 13 | Git Repository Created |
| 14 | Issue Multi Updated |
| 15 | Project User Added |
| 16 | Project User Deleted |
| 17 | Comment Notification Added |
| 18 | Pull Request Added |
| 19 | Pull Request Updated |
| 20 | Comment Added on Pull Request |
| 21 | Pull Request Deleted |
| 22 | Milestone Created |
| 23 | Milestone Updated |
| 24 | Milestone Deleted |
| 25 | Project Group Added |
| 26 | Project Group Deleted |

### Response
- **Status**: 200 OK
- **Content-Type**: application/json; charset=utf-8

Returns an array of activity objects.

| Field | Type | Description |
|-------|------|-------------|
| id | Number | Activity identifier |
| project | Object | Associated project details (id, projectKey, name, settings) |
| type | Number | Activity type (1-26, see table above) |
| content | Object | Activity-specific data (issue/wiki/file details, changes) |
| notifications | Array | Notification list (empty as of Feb 9, 2022) |
| createdUser | Object | User who triggered the activity |
| created | String | ISO 8601 timestamp |

```json
[
    {
        "id": 3153,
        "type": 2,
        "content": {
            "id": 4809,
            "key_id": 121,
            "summary": "Comment",
            "changes": [
                {
                    "field": "milestone",
                    "new_value": "R2014-07-23",
                    "old_value": "",
                    "type": "standard"
                }
            ]
        },
        "notifications": [],
        "created": "2013-12-27T07:50:44Z"
    }
]
```

---

## Get Space Logo

- **Method**: GET
- **Path**: `/api/v2/space/image`
- **Scope**: All user roles

### Parameters

None.

### Response
- **Status**: 200 OK
- **Content-Type**: application/octet-stream
- **Content-Disposition**: `attachment;filename="logo_mark.png"`

The response body contains the binary image file (PNG format). This endpoint returns the actual logo image, not JSON.

---

## Get Space Notification

- **Method**: GET
- **Path**: `/api/v2/space/notification`
- **Scope**: All user roles

### Parameters

None.

### Response
- **Status**: 200 OK
- **Content-Type**: application/json; charset=utf-8

| Field | Type | Description |
|-------|------|-------------|
| content | String | The notification message text |
| updated | String | ISO 8601 timestamp of last update |

```json
{
    "content": "Notification",
    "updated": "2013-06-18T07:55:37Z"
}
```

---

## Update Space Notification

- **Method**: PUT
- **Path**: `/api/v2/space/notification`
- **Scope**: Administrator

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| content | String | Yes | The notification content text to set |

### Response
- **Status**: 200 OK
- **Content-Type**: application/json; charset=utf-8

| Field | Type | Description |
|-------|------|-------------|
| content | String | The updated notification content text |
| updated | String | ISO 8601 timestamp of when the notification was updated |

```json
{
    "content": "Notification",
    "updated": "2013-06-18T07:55:37Z"
}
```

---

## Get Space Disk Usage

- **Method**: GET
- **Path**: `/api/v2/space/diskUsage`
- **Scope**: Administrator

### Parameters

None.

### Response
- **Status**: 200 OK
- **Content-Type**: application/json; charset=utf-8

| Field | Type | Description |
|-------|------|-------------|
| capacity | Number | Total storage capacity in bytes |
| issue | Number | Disk space used by issues (bytes) |
| wiki | Number | Disk space used by wiki pages (bytes) |
| file | Number | Disk space used by files (bytes) |
| subversion | Number | Disk space used by Subversion repositories (bytes) |
| git | Number | Disk space used by Git repositories (bytes) |
| gitLFS | Number | Disk space used by Git LFS (bytes) |
| details | Array | Breakdown of disk usage by project |
| details[].projectId | Number | Project identifier |
| details[].issue | Number | Project's issue storage (bytes) |
| details[].wiki | Number | Project's wiki storage (bytes) |
| details[].document | Number | Project's document storage (bytes) |
| details[].file | Number | Project's file storage (bytes) |
| details[].subversion | Number | Project's Subversion storage (bytes) |
| details[].git | Number | Project's Git storage (bytes) |
| details[].gitLFS | Number | Project's Git LFS storage (bytes) |

```json
{
    "capacity": 1073741824,
    "issue": 119511,
    "wiki": 48575,
    "file": 0,
    "subversion": 0,
    "git": 0,
    "gitLFS": 0,
    "details": [
        {
            "projectId": 1,
            "issue": 11931,
            "wiki": 0,
            "document": 0,
            "file": 0,
            "subversion": 0,
            "git": 0,
            "gitLFS": 0
        }
    ]
}
```

---

## Post Attachment File

- **Method**: POST
- **Path**: `/api/v2/space/attachment`
- **Scope**: Administrator, Normal User, Reporter, Guest Reporter
- **Content-Type**: multipart/form-data

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| file | File | Yes | The attachment file to upload (multipart/form-data) |

> **Note**: The uploaded file is temporary. It will be deleted after it has been attached to an issue or wiki page. If attachment fails, the file will be deleted one hour later.

### Response
- **Status**: 200 OK
- **Content-Type**: application/json; charset=utf-8

| Field | Type | Description |
|-------|------|-------------|
| id | Number | Unique identifier for the uploaded attachment |
| name | String | Original filename |
| size | Number | File size in bytes |

```json
{
    "id": 1,
    "name": "test.txt",
    "size": 8857
}
```
