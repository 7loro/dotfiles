# Notification API

## Table of Contents
- [Get Notification](#get-notification)
- [Count Notification](#count-notification)
- [Reset Unread Notification Count](#reset-unread-notification-count)
- [Read Notification](#read-notification)

---

## Get Notification

- **Method**: GET
- **Path**: `/api/v2/notifications`
- **Scope**: All

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| minId | Number | No | Minimum notification ID for filtering |
| maxId | Number | No | Maximum notification ID for filtering |
| count | Number | No | Records to retrieve (1-100, default: 20) |
| order | String | No | Sort direction: `"asc"` or `"desc"` |
| senderId | Number | No | Filter by sender's user ID |

### Response
- **Status**: 200 OK

### Notification Reason Codes

| Code | Description |
|------|-------------|
| 1 | Assigned to Issue |
| 2 | Issue Commented |
| 3 | Issue Created |
| 4 | Issue Updated |
| 5 | File Added |
| 6 | Project User Added |
| 9 | Other |
| 10 | Assigned to Pull Request |
| 11 | Comment Added on Pull Request |
| 12 | Pull Request Added |
| 13 | Pull Request Updated |

```json
[
    {
        "id": 22,
        "alreadyRead": false,
        "reason": 2,
        "resourceAlreadyRead": false,
        "project": {
            "id": 92,
            "projectKey": "SUB",
            "name": "subtasking",
            "chartEnabled": true,
            "subtaskingEnabled": true,
            "textFormattingRule": "markdown",
            "archived": false,
            "displayOrder": 0
        },
        "issue": {
            "id": 4809,
            "projectId": 92,
            "issueKey": "SUB-71",
            "keyId": 71,
            "issueType": {
                "id": 7,
                "projectId": 92,
                "name": "Bug",
                "color": "#990000",
                "displayOrder": 0
            },
            "summary": "test",
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
            "created": "2013-08-02T07:23:52Z",
            "updatedUser": {},
            "updated": "2013-08-02T07:23:52Z",
            "customFields": [],
            "attachments": [],
            "sharedFiles": [],
            "stars": []
        },
        "comment": {
            "id": 7237,
            "content": "test"
        },
        "sender": {
            "id": 1,
            "userId": "admin",
            "name": "admin",
            "roleType": 1,
            "lang": "ja",
            "mailAddress": "eguchi@nulab.example"
        },
        "created": "2013-08-02T07:23:52Z"
    }
]
```

---

## Count Notification

- **Method**: GET
- **Path**: `/api/v2/notifications/count`
- **Scope**: All

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| resourceAlreadyRead | Boolean | No | Set to `false` for unread notification count, `true` for already-read count |
| alreadyRead | Boolean | No | Set to `false` to get unread count since last check, `true` for already-read count |

### Response
- **Status**: 200 OK

```json
{
    "count": 138
}
```

---

## Reset Unread Notification Count

- **Method**: POST
- **Path**: `/api/v2/notifications/markAsRead`
- **Scope**: All

### Parameters

None.

### Response
- **Status**: 200 OK

```json
{
    "count": 4
}
```

---

## Read Notification

- **Method**: POST
- **Path**: `/api/v2/notifications/:id/markAsRead`
- **Scope**: All

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| id | Number | Yes | Notification ID (URL parameter) |

### Response
- **Status**: 204 No Content
