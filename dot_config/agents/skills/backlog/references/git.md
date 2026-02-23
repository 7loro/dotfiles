# Git & Pull Request API

## Table of Contents

- [Git Repositories](#git-repositories)
  - [Get List of Git Repositories](#get-list-of-git-repositories)
  - [Get Git Repository](#get-git-repository)
- [Pull Requests](#pull-requests)
  - [Get Pull Request List](#get-pull-request-list)
  - [Get Number of Pull Requests](#get-number-of-pull-requests)
  - [Add Pull Request](#add-pull-request)
  - [Get Pull Request](#get-pull-request)
  - [Update Pull Request](#update-pull-request)
- [Pull Request Comments](#pull-request-comments)
  - [Get Pull Request Comments](#get-pull-request-comments)
  - [Add Pull Request Comment](#add-pull-request-comment)
  - [Get Number of Pull Request Comments](#get-number-of-pull-request-comments)
  - [Update Pull Request Comment](#update-pull-request-comment)
- [Pull Request Attachments](#pull-request-attachments)
  - [Get List of Pull Request Attachments](#get-list-of-pull-request-attachments)
  - [Download Pull Request Attachment](#download-pull-request-attachment)
  - [Delete Pull Request Attachment](#delete-pull-request-attachment)

---

## Git Repositories

### Get List of Git Repositories

- **Method**: GET
- **Path**: `/api/v2/projects/:projectIdOrKey/git/repositories`
- **Scope**: Administrator, Normal User

#### URL Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectIdOrKey | String | Yes | Project ID or Project Key |

#### Query Parameters

None.

#### Response
- **Status**: 200 OK
- **Content-Type**: application/json;charset=utf-8

```json
[
    {
        "id": 1,
        "projectId": 1,
        "name": "app",
        "description": "",
        "hookUrl": null,
        "httpUrl": "https://xx.backlog.com/git/BLG/app.git",
        "sshUrl": "xx@xx.git.backlog.com:/BLG/app.git",
        "displayOrder": 0,
        "pushedAt": null,
        "createdUser": {
            "id": 1,
            "userId": "admin",
            "name": "admin",
            "roleType": 1,
            "lang": "ja",
            "nulabAccount": {
                "nulabId": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
                "name": "admin",
                "uniqueId": "admin"
            },
            "mailAddress": "eguchi@nulab.example",
            "lastLoginTime": "2022-09-01T06:35:39Z"
        },
        "created": "2013-05-28T09:24:43Z",
        "updatedUser": {
            "id": 1,
            "userId": "admin",
            "name": "admin",
            "roleType": 1,
            "lang": "ja",
            "nulabAccount": {
                "nulabId": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
                "name": "admin",
                "uniqueId": "admin"
            },
            "mailAddress": "eguchi@nulab.example",
            "lastLoginTime": "2022-09-01T06:35:39Z"
        },
        "updated": "2013-05-28T09:24:43Z"
    }
]
```

#### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| id | Number | Repository identifier |
| projectId | Number | Associated project ID |
| name | String | Repository name |
| description | String | Repository description |
| hookUrl | String/null | Webhook URL |
| httpUrl | String | HTTPS clone URL |
| sshUrl | String | SSH clone URL |
| displayOrder | Number | Display order value |
| pushedAt | String/null | Last push timestamp (ISO 8601) |
| createdUser | Object | User who created the repository |
| created | String | Creation timestamp (ISO 8601) |
| updatedUser | Object | User who last updated the repository |
| updated | String | Last update timestamp (ISO 8601) |

---

### Get Git Repository

- **Method**: GET
- **Path**: `/api/v2/projects/:projectIdOrKey/git/repositories/:repoIdOrName`
- **Scope**: Administrator, Normal User

#### URL Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectIdOrKey | String | Yes | Project ID or Project Key |
| repoIdOrName | String | Yes | Repository ID or Repository name |

#### Query Parameters

None.

#### Response
- **Status**: 200 OK
- **Content-Type**: application/json;charset=utf-8

```json
{
    "id": 1,
    "projectId": 1,
    "name": "app",
    "description": "",
    "hookUrl": null,
    "httpUrl": "https://xx.backlog.com/git/BLG/app.git",
    "sshUrl": "xx@xx.git.backlog.com:/BLG/app.git",
    "displayOrder": 0,
    "pushedAt": null,
    "createdUser": {
        "id": 1,
        "userId": "admin",
        "name": "admin",
        "roleType": 1,
        "lang": "ja",
        "nulabAccount": {
            "nulabId": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
            "name": "admin",
            "uniqueId": "admin"
        },
        "mailAddress": "eguchi@nulab.example",
        "lastLoginTime": "2022-09-01T06:35:39Z"
    },
    "created": "2013-05-28T09:24:43Z",
    "updatedUser": {
        "id": 1,
        "userId": "admin",
        "name": "admin",
        "roleType": 1,
        "lang": "ja",
        "nulabAccount": {
            "nulabId": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
            "name": "admin",
            "uniqueId": "admin"
        },
        "mailAddress": "eguchi@nulab.example",
        "lastLoginTime": "2022-09-01T06:35:39Z"
    },
    "updated": "2013-05-28T09:24:43Z"
}
```

#### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| id | Number | Repository identifier |
| projectId | Number | Associated project ID |
| name | String | Repository name |
| description | String | Repository description |
| hookUrl | String/null | Webhook URL |
| httpUrl | String | HTTPS clone URL |
| sshUrl | String | SSH clone URL |
| displayOrder | Number | Display order value |
| pushedAt | String/null | Last push timestamp (ISO 8601) |
| createdUser | Object | User who created the repository |
| created | String | Creation timestamp (ISO 8601) |
| updatedUser | Object | User who last updated the repository |
| updated | String | Last update timestamp (ISO 8601) |

---

## Pull Requests

### Get Pull Request List

- **Method**: GET
- **Path**: `/api/v2/projects/:projectIdOrKey/git/repositories/:repoIdOrName/pullRequests`
- **Scope**: Administrator, Normal User

#### URL Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectIdOrKey | String | Yes | Project ID or Project Key |
| repoIdOrName | String | Yes | Repository ID or Repository name |

#### Query Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| statusId[] | Number | No | Status ID (multiple allowed) |
| assigneeId[] | Number | No | Assignee ID (multiple allowed) |
| issueId[] | Number | No | Related Issue ID (multiple allowed) |
| createdUserId[] | Number | No | Created User ID (multiple allowed) |
| offset | Number | No | Pagination offset |
| count | Number | No | Number of records to retrieve (1-100), default=20 |

#### Response
- **Status**: 200 OK
- **Content-Type**: application/json;charset=utf-8

```json
[
    {
        "id": 1,
        "projectId": 1,
        "repositoryId": 1,
        "number": 1,
        "summary": "test",
        "description": "test data",
        "base": "master",
        "branch": "feature/test",
        "status": {
            "id": 1,
            "name": "Open"
        },
        "assignee": {
            "id": 1,
            "userId": "admin",
            "name": "admin",
            "roleType": 1,
            "lang": "ja",
            "nulabAccount": {
                "nulabId": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
                "name": "admin",
                "uniqueId": "admin"
            },
            "mailAddress": "eguchi@nulab.example",
            "lastLoginTime": "2022-09-01T06:35:39Z"
        },
        "issue": {
            "id": 1
        },
        "baseCommit": null,
        "branchCommit": null,
        "mergeCommit": null,
        "closeAt": null,
        "mergeAt": null,
        "createdUser": {
            "id": 1,
            "userId": "admin",
            "name": "admin",
            "roleType": 1,
            "lang": "ja",
            "nulabAccount": {
                "nulabId": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
                "name": "admin",
                "uniqueId": "admin"
            },
            "mailAddress": "eguchi@nulab.example",
            "lastLoginTime": "2022-09-01T06:35:39Z"
        },
        "created": "2015-04-23T03:04:14Z",
        "updatedUser": {
            "id": 1,
            "userId": "admin",
            "name": "admin",
            "roleType": 1,
            "lang": "ja",
            "nulabAccount": {
                "nulabId": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
                "name": "admin",
                "uniqueId": "admin"
            },
            "mailAddress": "eguchi@nulab.example",
            "lastLoginTime": "2022-09-01T06:35:39Z"
        },
        "updated": "2015-04-23T03:04:14Z"
    }
]
```

#### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| id | Number | Pull request identifier |
| projectId | Number | Associated project ID |
| repositoryId | Number | Associated repository ID |
| number | Number | Pull request number |
| summary | String | Pull request title/summary |
| description | String | Pull request description |
| base | String | Target/base branch name |
| branch | String | Source/merging branch name |
| status | Object | Status object with `id` and `name` |
| assignee | Object | Assignee user object |
| issue | Object | Linked issue (contains `id`) |
| baseCommit | String/null | Base commit hash |
| branchCommit | String/null | Branch commit hash |
| mergeCommit | String/null | Merge commit hash |
| closeAt | String/null | Close timestamp (ISO 8601) |
| mergeAt | String/null | Merge timestamp (ISO 8601) |
| createdUser | Object | User who created the PR |
| created | String | Creation timestamp (ISO 8601) |
| updatedUser | Object | User who last updated the PR |
| updated | String | Last update timestamp (ISO 8601) |

---

### Get Number of Pull Requests

- **Method**: GET
- **Path**: `/api/v2/projects/:projectIdOrKey/git/repositories/:repoIdOrName/pullRequests/count`
- **Scope**: Administrator, Normal User

#### URL Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectIdOrKey | String | Yes | Project ID or Project Key |
| repoIdOrName | String | Yes | Repository ID or Repository name |

#### Query Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| statusId[] | Number | No | Status ID (multiple allowed) |
| assigneeId[] | Number | No | Assignee ID (multiple allowed) |
| issueId[] | Number | No | Related Issue ID (multiple allowed) |
| createdUserId[] | Number | No | Created User ID (multiple allowed) |
| offset | Number | No | Pagination offset |
| count | Number | No | Number of records to retrieve (1-100), default=20 |

#### Response
- **Status**: 200 OK
- **Content-Type**: application/json;charset=utf-8

```json
{
    "count": 10
}
```

#### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| count | Number | Total number of pull requests matching the query |

---

### Add Pull Request

- **Method**: POST
- **Path**: `/api/v2/projects/:projectIdOrKey/git/repositories/:repoIdOrName/pullRequests`
- **Scope**: Administrator, Normal User
- **Content-Type**: application/x-www-form-urlencoded

#### URL Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectIdOrKey | String | Yes | Project ID or Project Key |
| repoIdOrName | String | Yes | Repository ID or Repository name |

#### Form Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| summary | String | Yes | Summary of pull request |
| description | String | Yes | Description of pull request |
| base | String | Yes | Branch name of merge base (target branch) |
| branch | String | Yes | Name of merging branch (source branch) |
| issueId | Number | No | Related issue's ID |
| assigneeId | Number | No | Assignee's ID of pull request |
| notifiedUserId[] | Number | No | User ID to send notification when pull request is added (multiple allowed) |
| attachmentId[] | Number | No | ID returned by Post Attachment File API (multiple allowed) |

#### Response
- **Status**: 200 OK
- **Content-Type**: application/json;charset=utf-8

```json
{
    "id": 1,
    "projectId": 1,
    "repositoryId": 1,
    "number": 1,
    "summary": "test",
    "description": "test data",
    "base": "master",
    "branch": "feature/test",
    "status": {
        "id": 1,
        "name": "Open"
    },
    "assignee": {
        "id": 1,
        "userId": "admin",
        "name": "admin",
        "roleType": 1,
        "lang": "ja",
        "nulabAccount": {
            "nulabId": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
            "name": "admin",
            "uniqueId": "admin"
        },
        "mailAddress": "eguchi@nulab.example",
        "lastLoginTime": "2022-09-01T06:35:39Z"
    },
    "issue": {
        "id": 1
    },
    "baseCommit": null,
    "branchCommit": null,
    "closeAt": null,
    "mergeAt": null,
    "createdUser": {
        "id": 1,
        "userId": "admin",
        "name": "admin",
        "roleType": 1,
        "lang": "ja",
        "nulabAccount": {
            "nulabId": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
            "name": "admin",
            "uniqueId": "admin"
        },
        "mailAddress": "eguchi@nulab.example",
        "lastLoginTime": "2022-09-01T06:35:39Z"
    },
    "created": "2015-04-23T03:04:14Z",
    "updatedUser": {
        "id": 1,
        "userId": "admin",
        "name": "admin",
        "roleType": 1,
        "lang": "ja",
        "nulabAccount": {
            "nulabId": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
            "name": "admin",
            "uniqueId": "admin"
        },
        "mailAddress": "eguchi@nulab.example",
        "lastLoginTime": "2022-09-01T06:35:39Z"
    },
    "updated": "2015-04-23T03:04:14Z"
}
```

#### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| id | Number | Pull request identifier |
| projectId | Number | Associated project ID |
| repositoryId | Number | Associated repository ID |
| number | Number | Pull request number |
| summary | String | Pull request title/summary |
| description | String | Pull request description |
| base | String | Target/base branch name |
| branch | String | Source/merging branch name |
| status | Object | Status object with `id` and `name` |
| assignee | Object | Assignee user object |
| issue | Object | Linked issue (contains `id`) |
| baseCommit | String/null | Base commit hash |
| branchCommit | String/null | Branch commit hash |
| closeAt | String/null | Close timestamp (ISO 8601) |
| mergeAt | String/null | Merge timestamp (ISO 8601) |
| createdUser | Object | User who created the PR |
| created | String | Creation timestamp (ISO 8601) |
| updatedUser | Object | User who last updated the PR |
| updated | String | Last update timestamp (ISO 8601) |

---

### Get Pull Request

- **Method**: GET
- **Path**: `/api/v2/projects/:projectIdOrKey/git/repositories/:repoIdOrName/pullRequests/:number`
- **Scope**: Administrator, Normal User

#### URL Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectIdOrKey | String | Yes | Project ID or Project Key |
| repoIdOrName | String | Yes | Repository ID or Repository name |
| number | Number | Yes | Pull request number |

#### Query Parameters

None.

#### Response
- **Status**: 200 OK
- **Content-Type**: application/json;charset=utf-8

```json
{
    "id": 1,
    "projectId": 1,
    "repositoryId": 1,
    "number": 1,
    "summary": "test",
    "description": "test data",
    "base": "master",
    "branch": "feature/test",
    "status": {
        "id": 1,
        "name": "Open"
    },
    "assignee": {
        "id": 1,
        "userId": "admin",
        "name": "admin",
        "roleType": 1,
        "lang": "ja",
        "nulabAccount": {
            "nulabId": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
            "name": "admin",
            "uniqueId": "admin"
        },
        "mailAddress": "eguchi@nulab.example",
        "lastLoginTime": "2022-09-01T06:35:39Z"
    },
    "issue": {
        "id": 1
    },
    "baseCommit": null,
    "branchCommit": null,
    "mergeCommit": null,
    "closeAt": null,
    "mergeAt": null,
    "createdUser": {
        "id": 1,
        "userId": "admin",
        "name": "admin",
        "roleType": 1,
        "lang": "ja",
        "nulabAccount": {
            "nulabId": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
            "name": "admin",
            "uniqueId": "admin"
        },
        "mailAddress": "eguchi@nulab.example",
        "lastLoginTime": "2022-09-01T06:35:39Z"
    },
    "created": "2015-04-23T03:04:14Z",
    "updatedUser": {
        "id": 1,
        "userId": "admin",
        "name": "admin",
        "roleType": 1,
        "lang": "ja",
        "nulabAccount": {
            "nulabId": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
            "name": "admin",
            "uniqueId": "admin"
        },
        "mailAddress": "eguchi@nulab.example",
        "lastLoginTime": "2022-09-01T06:35:39Z"
    },
    "created": "2015-04-23T03:04:14Z",
    "updated": "2015-04-23T03:04:14Z",
    "attachments": [],
    "stars": []
}
```

#### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| id | Number | Pull request identifier |
| projectId | Number | Associated project ID |
| repositoryId | Number | Associated repository ID |
| number | Number | Pull request number |
| summary | String | Pull request title/summary |
| description | String | Pull request description |
| base | String | Target/base branch name |
| branch | String | Source/merging branch name |
| status | Object | Status object with `id` and `name` |
| assignee | Object | Assignee user object |
| issue | Object | Linked issue (contains `id`) |
| baseCommit | String/null | Base commit hash |
| branchCommit | String/null | Branch commit hash |
| mergeCommit | String/null | Merge commit hash |
| closeAt | String/null | Close timestamp (ISO 8601) |
| mergeAt | String/null | Merge timestamp (ISO 8601) |
| createdUser | Object | User who created the PR |
| created | String | Creation timestamp (ISO 8601) |
| updatedUser | Object | User who last updated the PR |
| updated | String | Last update timestamp (ISO 8601) |
| attachments | Array | List of file attachments |
| stars | Array | List of star/favorite records |

---

### Update Pull Request

- **Method**: PATCH
- **Path**: `/api/v2/projects/:projectIdOrKey/git/repositories/:repoIdOrName/pullRequests/:number`
- **Scope**: Administrator, Normal User
- **Content-Type**: application/x-www-form-urlencoded

#### URL Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectIdOrKey | String | Yes | Project ID or Project Key |
| repoIdOrName | String | Yes | Repository ID or Repository name |
| number | Number | Yes | Pull request number |

#### Form Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| summary | String | No | Summary of pull request |
| description | String | No | Description of pull request |
| issueId | Number | No | Related issue's ID |
| assigneeId | Number | No | Assignee's ID of pull request |
| notifiedUserId[] | Number | No | User ID to send notification (multiple allowed) |
| comment | String | No | Comment to add with the update |

#### Response
- **Status**: 200 OK
- **Content-Type**: application/json;charset=utf-8

```json
{
    "id": 1,
    "projectId": 1,
    "repositoryId": 1,
    "number": 1,
    "summary": "test",
    "description": "test data",
    "base": "master",
    "branch": "feature/test",
    "status": {
        "id": 1,
        "name": "Open"
    },
    "assignee": {
        "id": 1,
        "userId": "admin",
        "name": "admin",
        "roleType": 1,
        "lang": "ja",
        "nulabAccount": {
            "nulabId": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
            "name": "admin",
            "uniqueId": "admin"
        },
        "mailAddress": "eguchi@nulab.example",
        "lastLoginTime": "2022-09-01T06:35:39Z"
    },
    "issue": {
        "id": 1
    },
    "baseCommit": null,
    "branchCommit": null,
    "mergeCommit": null,
    "closeAt": null,
    "mergeAt": null,
    "createdUser": {
        "id": 1,
        "userId": "admin",
        "name": "admin",
        "roleType": 1,
        "lang": "ja",
        "nulabAccount": {
            "nulabId": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
            "name": "admin",
            "uniqueId": "admin"
        },
        "mailAddress": "eguchi@nulab.example",
        "lastLoginTime": "2022-09-01T06:35:39Z"
    },
    "created": "2015-04-23T03:04:14Z",
    "updatedUser": {
        "id": 1,
        "userId": "admin",
        "name": "admin",
        "roleType": 1,
        "lang": "ja",
        "nulabAccount": {
            "nulabId": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
            "name": "admin",
            "uniqueId": "admin"
        },
        "mailAddress": "eguchi@nulab.example",
        "lastLoginTime": "2022-09-01T06:35:39Z"
    },
    "updated": "2015-04-23T03:04:14Z",
    "attachments": [],
    "stars": []
}
```

#### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| id | Number | Pull request identifier |
| projectId | Number | Associated project ID |
| repositoryId | Number | Associated repository ID |
| number | Number | Pull request number |
| summary | String | Pull request title/summary |
| description | String | Pull request description |
| base | String | Target/base branch name |
| branch | String | Source/merging branch name |
| status | Object | Status object with `id` and `name` |
| assignee | Object | Assignee user object |
| issue | Object | Linked issue (contains `id`) |
| baseCommit | String/null | Base commit hash |
| branchCommit | String/null | Branch commit hash |
| mergeCommit | String/null | Merge commit hash |
| closeAt | String/null | Close timestamp (ISO 8601) |
| mergeAt | String/null | Merge timestamp (ISO 8601) |
| createdUser | Object | User who created the PR |
| created | String | Creation timestamp (ISO 8601) |
| updatedUser | Object | User who last updated the PR |
| updated | String | Last update timestamp (ISO 8601) |
| attachments | Array | List of file attachments |
| stars | Array | List of star/favorite records |

---

## Pull Request Comments

### Get Pull Request Comments

- **Method**: GET
- **Path**: `/api/v2/projects/:projectIdOrKey/git/repositories/:repoIdOrName/pullRequests/:number/comments`
- **Scope**: Administrator, Normal User

#### URL Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectIdOrKey | String | Yes | Project ID or Project Key |
| repoIdOrName | String | Yes | Repository ID or Repository name |
| number | Number | Yes | Pull request number |

#### Query Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| minId | Number | No | Minimum comment ID |
| maxId | Number | No | Maximum comment ID |
| count | Number | No | Number of records to retrieve (1-100), default=20 |
| order | String | No | Sort order: "asc" or "desc", default="desc" |

#### Response
- **Status**: 200 OK
- **Content-Type**: application/json;charset=utf-8

```json
[
    {
        "id": 35,
        "content": "from api",
        "changeLog": [
            {
                "field": "dependentIssue",
                "newValue": "GIT-3",
                "originalValue": null
            }
        ],
        "createdUser": {
            "id": 1,
            "userId": "admin",
            "name": "admin",
            "roleType": 1,
            "lang": "ja",
            "nulabAccount": {
                "nulabId": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
                "name": "admin",
                "uniqueId": "admin"
            },
            "mailAddress": "eguchi@nulab.example",
            "lastLoginTime": "2022-09-01T06:35:39Z"
        },
        "created": "2015-05-14T01:53:38Z",
        "updated": "2015-05-14T01:53:38Z",
        "stars": [],
        "notifications": []
    }
]
```

#### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| id | Number | Comment identifier |
| content | String | Comment text |
| changeLog | Array | List of field change records |
| changeLog[].field | String | Changed field name |
| changeLog[].newValue | String/null | New value |
| changeLog[].originalValue | String/null | Original value |
| createdUser | Object | User who created the comment |
| created | String | Creation timestamp (ISO 8601) |
| updated | String | Last update timestamp (ISO 8601) |
| stars | Array | List of star records |
| notifications | Array | List of notification records |

---

### Add Pull Request Comment

- **Method**: POST
- **Path**: `/api/v2/projects/:projectIdOrKey/git/repositories/:repoIdOrName/pullRequests/:number/comments`
- **Scope**: Administrator, Normal User
- **Content-Type**: application/x-www-form-urlencoded

#### URL Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectIdOrKey | String | Yes | Project ID or Project Key |
| repoIdOrName | String | Yes | Repository ID or Repository name |
| number | Number | Yes | Pull request number |

#### Form Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| content | String | Yes | Comment text |
| attachmentId[] | Number | No | Attachment file ID from Post Attachment File API (multiple allowed) |
| notifiedUserId[] | Number | No | User ID to send notification when comment is added (multiple allowed) |

#### Response
- **Status**: 200 OK
- **Content-Type**: application/json;charset=utf-8

```json
{
    "id": 35,
    "content": "from api",
    "changeLog": [
        {
            "field": "dependentIssue",
            "newValue": "GIT-3",
            "originalValue": null
        }
    ],
    "createdUser": {
        "id": 1,
        "userId": "admin",
        "name": "admin",
        "roleType": 1,
        "lang": "ja",
        "nulabAccount": {
            "nulabId": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
            "name": "admin",
            "uniqueId": "admin"
        },
        "mailAddress": "eguchi@nulab.example",
        "lastLoginTime": "2022-09-01T06:35:39Z"
    },
    "created": "2015-05-14T01:53:38Z",
    "updated": "2015-05-14T01:53:38Z",
    "stars": [],
    "notifications": []
}
```

#### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| id | Number | Comment identifier |
| content | String | Comment text |
| changeLog | Array | List of field change records |
| changeLog[].field | String | Changed field name |
| changeLog[].newValue | String/null | New value |
| changeLog[].originalValue | String/null | Original value |
| createdUser | Object | User who created the comment |
| created | String | Creation timestamp (ISO 8601) |
| updated | String | Last update timestamp (ISO 8601) |
| stars | Array | List of star records |
| notifications | Array | List of notification records |

---

### Get Number of Pull Request Comments

- **Method**: GET
- **Path**: `/api/v2/projects/:projectIdOrKey/git/repositories/:repoIdOrName/pullRequests/:number/comments/count`
- **Scope**: Administrator, Normal User

#### URL Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectIdOrKey | String | Yes | Project ID or Project Key |
| repoIdOrName | String | Yes | Repository ID or Repository name |
| number | Number | Yes | Pull request number |

#### Query Parameters

None.

#### Response
- **Status**: 200 OK
- **Content-Type**: application/json;charset=utf-8

```json
{
    "count": 10
}
```

#### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| count | Number | Total number of comments on the pull request |

---

### Update Pull Request Comment

- **Method**: PATCH
- **Path**: `/api/v2/projects/:projectIdOrKey/git/repositories/:repoIdOrName/pullRequests/:number/comments/:commentId`
- **Scope**: Administrator, Normal User (authenticated user can only update their own comments)
- **Content-Type**: application/x-www-form-urlencoded

#### URL Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectIdOrKey | String | Yes | Project ID or Project Key |
| repoIdOrName | String | Yes | Repository ID or Repository name |
| number | Number | Yes | Pull request number |
| commentId | Number | Yes | Comment's ID |

#### Form Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| content | String | Yes | Comment's body |

#### Response
- **Status**: 200 OK
- **Content-Type**: application/json;charset=utf-8

```json
{
    "id": 35,
    "content": "updated comment",
    "changeLog": [],
    "createdUser": {
        "id": 1,
        "userId": "admin",
        "name": "admin",
        "roleType": 1,
        "lang": "ja",
        "nulabAccount": {
            "nulabId": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
            "name": "admin",
            "uniqueId": "admin"
        },
        "mailAddress": "eguchi@nulab.example",
        "lastLoginTime": "2022-09-01T06:35:39Z"
    },
    "created": "2015-05-14T01:53:38Z",
    "updated": "2015-05-14T02:00:00Z",
    "stars": [],
    "notifications": []
}
```

#### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| id | Number | Comment identifier |
| content | String | Updated comment text |
| changeLog | Array | List of field change records |
| createdUser | Object | User who created the comment |
| created | String | Creation timestamp (ISO 8601) |
| updated | String | Last update timestamp (ISO 8601) |
| stars | Array | List of star records |
| notifications | Array | List of notification records |

---

## Pull Request Attachments

### Get List of Pull Request Attachments

- **Method**: GET
- **Path**: `/api/v2/projects/:projectIdOrKey/git/repositories/:repoIdOrName/pullRequests/:number/attachments`
- **Scope**: Administrator, Normal User

#### URL Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectIdOrKey | String | Yes | Project ID or Project Key |
| repoIdOrName | String | Yes | Repository ID or Repository name |
| number | Number | Yes | Pull request number |

#### Query Parameters

None.

#### Response
- **Status**: 200 OK
- **Content-Type**: application/json;charset=utf-8

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
                "nulabId": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
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

#### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| id | Number | Attachment identifier |
| name | String | Filename |
| size | Number | File size in bytes |
| createdUser | Object | User who uploaded the file |
| created | String | Creation timestamp (ISO 8601) |

---

### Download Pull Request Attachment

- **Method**: GET
- **Path**: `/api/v2/projects/:projectIdOrKey/git/repositories/:repoIdOrName/pullRequests/:number/attachments/:attachmentId`
- **Scope**: Administrator, Normal User

#### URL Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectIdOrKey | String | Yes | Project ID or Project Key |
| repoIdOrName | String | Yes | Repository ID or Repository name |
| number | Number | Yes | Pull request number |
| attachmentId | Number | Yes | Attached file's ID |

#### Query Parameters

None.

#### Response
- **Status**: 200 OK
- **Content-Type**: application/octet-stream
- **Content-Disposition**: attachment;filename="<filename>"

Response body is binary file content (the attached file being downloaded).

---

### Delete Pull Request Attachment

- **Method**: DELETE
- **Path**: `/api/v2/projects/:projectIdOrKey/git/repositories/:repoIdOrName/pullRequests/:number/attachments/:attachmentId`
- **Scope**: Administrator, Normal User

#### URL Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectIdOrKey | String | Yes | Project ID or Project Key |
| repoIdOrName | String | Yes | Repository ID or Repository name |
| number | Number | Yes | Pull request number |
| attachmentId | Number | Yes | Attached file's ID |

#### Query Parameters

None.

#### Response
- **Status**: 200 OK
- **Content-Type**: application/json;charset=utf-8

Returns the deleted attachment's metadata as confirmation.

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
            "nulabId": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
            "name": "admin",
            "uniqueId": "admin"
        },
        "mailAddress": "eguchi@nulab.example",
        "lastLoginTime": "2022-09-01T06:35:39Z"
    },
    "created": "2014-10-28T09:24:43Z"
}
```

#### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| id | Number | Attachment identifier |
| name | String | Filename |
| size | Number | File size in bytes |
| createdUser | Object | User who uploaded the file |
| created | String | Creation timestamp (ISO 8601) |

---

## Common Object Schemas

### User Object

```json
{
    "id": 1,
    "userId": "admin",
    "name": "admin",
    "roleType": 1,
    "lang": "ja",
    "nulabAccount": {
        "nulabId": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
        "name": "admin",
        "uniqueId": "admin"
    },
    "mailAddress": "eguchi@nulab.example",
    "lastLoginTime": "2022-09-01T06:35:39Z"
}
```

| Field | Type | Description |
|-------|------|-------------|
| id | Number | User identifier |
| userId | String | User's login ID |
| name | String | Display name |
| roleType | Number | Role type (1=Admin, 2=Normal User, 3=Reporter, 4=Viewer, 5=Guest Reporter, 6=Guest Viewer) |
| lang | String | Language setting |
| nulabAccount | Object | Nulab account info |
| nulabAccount.nulabId | String | Nulab account ID |
| nulabAccount.name | String | Nulab account name |
| nulabAccount.uniqueId | String | Nulab unique ID |
| mailAddress | String | Email address |
| lastLoginTime | String | Last login timestamp (ISO 8601) |

### Pull Request Status Values

| ID | Name |
|----|------|
| 1 | Open |
| 2 | Closed |
| 3 | Merged |
