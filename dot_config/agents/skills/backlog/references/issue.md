# Issue API

## Table of Contents

### Issues
- [Get Issue List](#get-issue-list)
- [Count Issue](#count-issue)
- [Add Issue](#add-issue)
- [Get Issue](#get-issue)
- [Update Issue](#update-issue)
- [Delete Issue](#delete-issue)

### Comments
- [Get Comment List](#get-comment-list)
- [Add Comment](#add-comment)
- [Count Comment](#count-comment)
- [Get Comment](#get-comment)
- [Update Comment](#update-comment)
- [Delete Comment](#delete-comment)
- [Get List of Comment Notifications](#get-list-of-comment-notifications)
- [Add Comment Notification](#add-comment-notification)

### Issue Attachments
- [Get List of Issue Attachments](#get-list-of-issue-attachments)
- [Get Issue Attachment](#get-issue-attachment)
- [Delete Issue Attachment](#delete-issue-attachment)

### Issue Details
- [Get Issue Participant List](#get-issue-participant-list)
- [Get List of Linked Shared Files](#get-list-of-linked-shared-files)
- [Link Shared Files to Issue](#link-shared-files-to-issue)
- [Remove Link to Shared File from Issue](#remove-link-to-shared-file-from-issue)

---

## Get Issue List

- **Method**: GET
- **Path**: `/api/v2/issues`
- **Scope**: All

### Query Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectId[] | Number | No | Project ID (multiple allowed) |
| issueTypeId[] | Number | No | Issue Type ID (multiple allowed) |
| categoryId[] | Number | No | Category ID (multiple allowed) |
| versionId[] | Number | No | Version ID (multiple allowed) |
| milestoneId[] | Number | No | Milestone ID (multiple allowed) |
| statusId[] | Number | No | Status ID (multiple allowed) |
| priorityId[] | Number | No | Priority ID (multiple allowed) |
| assigneeId[] | Number | No | Assignee ID (multiple allowed) |
| createdUserId[] | Number | No | Creator ID (multiple allowed) |
| resolutionId[] | Number | No | Resolution ID (multiple allowed) |
| id[] | Number | No | Issue ID (multiple allowed) |
| parentIssueId[] | Number | No | Parent Issue ID (multiple allowed) |
| parentChild | Number | No | Subtask filter: 0=All, 1=Exclude child, 2=Child only, 3=Neither parent/child, 4=Parent only |
| attachment | Boolean | No | Filter issues with attachments |
| sharedFile | Boolean | No | Filter issues with shared files |
| sort | String | No | Sort field: issueType, category, version, milestone, summary, status, priority, attachment, sharedFile, created, createdUser, updated, updatedUser, assignee, startDate, dueDate, estimatedHours, actualHours, childIssue, customField_${id} |
| order | String | No | Sort order: "asc" or "desc" (default: "desc") |
| offset | Number | No | Pagination offset |
| count | Number | No | Records per page: 1-100 (default: 20) |
| createdSince | String | No | Created from date (yyyy-MM-dd) |
| createdUntil | String | No | Created to date (yyyy-MM-dd) |
| updatedSince | String | No | Updated from date (yyyy-MM-dd) |
| updatedUntil | String | No | Updated to date (yyyy-MM-dd) |
| startDateSince | String | No | Start date from (yyyy-MM-dd) |
| startDateUntil | String | No | Start date to (yyyy-MM-dd) |
| dueDateSince | String | No | Due date from (yyyy-MM-dd) |
| dueDateUntil | String | No | Due date to (yyyy-MM-dd) |
| hasDueDate | Boolean | No | Filter issues without due date (false only; true not supported) |
| keyword | String | No | Search keyword |
| customField_${id} | String | No | Custom text field search |
| customField_${id}_min | Number | No | Custom numeric field minimum |
| customField_${id}_max | Number | No | Custom numeric field maximum |
| customField_${id}_min | String | No | Custom date field from (yyyy-MM-dd) |
| customField_${id}_max | String | No | Custom date field to (yyyy-MM-dd) |
| customField_${id}[] | Number | No | Custom list field value IDs (multiple allowed) |

### Response
- **Status**: 200 OK

```json
[
    {
        "id": 1,
        "projectId": 1,
        "issueKey": "BLG-1",
        "keyId": 1,
        "issueType": {
            "id": 2,
            "projectId": 1,
            "name": "Task",
            "color": "#7ea800",
            "displayOrder": 0
        },
        "summary": "first issue",
        "description": "",
        "resolution": null,
        "priority": {
            "id": 3,
            "name": "Normal"
        },
        "status": {
            "id": 1,
            "projectId": 1,
            "name": "Open",
            "color": "#ed8077",
            "displayOrder": 1000
        },
        "assignee": {
            "id": 2,
            "userId": "eguchi",
            "name": "eguchi",
            "roleType": 2,
            "lang": null,
            "nulabAccount": {
                "nulabId": "tSaVeJfRxLURSAkgfbNAfCbM7PqddYLJ3nG3BELjx6eSTbu8LD",
                "name": "eguchi",
                "uniqueId": "eguchi"
            },
            "mailAddress": "eguchi@nulab.example",
            "lastLoginTime": "2022-09-01T06:35:39Z"
        },
        "category": [],
        "versions": [],
        "milestone": [
            {
                "id": 30,
                "projectId": 1,
                "name": "wait for release",
                "description": "",
                "startDate": null,
                "releaseDueDate": null,
                "archived": false,
                "displayOrder": 0
            }
        ],
        "startDate": null,
        "dueDate": null,
        "estimatedHours": null,
        "actualHours": null,
        "parentIssueId": null,
        "createdUser": {
            "id": 1,
            "userId": "admin",
            "name": "admin",
            "roleType": 1,
            "lang": "ja",
            "nulabAccount": {
                "nulabId": "Prm9ZD9DQD5snNWcSYSwZiQoA9WFBUEa2ySznrSnSQRhdC2X8G",
                "name": "admin",
                "uniqueId": "admin"
            },
            "mailAddress": "eguchi@nulab.example",
            "lastLoginTime": "2022-09-01T06:35:39Z"
        },
        "created": "2012-07-23T06:10:15Z",
        "updatedUser": {
            "id": 1,
            "userId": "admin",
            "name": "admin",
            "roleType": 1,
            "lang": "ja",
            "nulabAccount": {
                "nulabId": "Prm9ZD9DQD5snNWcSYSwZiQoA9WFBUEa2ySznrSnSQRhdC2X8G",
                "name": "admin",
                "uniqueId": "admin"
            },
            "mailAddress": "eguchi@nulab.example",
            "lastLoginTime": "2022-09-01T06:35:39Z"
        },
        "updated": "2013-02-07T08:09:49Z",
        "customFields": [],
        "attachments": [
            {
                "id": 1,
                "name": "IMGP0088.JPG",
                "size": 85079
            }
        ],
        "sharedFiles": [
            {
                "id": 454403,
                "projectId": 5,
                "type": "file",
                "dir": "/userIcon/",
                "name": "01_male clerk.png",
                "size": 2735,
                "createdUser": {
                    "id": 5686,
                    "userId": "takada",
                    "name": "takada",
                    "roleType": 2,
                    "lang": "ja",
                    "nulabAccount": {
                        "nulabId": "r4iGCWu4mU64aGUJykJH4GhBwdAXMTAtVRQ5RwZTDpeaECoBs2",
                        "name": "takada",
                        "uniqueId": "takada"
                    },
                    "mailAddress": "takada@nulab.example",
                    "lastLoginTime": "2022-09-01T06:35:39Z"
                },
                "created": "2009-02-27T03:26:15Z",
                "updatedUser": {
                    "id": 5686,
                    "userId": "takada",
                    "name": "takada",
                    "roleType": 2,
                    "lang": "ja",
                    "nulabAccount": {
                        "nulabId": "r4iGCWu4mU64aGUJykJH4GhBwdAXMTAtVRQ5RwZTDpeaECoBs2",
                        "name": "takada",
                        "uniqueId": "takada"
                    },
                    "mailAddress": "takada@nulab.example",
                    "lastLoginTime": "2022-09-01T06:35:39Z"
                },
                "updated": "2009-03-03T16:57:47Z"
            }
        ],
        "stars": [
            {
                "id": 10,
                "comment": null,
                "url": "https://xx.backlogtool.com/view/BLG-1",
                "title": "[BLG-1] first issue | Show issue - Backlog",
                "presenter": {
                    "id": 2,
                    "userId": "eguchi",
                    "name": "eguchi",
                    "roleType": 2,
                    "lang": "ja",
                    "nulabAccount": {
                        "nulabId": "tSaVeJfRxLURSAkgfbNAfCbM7PqddYLJ3nG3BELjx6eSTbu8LD",
                        "name": "eguchi",
                        "uniqueId": "eguchi"
                    },
                    "mailAddress": "eguchi@nulab.example",
                    "lastLoginTime": "2022-09-01T06:35:39Z"
                },
                "created": "2013-07-08T10:24:28Z"
            }
        ]
    }
]
```

---

## Count Issue

- **Method**: GET
- **Path**: `/api/v2/issues/count`
- **Scope**: All

### Query Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectId[] | Number | No | Project ID (multiple allowed) |
| issueTypeId[] | Number | No | Issue Type ID (multiple allowed) |
| categoryId[] | Number | No | Category ID (multiple allowed) |
| versionId[] | Number | No | Version ID (multiple allowed) |
| milestoneId[] | Number | No | Milestone ID (multiple allowed) |
| statusId[] | Number | No | Status ID (multiple allowed) |
| priorityId[] | Number | No | Priority ID (multiple allowed) |
| assigneeId[] | Number | No | Assignee ID (multiple allowed) |
| createdUserId[] | Number | No | Creator ID (multiple allowed) |
| resolutionId[] | Number | No | Resolution ID (multiple allowed) |
| id[] | Number | No | Issue ID (multiple allowed) |
| parentIssueId[] | Number | No | Parent Issue ID (multiple allowed) |
| parentChild | Number | No | Subtask filter: 0=All, 1=Exclude child, 2=Child only, 3=Neither, 4=Parent only |
| attachment | Boolean | No | Filter issues with attachments |
| sharedFile | Boolean | No | Filter issues with shared files |
| sort | String | No | Sort field (same options as Get Issue List) |
| order | String | No | Sort order: "asc" or "desc" (default: "desc") |
| offset | Number | No | Pagination offset |
| count | Number | No | Records to retrieve: 1-100 (default: 20) |
| createdSince | String | No | Created from date (yyyy-MM-dd) |
| createdUntil | String | No | Created to date (yyyy-MM-dd) |
| updatedSince | String | No | Updated from date (yyyy-MM-dd) |
| updatedUntil | String | No | Updated to date (yyyy-MM-dd) |
| startDateSince | String | No | Start date from (yyyy-MM-dd) |
| startDateUntil | String | No | Start date to (yyyy-MM-dd) |
| dueDateSince | String | No | Due date from (yyyy-MM-dd) |
| dueDateUntil | String | No | Due date to (yyyy-MM-dd) |
| hasDueDate | Boolean | No | Filter issues without due date (false only) |
| keyword | String | No | Search keyword |
| customField_${id} | String | No | Custom text field search |
| customField_${id}_min | Number | No | Custom numeric field minimum |
| customField_${id}_max | Number | No | Custom numeric field maximum |
| customField_${id}[] | Number | No | Custom list field value IDs (multiple allowed) |

### Response
- **Status**: 200 OK

```json
{
    "count": 43
}
```

---

## Add Issue

- **Method**: POST
- **Path**: `/api/v2/issues`
- **Scope**: Administrator, Normal User, Reporter, Guest Reporter

### Form Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectId | Number | Yes | Project ID |
| summary | String | Yes | Summary |
| issueTypeId | Number | Yes | Issue Type ID |
| priorityId | Number | Yes | Priority ID |
| parentIssueId | Number | No | Parent Issue ID |
| description | String | No | Description |
| startDate | String | No | Start Date (yyyy-MM-dd) |
| dueDate | String | No | Due Date (yyyy-MM-dd) |
| estimatedHours | Number | No | Estimated Hours |
| actualHours | Number | No | Actual Hours |
| categoryId[] | Number | No | Category ID (multiple allowed) |
| versionId[] | Number | No | Version ID (multiple allowed) |
| milestoneId[] | Number | No | Milestone ID (multiple allowed) |
| assigneeId | Number | No | Assignee ID |
| notifiedUserId[] | Number | No | Notified User ID (multiple allowed) |
| attachmentId[] | Number | No | Attachment file ID (multiple allowed) |
| customField_${id} | String/Number | No | Custom field value |
| customField_${id}_otherValue | String | No | Other text of List type custom field |

### Response
- **Status**: 201 Created

Response body is the same issue object structure as [Get Issue](#get-issue).

---

## Get Issue

- **Method**: GET
- **Path**: `/api/v2/issues/:issueIdOrKey`
- **Scope**: All

### URL Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| issueIdOrKey | String | Yes | Issue ID or Issue Key |

### Response
- **Status**: 200 OK

```json
{
    "id": 1,
    "projectId": 1,
    "issueKey": "BLG-1",
    "keyId": 1,
    "issueType": {
        "id": 2,
        "projectId": 1,
        "name": "Task",
        "color": "#7ea800",
        "displayOrder": 0
    },
    "summary": "first issue",
    "description": "",
    "resolution": null,
    "priority": {
        "id": 3,
        "name": "Normal"
    },
    "status": {
        "id": 1,
        "projectId": 1,
        "name": "Open",
        "color": "#ed8077",
        "displayOrder": 1000
    },
    "assignee": {
        "id": 2,
        "userId": "eguchi",
        "name": "eguchi",
        "roleType": 2,
        "lang": null,
        "nulabAccount": {
            "nulabId": "tSaVeJfRxLURSAkgfbNAfCbM7PqddYLJ3nG3BELjx6eSTbu8LD",
            "name": "eguchi",
            "uniqueId": "eguchi"
        },
        "mailAddress": "eguchi@nulab.example",
        "lastLoginTime": "2022-09-01T06:35:39Z"
    },
    "category": [],
    "versions": [],
    "milestone": [
        {
            "id": 30,
            "projectId": 1,
            "name": "wait for release",
            "description": "",
            "startDate": null,
            "releaseDueDate": null,
            "archived": false,
            "displayOrder": 0
        }
    ],
    "startDate": null,
    "dueDate": null,
    "estimatedHours": null,
    "actualHours": null,
    "parentIssueId": null,
    "createdUser": {
        "id": 1,
        "userId": "admin",
        "name": "admin",
        "roleType": 1,
        "lang": "ja",
        "nulabAccount": {
            "nulabId": "Prm9ZD9DQD5snNWcSYSwZiQoA9WFBUEa2ySznrSnSQRhdC2X8G",
            "name": "admin",
            "uniqueId": "admin"
        },
        "mailAddress": "eguchi@nulab.example",
        "lastLoginTime": "2022-09-01T06:35:39Z"
    },
    "created": "2012-07-23T06:10:15Z",
    "updatedUser": {
        "id": 1,
        "userId": "admin",
        "name": "admin",
        "roleType": 1,
        "lang": "ja",
        "nulabAccount": {
            "nulabId": "Prm9ZD9DQD5snNWcSYSwZiQoA9WFBUEa2ySznrSnSQRhdC2X8G",
            "name": "admin",
            "uniqueId": "admin"
        },
        "mailAddress": "eguchi@nulab.example",
        "lastLoginTime": "2022-09-01T06:35:39Z"
    },
    "updated": "2013-02-07T08:09:49Z",
    "customFields": [],
    "attachments": [
        {
            "id": 1,
            "name": "IMGP0088.JPG",
            "size": 85079
        }
    ],
    "sharedFiles": [],
    "stars": [
        {
            "id": 10,
            "comment": null,
            "url": "https://xx.backlogtool.com/view/BLG-1",
            "title": "[BLG-1] first issue | Show issue - Backlog",
            "presenter": {
                "id": 2,
                "userId": "eguchi",
                "name": "eguchi",
                "roleType": 2,
                "lang": "ja",
                "nulabAccount": {
                    "nulabId": "tSaVeJfRxLURSAkgfbNAfCbM7PqddYLJ3nG3BELjx6eSTbu8LD",
                    "name": "eguchi",
                    "uniqueId": "eguchi"
                },
                "mailAddress": "eguchi@nulab.example",
                "lastLoginTime": "2022-09-01T06:35:39Z"
            },
            "created": "2013-07-08T10:24:28Z"
        }
    ]
}
```

---

## Update Issue

- **Method**: PATCH
- **Path**: `/api/v2/issues/:issueIdOrKey`
- **Scope**: Administrator, Normal User

### URL Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| issueIdOrKey | String | Yes | Issue ID or Issue Key |

### Form Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| summary | String | No | Summary |
| parentIssueId | Number | No | Parent Issue ID |
| description | String | No | Description |
| statusId | Number | No | Status ID |
| resolutionId | Number | No | Resolution ID |
| startDate | String | No | Start Date (yyyy-MM-dd) |
| dueDate | String | No | Due Date (yyyy-MM-dd) |
| estimatedHours | Number | No | Estimated Hours |
| actualHours | Number | No | Actual Hours |
| issueTypeId | Number | No | Issue Type ID |
| categoryId[] | Number | No | Category ID (multiple allowed) |
| versionId[] | Number | No | Version ID (multiple allowed) |
| milestoneId[] | Number | No | Milestone ID (multiple allowed) |
| priorityId | Number | No | Priority ID |
| assigneeId | Number | No | Assignee ID |
| notifiedUserId[] | Number | No | Notified User ID (multiple allowed) |
| attachmentId[] | Number | No | Attachment file ID (multiple allowed) |
| comment | String | No | Comment |
| customField_${id} | String/Number | No | Custom field value |
| customField_${id}_otherValue | String | No | Other text of List type custom field |

### Response
- **Status**: 200 OK

Response body is the same issue object structure as [Get Issue](#get-issue).

---

## Delete Issue

- **Method**: DELETE
- **Path**: `/api/v2/issues/:issueIdOrKey`
- **Scope**: Administrator, Project Administrator

### URL Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| issueIdOrKey | String | Yes | Issue ID or Issue Key |

### Response
- **Status**: 200 OK

Response body is the same issue object structure as [Get Issue](#get-issue).

---

## Get Comment List

- **Method**: GET
- **Path**: `/api/v2/issues/:issueIdOrKey/comments`
- **Scope**: All

### URL Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| issueIdOrKey | String | Yes | Issue ID or Issue Key |

### Query Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| minId | Number | No | Minimum comment ID |
| maxId | Number | No | Maximum comment ID |
| count | Number | No | Records to retrieve: 1-100 (default: 20) |
| order | String | No | Sort order: "asc" or "desc" (default: "desc") |

### Response
- **Status**: 200 OK

```json
[
    {
        "id": 6586,
        "projectId": 5,
        "issueId": 50,
        "content": "test",
        "changeLog": null,
        "createdUser": {
            "id": 1,
            "userId": "admin",
            "name": "admin",
            "roleType": 1,
            "lang": "ja",
            "nulabAccount": {
                "nulabId": "Prm9ZD9DQD5snNWcSYSwZiQoA9WFBUEa2ySznrSnSQRhdC2X8G",
                "name": "admin",
                "uniqueId": "admin"
            },
            "mailAddress": "eguchi@nulab.example",
            "lastLoginTime": "2022-09-01T06:35:39Z"
        },
        "created": "2013-08-05T06:15:06Z",
        "updated": "2013-08-05T06:15:06Z",
        "stars": [],
        "notifications": []
    }
]
```

---

## Add Comment

- **Method**: POST
- **Path**: `/api/v2/issues/:issueIdOrKey/comments`
- **Scope**: Administrator, Normal User, Reporter, Guest Reporter

### URL Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| issueIdOrKey | String | Yes | Issue ID or Issue Key |

### Form Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| content | String | Yes | Comment text |
| notifiedUserId[] | Number | No | User IDs to notify (multiple allowed) |
| attachmentId[] | Number | No | Attachment file IDs (multiple allowed) |

### Response
- **Status**: 201 Created

```json
{
    "id": 6586,
    "projectId": 5,
    "issueId": 50,
    "content": "test",
    "changeLog": null,
    "createdUser": {
        "id": 1,
        "userId": "admin",
        "name": "admin",
        "roleType": 1,
        "lang": "ja",
        "nulabAccount": {
            "nulabId": "Prm9ZD9DQD5snNWcSYSwZiQoA9WFBUEa2ySznrSnSQRhdC2X8G",
            "name": "admin",
            "uniqueId": "admin"
        },
        "mailAddress": "eguchi@nulab.example",
        "lastLoginTime": "2022-09-01T06:35:39Z"
    },
    "created": "2013-08-05T06:15:06Z",
    "updated": "2013-08-05T06:15:06Z",
    "stars": [],
    "notifications": []
}
```

---

## Count Comment

- **Method**: GET
- **Path**: `/api/v2/issues/:issueIdOrKey/comments/count`
- **Scope**: All

### URL Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| issueIdOrKey | String | Yes | Issue ID or Issue Key |

### Response
- **Status**: 200 OK

```json
{
    "count": 10
}
```

---

## Get Comment

- **Method**: GET
- **Path**: `/api/v2/issues/:issueIdOrKey/comments/:commentId`
- **Scope**: All

### URL Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| issueIdOrKey | String | Yes | Issue ID or Issue Key |
| commentId | Number | Yes | Comment ID |

### Response
- **Status**: 200 OK

```json
{
    "id": 6586,
    "projectId": 5,
    "issueId": 50,
    "content": "test",
    "changeLog": null,
    "createdUser": {
        "id": 1,
        "userId": "admin",
        "name": "admin",
        "roleType": 1,
        "lang": "ja",
        "nulabAccount": {
            "nulabId": "Prm9ZD9DQD5snNWcSYSwZiQoA9WFBUEa2ySznrSnSQRhdC2X8G",
            "name": "admin",
            "uniqueId": "admin"
        },
        "mailAddress": "eguchi@nulab.example",
        "lastLoginTime": "2022-09-01T06:35:39Z"
    },
    "created": "2013-08-05T06:15:06Z",
    "updated": "2013-08-05T06:15:06Z",
    "stars": [],
    "notifications": []
}
```

---

## Update Comment

- **Method**: PATCH
- **Path**: `/api/v2/issues/:issueIdOrKey/comments/:commentId`
- **Scope**: Administrator, Normal User, Reporter, Guest Reporter
- **Note**: Users can only update their own comments.

### URL Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| issueIdOrKey | String | Yes | Issue ID or Issue Key |
| commentId | Number | Yes | Comment ID |

### Form Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| content | String | Yes | Updated comment text |

### Response
- **Status**: 200 OK

Response body is the same comment object structure as [Get Comment](#get-comment).

---

## Delete Comment

- **Method**: DELETE
- **Path**: `/api/v2/issues/:issueIdOrKey/comments/:commentId`
- **Scope**: All (users can delete own comment)

### URL Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| issueIdOrKey | String | Yes | Issue ID or Issue Key |
| commentId | Number | Yes | Comment ID |

### Response
- **Status**: 200 OK

Response body is the same comment object structure as [Get Comment](#get-comment).

---

## Get List of Comment Notifications

- **Method**: GET
- **Path**: `/api/v2/issues/:issueIdOrKey/comments/:commentId/notifications`
- **Scope**: All

### URL Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| issueIdOrKey | String | Yes | Issue ID or Issue Key |
| commentId | Number | Yes | Comment ID |

### Response
- **Status**: 200 OK

#### Notification Reason Codes

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
        "user": {
            "id": 1,
            "userId": "admin",
            "name": "admin",
            "roleType": 1,
            "lang": "ja",
            "nulabAccount": {
                "nulabId": "Prm9ZD9DQD5snNWcSYSwZiQoA9WFBUEa2ySznrSnSQRhdC2X8G",
                "name": "admin",
                "uniqueId": "admin"
            },
            "mailAddress": "eguchi@nulab.example",
            "lastLoginTime": "2022-09-01T06:35:39Z"
        },
        "resourceAlreadyRead": false
    }
]
```

---

## Add Comment Notification

- **Method**: POST
- **Path**: `/api/v2/issues/:issueIdOrKey/comments/:commentId/notifications`
- **Scope**: Administrator, Normal User, Reporter, Guest Reporter
- **Note**: Only the comment's original author can add notifications.

### URL Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| issueIdOrKey | String | Yes | Issue ID or Issue Key |
| commentId | Number | Yes | Comment ID |

### Form Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| notifiedUserId[] | Number | Yes | User IDs to notify (multiple allowed) |

### Response
- **Status**: 200 OK

```json
{
    "id": 6586,
    "projectId": 5,
    "issueId": 50,
    "content": "This is a comment",
    "changeLog": null,
    "createdUser": {
        "id": 1,
        "userId": "admin",
        "name": "admin",
        "roleType": 1,
        "lang": "ja",
        "nulabAccount": {
            "nulabId": "Prm9ZD9DQD5snNWcSYSwZiQoA9WFBUEa2ySznrSnSQRhdC2X8G",
            "name": "admin",
            "uniqueId": "admin"
        },
        "mailAddress": "eguchi@nulab.example",
        "lastLoginTime": "2022-09-01T06:35:39Z"
    },
    "created": "2013-08-05T06:15:06Z",
    "updated": "2013-08-05T06:15:06Z",
    "stars": [],
    "notifications": [
        {
            "id": 22,
            "alreadyRead": false,
            "reason": 2,
            "user": {
                "id": 1,
                "userId": "admin",
                "name": "admin",
                "roleType": 1,
                "lang": "ja",
                "nulabAccount": {
                    "nulabId": "Prm9ZD9DQD5snNWcSYSwZiQoA9WFBUEa2ySznrSnSQRhdC2X8G",
                    "name": "admin",
                    "uniqueId": "admin"
                },
                "mailAddress": "eguchi@nulab.example",
                "lastLoginTime": "2022-09-01T06:35:39Z"
            },
            "resourceAlreadyRead": false
        }
    ]
}
```

---

## Get List of Issue Attachments

- **Method**: GET
- **Path**: `/api/v2/issues/:issueIdOrKey/attachments`
- **Scope**: All

### URL Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| issueIdOrKey | String | Yes | Issue ID or Issue Key |

### Response
- **Status**: 200 OK

```json
[
    {
        "id": 8,
        "name": "IMG0088.png",
        "size": 5563,
        "createdUser": {
            "id": 1,
            "userId": "admin",
            "name": "admin",
            "roleType": 1,
            "lang": "ja",
            "nulabAccount": {
                "nulabId": "Prm9ZD9DQD5snNWcSYSwZiQoA9WFBUEa2ySznrSnSQRhdC2X8G",
                "name": "admin",
                "uniqueId": "admin"
            },
            "mailAddress": "eguchi@nulab.example",
            "lastLoginTime": "2022-09-01T06:35:39Z"
        },
        "created": "2014-10-28T09:24:43Z"
    }
]
```

---

## Get Issue Attachment

- **Method**: GET
- **Path**: `/api/v2/issues/:issueIdOrKey/attachments/:attachmentId`
- **Scope**: Administrator, Normal User, Reporter, Guest Reporter

### URL Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| issueIdOrKey | String | Yes | Issue ID or Issue Key |
| attachmentId | Number | Yes | Attachment file ID |

### Response
- **Status**: 200 OK
- **Content-Type**: application/octet-stream
- **Content-Disposition**: attachment;filename="<filename>"

Response body is the binary file content.

---

## Delete Issue Attachment

- **Method**: DELETE
- **Path**: `/api/v2/issues/:issueIdOrKey/attachments/:attachmentId`
- **Scope**: Administrator, Normal User

### URL Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| issueIdOrKey | String | Yes | Issue ID or Issue Key |
| attachmentId | Number | Yes | Attachment file ID |

### Response
- **Status**: 200 OK

```json
{
    "id": 8,
    "name": "IMG0088.png",
    "size": 5563,
    "createdUser": {
        "id": 1,
        "userId": "admin",
        "name": "admin",
        "roleType": 1,
        "lang": "ja",
        "nulabAccount": {
            "nulabId": "Prm9ZD9DQD5snNWcSYSwZiQoA9WFBUEa2ySznrSnSQRhdC2X8G",
            "name": "admin",
            "uniqueId": "admin"
        },
        "mailAddress": "eguchi@nulab.example",
        "lastLoginTime": "2022-09-01T06:35:39Z"
    },
    "created": "2014-10-28T09:24:43Z"
}
```

---

## Get Issue Participant List

- **Method**: GET
- **Path**: `/api/v2/issues/:issueIdOrKey/participants`
- **Scope**: All

### URL Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| issueIdOrKey | String | Yes | Issue ID or Issue Key |

### Response
- **Status**: 200 OK

```json
[
    {
        "id": 1,
        "userId": "admin",
        "name": "admin",
        "roleType": 1,
        "lang": "ja",
        "nulabAccount": {
            "nulabId": "Prm9ZD9DQD5snNWcSYSwZiQoA9WFBUEa2ySznrSnSQRhdC2X8G",
            "name": "admin",
            "uniqueId": "admin"
        },
        "mailAddress": "eguchi@nulab.example",
        "lastLoginTime": "2022-09-01T06:35:39Z"
    }
]
```

---

## Get List of Linked Shared Files

- **Method**: GET
- **Path**: `/api/v2/issues/:issueIdOrKey/sharedFiles`
- **Scope**: Administrator, Normal User

### URL Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| issueIdOrKey | String | Yes | Issue ID or Issue Key |

### Response
- **Status**: 200 OK

```json
[
    {
        "id": 4056,
        "projectId": 5,
        "type": "file",
        "dir": "/design/",
        "name": "site.png",
        "size": 2735,
        "createdUser": {
            "id": 5686,
            "userId": "takada",
            "name": "takada",
            "roleType": 2,
            "lang": "ja",
            "nulabAccount": {
                "nulabId": "r4iGCWu4mU64aGUJykJH4GhBwdAXMTAtVRQ5RwZTDpeaECoBs2",
                "name": "takada",
                "uniqueId": "takada"
            },
            "mailAddress": "takada@nulab.example",
            "lastLoginTime": "2022-09-01T06:35:39Z"
        },
        "created": "2009-02-27T03:26:15Z",
        "updatedUser": {
            "id": 5686,
            "userId": "takada",
            "name": "takada",
            "roleType": 2,
            "lang": "ja",
            "nulabAccount": {
                "nulabId": "r4iGCWu4mU64aGUJykJH4GhBwdAXMTAtVRQ5RwZTDpeaECoBs2",
                "name": "takada",
                "uniqueId": "takada"
            },
            "mailAddress": "takada@nulab.example",
            "lastLoginTime": "2022-09-01T06:35:39Z"
        },
        "updated": "2010-05-02T17:37:10Z"
    }
]
```

---

## Link Shared Files to Issue

- **Method**: POST
- **Path**: `/api/v2/issues/:issueIdOrKey/sharedFiles`
- **Scope**: Administrator, Normal User

### URL Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| issueIdOrKey | String | Yes | Issue ID or Issue Key |

### Form Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| fileId[] | Number | Yes | Shared File ID (multiple allowed) |

### Response
- **Status**: 200 OK

```json
[
    {
        "id": 4056,
        "projectId": 5,
        "type": "file",
        "dir": "/design/",
        "name": "site.png",
        "size": 2735,
        "createdUser": {
            "id": 5686,
            "userId": "takada",
            "name": "takada",
            "roleType": 2,
            "lang": "ja",
            "nulabAccount": {
                "nulabId": "r4iGCWu4mU64aGUJykJH4GhBwdAXMTAtVRQ5RwZTDpeaECoBs2",
                "name": "takada",
                "uniqueId": "takada"
            },
            "mailAddress": "takada@nulab.example",
            "lastLoginTime": "2022-09-01T06:35:39Z"
        },
        "created": "2009-02-27T03:26:15Z",
        "updatedUser": {
            "id": 5686,
            "userId": "takada",
            "name": "takada",
            "roleType": 2,
            "lang": "ja",
            "nulabAccount": {
                "nulabId": "r4iGCWu4mU64aGUJykJH4GhBwdAXMTAtVRQ5RwZTDpeaECoBs2",
                "name": "takada",
                "uniqueId": "takada"
            },
            "mailAddress": "takada@nulab.example",
            "lastLoginTime": "2022-09-01T06:35:39Z"
        },
        "updated": "2010-05-02T17:37:10Z"
    }
]
```

---

## Remove Link to Shared File from Issue

- **Method**: DELETE
- **Path**: `/api/v2/issues/:issueIdOrKey/sharedFiles/:id`
- **Scope**: Administrator, Normal User

### URL Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| issueIdOrKey | String | Yes | Issue ID or Issue Key |
| id | Number | Yes | Shared File ID |

### Response
- **Status**: 200 OK

```json
{
    "id": 4056,
    "projectId": 5,
    "type": "file",
    "dir": "/design/",
    "name": "site.png",
    "size": 2735,
    "createdUser": {
        "id": 5686,
        "userId": "takada",
        "name": "takada",
        "roleType": 2,
        "lang": "ja",
        "nulabAccount": {
            "nulabId": "r4iGCWu4mU64aGUJykJH4GhBwdAXMTAtVRQ5RwZTDpeaECoBs2",
            "name": "takada",
            "uniqueId": "takada"
        },
        "mailAddress": "takada@nulab.example",
        "lastLoginTime": "2022-09-01T06:35:39Z"
    },
    "created": "2009-02-27T03:26:15Z",
    "updatedUser": {
        "id": 5686,
        "userId": "takada",
        "name": "takada",
        "roleType": 2,
        "lang": "ja",
        "nulabAccount": {
            "nulabId": "r4iGCWu4mU64aGUJykJH4GhBwdAXMTAtVRQ5RwZTDpeaECoBs2",
            "name": "takada",
            "uniqueId": "takada"
        },
        "mailAddress": "takada@nulab.example",
        "lastLoginTime": "2022-09-01T06:35:39Z"
    },
    "updated": "2010-05-02T17:37:10Z"
}
```
