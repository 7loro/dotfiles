# Team & Licence API

## Table of Contents
- [Get Licence](#get-licence)
- [Get List of Teams](#get-list-of-teams)
- [Add Team](#add-team)
- [Get Team](#get-team)
- [Update Team](#update-team)
- [Delete Team](#delete-team)
- [Get Team Icon](#get-team-icon)
- [Get Project Team List](#get-project-team-list)
- [Add Project Team](#add-project-team)
- [Delete Project Team](#delete-project-team)

---

## Get Licence

- **Method**: GET
- **Path**: `/api/v2/space/licence`
- **Scope**: All

### Parameters

None.

### Response
- **Status**: 200 OK

```json
{
    "active": true,
    "attachmentLimit": 1073741824,
    "attachmentLimitPerFile": 10485760,
    "attachmentNumLimit": 0,
    "attribute": true,
    "attributeLimit": 10,
    "burndown": true,
    "commentLimit": 0,
    "componentLimit": 0,
    "fileSharing": true,
    "gantt": true,
    "git": true,
    "issueLimit": 0,
    "licenceTypeId": 11,
    "limitDate": "2019-06-18T00:00:00Z",
    "nulabAccount": true,
    "parentChildIssue": true,
    "postIssueByMail": true,
    "projectLimit": 100,
    "storageLimit": 10737418240,
    "userLimit": 100,
    "wikiAttachment": true,
    "wikiAttachmentLimitPerFile": 10485760,
    "wikiAttachmentNumLimit": 0
}
```

### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| active | Boolean | License activation status |
| attachmentLimit | Number | Maximum attachment storage (bytes) |
| attachmentLimitPerFile | Number | Size limit per attachment file (bytes) |
| attachmentNumLimit | Number | Number of attachments allowed (0 = unlimited) |
| attribute | Boolean | Custom attributes feature enabled |
| attributeLimit | Number | Maximum custom attributes |
| burndown | Boolean | Burndown chart feature enabled |
| commentLimit | Number | Comment limit (0 = unlimited) |
| componentLimit | Number | Component limit (0 = unlimited) |
| fileSharing | Boolean | File sharing capability enabled |
| gantt | Boolean | Gantt chart feature enabled |
| git | Boolean | Git repository support enabled |
| issueLimit | Number | Issue limit (0 = unlimited) |
| licenceTypeId | Number | License type identifier |
| limitDate | String | License expiration date (ISO 8601) |
| nulabAccount | Boolean | Nulab account integration enabled |
| parentChildIssue | Boolean | Hierarchical issue support enabled |
| postIssueByMail | Boolean | Email issue posting enabled |
| projectLimit | Number | Maximum number of projects |
| storageLimit | Number | Total storage allocation (bytes) |
| userLimit | Number | Maximum number of user accounts |
| wikiAttachment | Boolean | Wiki attachment support enabled |

---

## Get List of Teams

- **Method**: GET
- **Path**: `/api/v2/teams`
- **Scope**: Administrator, Project Administrator

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| order | String | No | Sort order: `"asc"` or `"desc"` (default: `"desc"`) |
| offset | Number | No | Pagination offset |
| count | Number | No | Records to retrieve (1-100, default: 20) |

### Response
- **Status**: 200 OK

```json
[
    {
        "id": 1,
        "name": "test",
        "members": [
            {
                "id": 2,
                "userId": "developer",
                "name": "developer",
                "roleType": 2,
                "lang": "ja",
                "nulabAccount": {
                    "nulabId": "abcdefghijklmnopqrstuvwxyz",
                    "name": "developer",
                    "uniqueId": "developer"
                },
                "mailAddress": "developer@nulab.example",
                "lastLoginTime": "2022-09-01T06:35:39Z"
            }
        ],
        "displayOrder": null,
        "createdUser": {
            "id": 1,
            "userId": "admin",
            "name": "admin",
            "roleType": 1,
            "lang": "ja",
            "mailAddress": "eguchi@nulab.example"
        },
        "created": "2013-05-30T09:11:36Z",
        "updatedUser": {
            "id": 1,
            "userId": "admin",
            "name": "admin",
            "roleType": 1,
            "lang": "ja",
            "mailAddress": "eguchi@nulab.example"
        },
        "updated": "2013-05-30T09:11:36Z"
    }
]
```

---

## Add Team

- **Method**: POST
- **Path**: `/api/v2/teams`
- **Scope**: Administrator
- **Content-Type**: `application/x-www-form-urlencoded`

> Note: You can't use this API at new plan space.

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| name | String | Yes | Team (group) name |
| members[] | Number | No | User IDs to add to the team (multiple allowed) |

### Response
- **Status**: 200 OK

```json
{
    "id": 1,
    "name": "test",
    "members": [
        {
            "id": 2,
            "userId": "developer",
            "name": "developer",
            "roleType": 2,
            "lang": "ja",
            "nulabAccount": {
                "nulabId": "abcdefghijklmnopqrstuvwxyz",
                "name": "developer",
                "uniqueId": "developer"
            },
            "mailAddress": "developer@nulab.example",
            "lastLoginTime": "2022-09-01T06:35:39Z"
        }
    ],
    "displayOrder": null,
    "createdUser": {
        "id": 1,
        "userId": "admin",
        "name": "admin",
        "roleType": 1,
        "lang": "ja",
        "mailAddress": "eguchi@nulab.example"
    },
    "created": "2013-05-30T09:11:36Z",
    "updatedUser": {
        "id": 1,
        "userId": "admin",
        "name": "admin",
        "roleType": 1,
        "lang": "ja",
        "mailAddress": "eguchi@nulab.example"
    },
    "updated": "2013-05-30T09:11:36Z"
}
```

---

## Get Team

- **Method**: GET
- **Path**: `/api/v2/teams/:teamId`
- **Scope**: Administrator

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| teamId | Number | Yes | Team ID (URL parameter) |

### Response
- **Status**: 200 OK

```json
{
    "id": 1,
    "name": "test",
    "members": [
        {
            "id": 2,
            "userId": "developer",
            "name": "developer",
            "roleType": 2,
            "lang": "ja",
            "nulabAccount": {
                "nulabId": "abcdefghijklmnopqrstuvwxyz",
                "name": "developer",
                "uniqueId": "developer"
            },
            "mailAddress": "developer@nulab.example",
            "lastLoginTime": "2022-09-01T06:35:39Z"
        }
    ],
    "displayOrder": null,
    "createdUser": {
        "id": 1,
        "userId": "admin",
        "name": "admin",
        "roleType": 1,
        "lang": "ja",
        "mailAddress": "eguchi@nulab.example"
    },
    "created": "2013-05-30T09:11:36Z",
    "updatedUser": {
        "id": 1,
        "userId": "admin",
        "name": "admin",
        "roleType": 1,
        "lang": "ja",
        "mailAddress": "eguchi@nulab.example"
    },
    "updated": "2013-05-30T09:11:36Z"
}
```

---

## Update Team

- **Method**: PATCH
- **Path**: `/api/v2/teams/:teamId`
- **Scope**: Administrator
- **Content-Type**: `application/x-www-form-urlencoded`

> Note: This API is unavailable on new plan spaces.

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| teamId | Number | Yes | Team ID (URL parameter) |
| name | String | No | Team name |
| members[] | Number | No | User IDs to set as team members (multiple allowed) |

### Response
- **Status**: 200 OK

```json
{
    "id": 1,
    "name": "test",
    "members": [
        {
            "id": 2,
            "userId": "developer",
            "name": "developer",
            "roleType": 2,
            "lang": "ja",
            "nulabAccount": {
                "nulabId": "abcdefghijklmnopqrstuvwxyz",
                "name": "developer",
                "uniqueId": "developer"
            },
            "mailAddress": "developer@nulab.example",
            "lastLoginTime": "2022-09-01T06:35:39Z"
        }
    ],
    "displayOrder": null,
    "createdUser": {
        "id": 1,
        "userId": "admin",
        "name": "admin",
        "roleType": 1,
        "lang": "ja",
        "mailAddress": "eguchi@nulab.example"
    },
    "created": "2013-05-30T09:11:36Z",
    "updatedUser": {
        "id": 1,
        "userId": "admin",
        "name": "admin",
        "roleType": 1,
        "lang": "ja",
        "mailAddress": "eguchi@nulab.example"
    },
    "updated": "2013-05-30T09:11:36Z"
}
```

---

## Delete Team

- **Method**: DELETE
- **Path**: `/api/v2/teams/:teamId`
- **Scope**: Administrator

> Note: This API is unavailable on new plan spaces.

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| teamId | Number | Yes | Team ID (URL parameter) |

### Response
- **Status**: 200 OK

Returns the deleted team object (same structure as Get Team response).

---

## Get Team Icon

- **Method**: GET
- **Path**: `/api/v2/teams/:teamId/icon`
- **Scope**: All

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| teamId | Number | Yes | Team ID (URL parameter) |

### Response
- **Status**: 200 OK
- **Content-Type**: `application/octet-stream`
- **Content-Disposition**: `attachment;filename="team_{teamId}.gif"`

Returns binary image file of the team icon.

---

## Get Project Team List

- **Method**: GET
- **Path**: `/api/v2/projects/:projectIdOrKey/teams`
- **Scope**: All

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectIdOrKey | String | Yes | Project ID or Project Key (URL parameter) |

### Response
- **Status**: 200 OK

```json
[
    {
        "id": 1,
        "name": "test",
        "members": [
            {
                "id": 2,
                "userId": "developer",
                "name": "developer",
                "roleType": 2,
                "lang": "ja",
                "nulabAccount": {
                    "nulabId": "abcdefghijklmnopqrstuvwxyz",
                    "name": "developer",
                    "uniqueId": "developer"
                },
                "mailAddress": "developer@nulab.example",
                "lastLoginTime": "2022-09-01T06:35:39Z"
            }
        ],
        "displayOrder": null,
        "createdUser": {
            "id": 1,
            "userId": "admin",
            "name": "admin",
            "roleType": 1,
            "lang": "ja",
            "mailAddress": "eguchi@nulab.example"
        },
        "created": "2013-05-30T09:11:36Z",
        "updatedUser": {
            "id": 1,
            "userId": "admin",
            "name": "admin",
            "roleType": 1,
            "lang": "ja",
            "mailAddress": "eguchi@nulab.example"
        },
        "updated": "2013-05-30T09:11:36Z"
    }
]
```

---

## Add Project Team

- **Method**: POST
- **Path**: `/api/v2/projects/:projectIdOrKey/teams`
- **Scope**: Administrator, Project Administrator
- **Content-Type**: `application/x-www-form-urlencoded`

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectIdOrKey | String | Yes | Project ID or Project Key (URL parameter) |
| teamId | Number | Yes | Team ID to add to the project |

### Response
- **Status**: 200 OK

```json
{
    "id": 1,
    "name": "test",
    "members": [
        {
            "id": 2,
            "userId": "developer",
            "name": "developer",
            "roleType": 2,
            "lang": "ja",
            "nulabAccount": {
                "nulabId": "abcdefghijklmnopqrstuvwxyz",
                "name": "developer",
                "uniqueId": "developer"
            },
            "mailAddress": "developer@nulab.example",
            "lastLoginTime": "2022-09-01T06:35:39Z"
        }
    ],
    "displayOrder": null,
    "createdUser": {
        "id": 1,
        "userId": "admin",
        "name": "admin",
        "roleType": 1,
        "lang": "ja",
        "mailAddress": "eguchi@nulab.example"
    },
    "created": "2013-05-30T09:11:36Z",
    "updatedUser": {
        "id": 1,
        "userId": "admin",
        "name": "admin",
        "roleType": 1,
        "lang": "ja",
        "mailAddress": "eguchi@nulab.example"
    },
    "updated": "2013-05-30T09:11:36Z"
}
```

---

## Delete Project Team

- **Method**: DELETE
- **Path**: `/api/v2/projects/:projectIdOrKey/teams`
- **Scope**: Administrator, Project Administrator
- **Content-Type**: `application/x-www-form-urlencoded`

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectIdOrKey | String | Yes | Project ID or Project Key (URL parameter) |
| teamId | Number | Yes | Team ID to remove from the project |

### Response
- **Status**: 200 OK

Returns the removed team object (same structure as Get Team response).
