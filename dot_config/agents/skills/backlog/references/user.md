# User API

## Table of Contents
- [Get User List](#get-user-list)
- [Get User](#get-user)
- [Add User](#add-user)
- [Update User](#update-user)
- [Delete User](#delete-user)
- [Get Own User](#get-own-user)
- [Get User Icon](#get-user-icon)
- [Get User Recent Updates](#get-user-recent-updates)
- [Get Received Star List](#get-received-star-list)
- [Count User Received Stars](#count-user-received-stars)
- [Get List of Recently Viewed Issues](#get-list-of-recently-viewed-issues)
- [Get List of Recently Viewed Projects](#get-list-of-recently-viewed-projects)
- [Get List of Recently Viewed Wikis](#get-list-of-recently-viewed-wikis)

---

## Get User List

- **Method**: GET
- **Path**: `/api/v2/users`
- **Scope**: Administrator, Project Administrator

### Parameters

No parameters.

### Response
- **Status**: 200 OK
- **Content-Type**: application/json

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

### Role Types

**Classic Plan:**

| Value | Role |
|-------|------|
| 1 | Administrator |
| 2 | Normal User |
| 3 | Reporter |
| 4 | Viewer |
| 5 | Guest Reporter |
| 6 | Guest Viewer |

**New Plan:**

| Value | Role |
|-------|------|
| 1 | Administrator |
| 2 | Member / Guest |
| 3 | Member / Guest (Add Issues Only) |
| 4 | Member / Guest (View Issues Only) |

---

## Get User

- **Method**: GET
- **Path**: `/api/v2/users/:userId`
- **Scope**: All

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| userId | Number | Yes | URL path parameter. The user's unique identifier. |

### Response
- **Status**: 200 OK
- **Content-Type**: application/json

```json
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
```

---

## Add User

- **Method**: POST
- **Path**: `/api/v2/users`
- **Scope**: Administrator, Project Administrator
- **Note**: This API is unavailable on new plan spaces. Project Administrators cannot create Administrator-level users.

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| userId | String | Yes | User's login ID |
| password | String | Yes | User's password |
| name | String | Yes | User's display name |
| mailAddress | String | Yes | User's email address |
| roleType | Number | Yes | Role type: Administrator(1), Normal User(2), Reporter(3), Viewer(4), Guest Reporter(5), Guest Viewer(6) |

### Response
- **Status**: 201 Created
- **Content-Type**: application/json
- **Location**: `https://xx.backlogtool.com/user/{userId}`

```json
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
```

---

## Update User

- **Method**: PATCH
- **Path**: `/api/v2/users/:userId`
- **Scope**: Administrator
- **Note**: This API is unavailable on new plan spaces.

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| userId | Number | Yes | URL path parameter. The user's unique identifier. |
| password | String | No | User's password |
| name | String | No | User's display name |
| mailAddress | String | No | User's email address |
| roleType | Number | No | Role type: Administrator(1), Normal User(2), Reporter(3), Viewer(4), Guest Reporter(5), Guest Viewer(6) |

### Response
- **Status**: 200 OK
- **Content-Type**: application/json

```json
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
```

---

## Delete User

- **Method**: DELETE
- **Path**: `/api/v2/users/:userId`
- **Scope**: Administrator
- **Note**: This API is unavailable on new plan spaces.

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| userId | Number | Yes | URL path parameter. The user's unique identifier. |

### Response
- **Status**: 200 OK
- **Content-Type**: application/json

```json
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
```

---

## Get Own User

- **Method**: GET
- **Path**: `/api/v2/users/myself`
- **Scope**: All

### Parameters

No parameters.

### Response
- **Status**: 200 OK
- **Content-Type**: application/json

```json
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
```

---

## Get User Icon

- **Method**: GET
- **Path**: `/api/v2/users/:userId/icon`
- **Scope**: All

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| userId | Number | Yes | URL path parameter. The user's unique identifier. |

### Response
- **Status**: 200 OK
- **Content-Type**: application/octet-stream
- **Content-Disposition**: `attachment;filename="person_168.gif"`

Binary image data of the user's icon.

---

## Get User Recent Updates

- **Method**: GET
- **Path**: `/api/v2/users/:userId/activities`
- **Scope**: All

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| userId | Number | Yes | URL path parameter. The user's unique identifier. |
| activityTypeId[] | Number | No | Activity type filter (1-26). Multiple values supported. |
| minId | Number | No | Minimum activity ID |
| maxId | Number | No | Maximum activity ID |
| count | Number | No | Number of records to retrieve (1-100). Default: 20 |
| order | String | No | Sort direction: "asc" or "desc". Default: "desc" |

### Activity Type IDs

| Type ID | Description |
|---------|-------------|
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
- **Content-Type**: application/json

> **Note**: The contents of `notifications` have been removed from the response body and modified to an empty array since February 9, 2022.

```json
[
    {
        "id": 3153,
        "project": {
            "id": 92,
            "projectKey": "SUB",
            "name": "Subtasking",
            "chartEnabled": true,
            "useResolvedForChart": true,
            "subtaskingEnabled": true,
            "projectLeaderCanEditProjectLeader": false,
            "useWiki": true,
            "useFileSharing": true,
            "useWikiTreeView": true,
            "useSubversion": true,
            "useGit": true,
            "useOriginalImageSizeAtWiki": false,
            "textFormattingRule": "backlog",
            "archived": false,
            "displayOrder": 3,
            "useDevAttributes": true
        },
        "type": 2,
        "content": {
            "id": 4809,
            "key_id": 121,
            "summary": "Comment",
            "description": "",
            "comment": {
                "id": 7237,
                "content": ""
            },
            "changes": [
                {
                    "field": "milestone",
                    "new_value": " R2014-07-23",
                    "old_value": "",
                    "type": "standard"
                },
                {
                    "field": "status",
                    "new_value": "4",
                    "old_value": "1",
                    "type": "standard"
                }
            ]
        },
        "notifications": [],
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
        "created": "2013-12-27T07:50:44Z"
    }
]
```

---

## Get Received Star List

- **Method**: GET
- **Path**: `/api/v2/users/:userId/stars`
- **Scope**: All

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| userId | Number | Yes | URL path parameter. The user's unique identifier. |
| minId | Number | No | Minimum star ID |
| maxId | Number | No | Maximum star ID |
| count | Number | No | Number of records to retrieve (1-100). Default: 20 |
| order | String | No | Sort direction: "asc" or "desc". Default: "desc" |

### Response
- **Status**: 200 OK
- **Content-Type**: application/json

```json
[
    {
        "id": 75,
        "comment": null,
        "url": "https://xx.backlogtool.com/view/BLG-1",
        "title": "[BLG-1] first issue | Show issue - Backlog",
        "presenter": {
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
        "created": "2014-01-23T10:55:19Z"
    }
]
```

---

## Count User Received Stars

- **Method**: GET
- **Path**: `/api/v2/users/:userId/stars/count`
- **Scope**: All

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| userId | Number | Yes | URL path parameter. The user's unique identifier. |
| since | String | No | Count stars after the given date (yyyy-MM-dd) |
| until | String | No | Count stars before the given date (yyyy-MM-dd) |

### Response
- **Status**: 200 OK
- **Content-Type**: application/json

```json
{
    "count": 54
}
```

---

## Get List of Recently Viewed Issues

- **Method**: GET
- **Path**: `/api/v2/users/myself/recentlyViewedIssues`
- **Scope**: All

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| order | String | No | Sort direction: "asc" or "desc". Default: "desc" |
| offset | Number | No | Pagination offset |
| count | Number | No | Number of records to retrieve (1-100). Default: 20 |

### Response
- **Status**: 200 OK
- **Content-Type**: application/json

```json
[
    {
        "issue": {
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
                    "archived": false
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
                    "dir": "/usericon/",
                    "name": "01.png",
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
        },
        "updated": "2014-07-11T02:00:00Z"
    }
]
```

---

## Get List of Recently Viewed Projects

- **Method**: GET
- **Path**: `/api/v2/users/myself/recentlyViewedProjects`
- **Scope**: All

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| order | String | No | Sort direction: "asc" or "desc". Default: "desc" |
| offset | Number | No | Pagination offset |
| count | Number | No | Number of records to retrieve (1-100). Default: 20 |

### Response
- **Status**: 200 OK
- **Content-Type**: application/json

```json
[
    {
        "project": {
            "id": 1,
            "projectKey": "TEST",
            "name": "test",
            "chartEnabled": true,
            "useResolvedForChart": true,
            "subtaskingEnabled": true,
            "projectLeaderCanEditProjectLeader": false,
            "useWiki": true,
            "useFileSharing": true,
            "useWikiTreeView": true,
            "useSubversion": false,
            "useGit": false,
            "useOriginalImageSizeAtWiki": false,
            "textFormattingRule": "backlog",
            "archived": false,
            "displayOrder": 3,
            "useDevAttributes": true
        },
        "updated": "2014-07-11T01:59:07Z"
    }
]
```

---

## Get List of Recently Viewed Wikis

- **Method**: GET
- **Path**: `/api/v2/users/myself/recentlyViewedWikis`
- **Scope**: All

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| order | String | No | Sort direction: "asc" or "desc". Default: "desc" |
| offset | Number | No | Pagination offset |
| count | Number | No | Number of records to retrieve (1-100). Default: 20 |

### Response
- **Status**: 200 OK
- **Content-Type**: application/json

```json
[
    {
        "page": {
            "id": 112,
            "projectId": 103,
            "name": "Home",
            "tags": [
                {
                    "id": 12,
                    "name": "proceedings"
                }
            ],
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
            "created": "2013-05-30T09:11:36Z",
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
            "updated": "2013-05-30T09:11:36Z"
        },
        "updated": "2014-07-16T07:18:16Z"
    }
]
```
