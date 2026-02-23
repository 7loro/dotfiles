# Project API

## Table of Contents

### Project Core
- [Get Project List](#get-project-list)
- [Add Project](#add-project)
- [Get Project](#get-project)
- [Update Project](#update-project)
- [Delete Project](#delete-project)
- [Get Project Icon](#get-project-icon)
- [Get Project Recent Updates](#get-project-recent-updates)
- [Get Status List of Project](#get-status-list-of-project)
- [Get Priority List](#get-priority-list)
- [Get Resolution List](#get-resolution-list)

### Project Members
- [Add Project User](#add-project-user)
- [Get Project User List](#get-project-user-list)
- [Delete Project User](#delete-project-user)
- [Add Project Administrator](#add-project-administrator)
- [Get List of Project Administrators](#get-list-of-project-administrators)
- [Delete Project Administrator](#delete-project-administrator)

### Project Settings - Statuses
- [Add Status](#add-status)
- [Update Status](#update-status)
- [Delete Status](#delete-status)
- [Update Order of Status](#update-order-of-status)

### Project Settings - Issue Types
- [Get Issue Type List](#get-issue-type-list)
- [Add Issue Type](#add-issue-type)
- [Update Issue Type](#update-issue-type)
- [Delete Issue Type](#delete-issue-type)

### Project Settings - Categories
- [Get Category List](#get-category-list)
- [Add Category](#add-category)
- [Update Category](#update-category)
- [Delete Category](#delete-category)

### Project Settings - Versions/Milestones
- [Get Version/Milestone List](#get-versionmilestone-list)
- [Add Version/Milestone](#add-versionmilestone)
- [Update Version/Milestone](#update-versionmilestone)
- [Delete Version](#delete-version)

### Project Settings - Custom Fields
- [Get Custom Field List](#get-custom-field-list)
- [Add Custom Field](#add-custom-field)
- [Update Custom Field](#update-custom-field)
- [Delete Custom Field](#delete-custom-field)
- [Add List Item for List Type Custom Field](#add-list-item-for-list-type-custom-field)
- [Update List Item for List Type Custom Field](#update-list-item-for-list-type-custom-field)
- [Delete List Item for List Type Custom Field](#delete-list-item-for-list-type-custom-field)

---

## Get Project List

Returns list of projects.

- **Method**: GET
- **Path**: `/api/v2/projects`
- **Scope**: All

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| archived | Boolean | No | Filter by archive status. Unspecified: all projects. `false`: unarchived only. `true`: archived only. |
| all | Boolean | No | (Admin only) `true`: returns all projects. `false` (default): only joined projects. |

### Response
- **Status**: 200 OK

```json
[
    {
        "id": 1,
        "projectKey": "TEST",
        "name": "test",
        "chartEnabled": false,
        "useResolvedForChart": false,
        "subtaskingEnabled": false,
        "projectLeaderCanEditProjectLeader": false,
        "useWiki": true,
        "useFileSharing": true,
        "useWikiTreeView": true,
        "useOriginalImageSizeAtWiki": false,
        "useSubversion": true,
        "useGit": true,
        "textFormattingRule": "markdown",
        "archived": false,
        "displayOrder": 2147483646,
        "useDevAttributes": true
    }
]
```

---

## Add Project

Creates a new project.

- **Method**: POST
- **Path**: `/api/v2/projects`
- **Scope**: Administrator
- **Content-Type**: `application/x-www-form-urlencoded`

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| name | String | Yes | Project Name |
| key | String | Yes | Project Key. Uppercase letters (A-Z), numbers (0-9) and underscore (_) can be used. |
| chartEnabled | Boolean | No | Enable chart |
| useResolvedForChart | Boolean | No | Consider Resolved and statuses after as Closed |
| subtaskingEnabled | Boolean | No | Enable subtasking |
| projectLeaderCanEditProjectLeader | Boolean | No | Allow project administrators to manage each other |
| useWiki | Boolean | No | Enable Wiki |
| useFileSharing | Boolean | No | Enable shared files |
| useWikiTreeView | Boolean | No | Enable Wiki tree view |
| useSubversion | Boolean | No | Enable Subversion |
| useGit | Boolean | No | Enable Git |
| useOriginalImageSizeAtWiki | Boolean | No | Display images in Wikis in their original size |
| textFormattingRule | String | No | Formatting rules: `"backlog"` or `"markdown"` |
| useDevAttributes | Boolean | No | Enable priorities, versions and milestones |

### Response
- **Status**: 201 Created

```json
{
    "id": 1,
    "projectKey": "TEST",
    "name": "test",
    "chartEnabled": false,
    "useResolvedForChart": false,
    "subtaskingEnabled": false,
    "projectLeaderCanEditProjectLeader": false,
    "useWiki": true,
    "useFileSharing": true,
    "useWikiTreeView": true,
    "useOriginalImageSizeAtWiki": false,
    "useSubversion": true,
    "useGit": true,
    "textFormattingRule": "markdown",
    "archived": false,
    "displayOrder": 2147483646,
    "useDevAttributes": true
}
```

---

## Get Project

Returns information about a specific project.

- **Method**: GET
- **Path**: `/api/v2/projects/:projectIdOrKey`
- **Scope**: All

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectIdOrKey | String | Yes | (URL param) Project ID or Project Key |

### Response
- **Status**: 200 OK

```json
{
    "id": 1,
    "projectKey": "TEST",
    "name": "test",
    "chartEnabled": false,
    "useResolvedForChart": false,
    "subtaskingEnabled": false,
    "projectLeaderCanEditProjectLeader": false,
    "useWiki": true,
    "useFileSharing": true,
    "useWikiTreeView": true,
    "useOriginalImageSizeAtWiki": false,
    "useSubversion": true,
    "useGit": true,
    "textFormattingRule": "markdown",
    "archived": false,
    "displayOrder": 2147483646,
    "useDevAttributes": true
}
```

---

## Update Project

Updates information about a project.

- **Method**: PATCH
- **Path**: `/api/v2/projects/:projectIdOrKey`
- **Scope**: Administrator, Project Administrator
- **Content-Type**: `application/x-www-form-urlencoded`

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectIdOrKey | String | Yes | (URL param) Project ID or Project Key |
| name | String | No | Project Name |
| key | String | No | Project Key |
| chartEnabled | Boolean | No | Enable chart |
| useResolvedForChart | Boolean | No | Consider Resolved and statuses after as Closed |
| subtaskingEnabled | Boolean | No | Enable subtasking |
| projectLeaderCanEditProjectLeader | Boolean | No | Allow project administrators to manage each other |
| useWiki | Boolean | No | Enable Wiki |
| useFileSharing | Boolean | No | Enable shared files |
| useWikiTreeView | Boolean | No | Enable Wiki tree view |
| useSubversion | Boolean | No | Enable Subversion |
| useGit | Boolean | No | Enable Git |
| useOriginalImageSizeAtWiki | Boolean | No | Display images in original size |
| textFormattingRule | String | No | Formatting rules: `"backlog"` or `"markdown"` |
| archived | Boolean | No | Archive this project |
| useDevAttributes | Boolean | No | Enable priorities, versions and milestones |

### Response
- **Status**: 200 OK

```json
{
    "id": 1,
    "projectKey": "TEST",
    "name": "test",
    "chartEnabled": false,
    "useResolvedForChart": false,
    "subtaskingEnabled": false,
    "projectLeaderCanEditProjectLeader": false,
    "useWiki": true,
    "useFileSharing": true,
    "useWikiTreeView": true,
    "useOriginalImageSizeAtWiki": false,
    "useSubversion": true,
    "useGit": true,
    "textFormattingRule": "markdown",
    "archived": false,
    "displayOrder": 2147483646,
    "useDevAttributes": true
}
```

---

## Delete Project

Deletes a project.

- **Method**: DELETE
- **Path**: `/api/v2/projects/:projectIdOrKey`
- **Scope**: Administrator

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectIdOrKey | String | Yes | (URL param) Project ID or Project Key |

### Response
- **Status**: 200 OK

```json
{
    "id": 1,
    "projectKey": "TEST",
    "name": "test",
    "chartEnabled": false,
    "useResolvedForChart": false,
    "subtaskingEnabled": false,
    "projectLeaderCanEditProjectLeader": false,
    "useWiki": true,
    "useFileSharing": true,
    "useWikiTreeView": true,
    "useOriginalImageSizeAtWiki": false,
    "textFormattingRule": "markdown",
    "archived": false,
    "displayOrder": 2147483646,
    "useDevAttributes": true
}
```

---

## Get Project Icon

Downloads the project icon image.

- **Method**: GET
- **Path**: `/api/v2/projects/:projectIdOrKey/image`
- **Scope**: All

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectIdOrKey | String | Yes | (URL param) Project ID or Project Key |

### Response
- **Status**: 200 OK
- **Content-Type**: `application/octet-stream`
- **Content-Disposition**: `attachment;filename="logo_mark.png"`

Binary image data.

---

## Get Project Recent Updates

Returns recent update activities in the project.

- **Method**: GET
- **Path**: `/api/v2/projects/:projectIdOrKey/activities`
- **Scope**: All

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectIdOrKey | String | Yes | (URL param) Project ID or Project Key |
| activityTypeId[] | Number | No | Activity type filter (1-26). Multiple values supported. |
| minId | Number | No | Minimum activity ID |
| maxId | Number | No | Maximum activity ID |
| count | Number | No | Number of records to retrieve (1-100, default: 20) |
| order | String | No | Sort order: `"asc"` or `"desc"` (default: `"desc"`) |

### Response
- **Status**: 200 OK

```json
[
    {
        "id": 1,
        "project": {
            "id": 1,
            "projectKey": "TEST",
            "name": "test"
        },
        "type": 1,
        "content": {
            "id": 1,
            "key_id": 1,
            "summary": "test",
            "description": ""
        },
        "notifications": [],
        "createdUser": {
            "id": 1,
            "userId": "admin",
            "name": "admin",
            "roleType": 1,
            "lang": "ja",
            "mailAddress": "eguchi@nulab.example"
        },
        "created": "2013-12-27T07:50:44Z"
    }
]
```

> **Note**: As of February 9, 2022, the `notifications` field always returns an empty array.

---

## Get Status List of Project

Returns list of statuses in the project.

- **Method**: GET
- **Path**: `/api/v2/projects/:projectIdOrKey/statuses`
- **Scope**: All

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectIdOrKey | String | Yes | (URL param) Project ID or Project Key |

### Response
- **Status**: 200 OK

```json
[
    {
        "id": 1,
        "projectId": 1,
        "name": "Open",
        "color": "#ed8077",
        "displayOrder": 1000
    }
]
```

---

## Get Priority List

Returns list of priorities.

- **Method**: GET
- **Path**: `/api/v2/priorities`
- **Scope**: All

### Parameters

None.

### Response
- **Status**: 200 OK

```json
[
    {
        "id": 2,
        "name": "High"
    },
    {
        "id": 3,
        "name": "Normal"
    },
    {
        "id": 4,
        "name": "Low"
    }
]
```

---

## Get Resolution List

Returns list of resolutions.

- **Method**: GET
- **Path**: `/api/v2/resolutions`
- **Scope**: All

### Parameters

None.

### Response
- **Status**: 200 OK

```json
[
    {
        "id": 0,
        "name": "Fixed"
    },
    {
        "id": 1,
        "name": "Won't Fix"
    },
    {
        "id": 2,
        "name": "Invalid"
    },
    {
        "id": 3,
        "name": "Duplication"
    },
    {
        "id": 4,
        "name": "Cannot Reproduce"
    }
]
```

---

## Add Project User

Adds a user to the list of project members.

- **Method**: POST
- **Path**: `/api/v2/projects/:projectIdOrKey/users`
- **Scope**: Administrator, Project Administrator
- **Content-Type**: `application/x-www-form-urlencoded`

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectIdOrKey | String | Yes | (URL param) Project ID or Project Key |
| userId | Number | Yes | User ID |

### Response
- **Status**: 200 OK

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

## Get Project User List

Returns list of project members.

- **Method**: GET
- **Path**: `/api/v2/projects/:projectIdOrKey/users`
- **Scope**: All

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectIdOrKey | String | Yes | (URL param) Project ID or Project Key |
| excludeGroupMembers | Boolean | No | Set to `true` to exclude members that are part of project groups. Default: `false`. |

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

## Delete Project User

Removes a user from the project members.

- **Method**: DELETE
- **Path**: `/api/v2/projects/:projectIdOrKey/users`
- **Scope**: Administrator, Project Administrator
- **Content-Type**: `application/x-www-form-urlencoded`

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectIdOrKey | String | Yes | (URL param) Project ID or Project Key |
| userId | Number | Yes | User ID |

### Response
- **Status**: 200 OK

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

## Add Project Administrator

Adds the Project Administrator role to a user.

- **Method**: POST
- **Path**: `/api/v2/projects/:projectIdOrKey/administrators`
- **Scope**: Administrator
- **Content-Type**: `application/x-www-form-urlencoded`

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectIdOrKey | String | Yes | (URL param) Project ID or Project Key |
| userId | Number | Yes | User ID |

### Response
- **Status**: 200 OK

```json
{
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
}
```

---

## Get List of Project Administrators

Returns list of users who have the Project Administrator role.

- **Method**: GET
- **Path**: `/api/v2/projects/:projectIdOrKey/administrators`
- **Scope**: All

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectIdOrKey | String | Yes | (URL param) Project ID or Project Key |

### Response
- **Status**: 200 OK

```json
[
    {
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
    }
]
```

---

## Delete Project Administrator

Removes the Project Administrator role from a user.

- **Method**: DELETE
- **Path**: `/api/v2/projects/:projectIdOrKey/administrators`
- **Scope**: Administrator
- **Content-Type**: `application/x-www-form-urlencoded`

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectIdOrKey | String | Yes | (URL param) Project ID or Project Key |
| userId | Number | Yes | User ID |

### Response
- **Status**: 200 OK

```json
{
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
}
```

---

## Add Status

Adds a new custom status to the project. Projects can have up to 8 custom statuses in addition to the 4 default ones.

- **Method**: POST
- **Path**: `/api/v2/projects/:projectIdOrKey/statuses`
- **Scope**: Administrator
- **Content-Type**: `application/x-www-form-urlencoded`

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectIdOrKey | String | Yes | (URL param) Project ID or Project Key |
| name | String | Yes | Status name |
| color | String | Yes | Background color. One of: `"#ea2c00"`, `"#e87758"`, `"#e07b9a"`, `"#868cb7"`, `"#3b9dbd"`, `"#4caf93"`, `"#b0be3c"`, `"#eda62a"`, `"#f42858"`, `"#393939"` |

### Response
- **Status**: 200 OK

```json
{
    "id": 101,
    "projectId": 1,
    "name": "Waiting for review",
    "color": "#e87758",
    "displayOrder": 3999
}
```

---

## Update Status

Updates information about a status.

- **Method**: PATCH
- **Path**: `/api/v2/projects/:projectIdOrKey/statuses/:id`
- **Scope**: Administrator
- **Content-Type**: `application/x-www-form-urlencoded`

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectIdOrKey | String | Yes | (URL param) Project ID or Project Key |
| id | Number | Yes | (URL param) Status ID |
| name | String | Yes | Status name |
| color | String | Yes | Background color. One of: `"#ea2c00"`, `"#e87758"`, `"#e07b9a"`, `"#868cb7"`, `"#3b9dbd"`, `"#4caf93"`, `"#b0be3c"`, `"#eda62a"`, `"#f42858"`, `"#393939"` |

### Response
- **Status**: 200 OK

```json
{
    "id": 101,
    "projectId": 1,
    "name": "Waiting for review",
    "color": "#e87758",
    "displayOrder": 3999
}
```

---

## Delete Status

Deletes a status. Issues with the deleted status are reassigned to the specified substitute status.

- **Method**: DELETE
- **Path**: `/api/v2/projects/:projectIdOrKey/statuses/:id`
- **Scope**: Administrator
- **Content-Type**: `application/x-www-form-urlencoded`

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectIdOrKey | String | Yes | (URL param) Project ID or Project Key |
| id | Number | Yes | (URL param) Status ID |
| substituteStatusId | Number | Yes | Status ID to replace linked issues. Issues with the deleted status will be set to this substitute status. |

### Response
- **Status**: 200 OK

```json
{
    "id": 101,
    "projectId": 1,
    "name": "Waiting for review",
    "color": "#e87758",
    "displayOrder": 3999
}
```

---

## Update Order of Status

Updates the display order of statuses in the project.

- **Method**: PATCH
- **Path**: `/api/v2/projects/:projectIdOrKey/statuses/updateDisplayOrder`
- **Scope**: Administrator
- **Content-Type**: `application/x-www-form-urlencoded`

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectIdOrKey | String | Yes | (URL param) Project ID or Project Key |
| statusId[] | Number[] | Yes | Ordered list of all status IDs. Constraints: "Open" must be first, "Close" must be last, "In Progress" must precede "Resolved". |

### Response
- **Status**: 200 OK

```json
[
    {
        "id": 1,
        "projectId": 1,
        "name": "Open",
        "color": "#ed8077",
        "displayOrder": 1000
    },
    {
        "id": 101,
        "projectId": 1,
        "name": "Ready",
        "color": "#ed8077",
        "displayOrder": 1001
    }
]
```

---

## Get Issue Type List

Returns list of issue types in the project.

- **Method**: GET
- **Path**: `/api/v2/projects/:projectIdOrKey/issueTypes`
- **Scope**: All

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectIdOrKey | String | Yes | (URL param) Project ID or Project Key |

### Response
- **Status**: 200 OK

```json
[
    {
        "id": 1,
        "projectId": 1,
        "name": "Bug",
        "color": "#990000",
        "displayOrder": 0,
        "templateSummary": "Subject",
        "templateDescription": "Description"
    }
]
```

---

## Add Issue Type

Adds a new issue type to the project.

- **Method**: POST
- **Path**: `/api/v2/projects/:projectIdOrKey/issueTypes`
- **Scope**: Administrator, Normal User
- **Content-Type**: `application/x-www-form-urlencoded`

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectIdOrKey | String | Yes | (URL param) Project ID or Project Key |
| name | String | Yes | Issue Type name |
| color | String | Yes | Background color. One of: `"#e30000"`, `"#990000"`, `"#934981"`, `"#814fbc"`, `"#2779ca"`, `"#007e9a"`, `"#7ea800"`, `"#ff9200"`, `"#ff3265"`, `"#666665"` |
| templateSummary | String | No | Template text for the subject field |
| templateDescription | String | No | Template text for the description field |

### Response
- **Status**: 200 OK

```json
{
    "id": 1,
    "projectId": 1,
    "name": "Bug",
    "color": "#990000",
    "displayOrder": 0,
    "templateSummary": "Subject",
    "templateDescription": "Description"
}
```

---

## Update Issue Type

Updates information about an issue type.

- **Method**: PATCH
- **Path**: `/api/v2/projects/:projectIdOrKey/issueTypes/:id`
- **Scope**: Administrator, Normal User
- **Content-Type**: `application/x-www-form-urlencoded`

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectIdOrKey | String | Yes | (URL param) Project ID or Project Key |
| id | Number | Yes | (URL param) Issue Type ID |
| name | String | No | Issue Type name |
| color | String | No | Background color. One of: `"#e30000"`, `"#990000"`, `"#934981"`, `"#814fbc"`, `"#2779ca"`, `"#007e9a"`, `"#7ea800"`, `"#ff9200"`, `"#ff3265"`, `"#666665"` |
| templateSummary | String | No | Template text for the subject field |
| templateDescription | String | No | Template text for the description field |

### Response
- **Status**: 200 OK

```json
{
    "id": 1,
    "projectId": 1,
    "name": "Bug",
    "color": "#990000",
    "displayOrder": 0,
    "templateSummary": "Subject",
    "templateDescription": "Description"
}
```

---

## Delete Issue Type

Deletes an issue type. Issues linked to the deleted type are reassigned to the specified substitute type.

- **Method**: DELETE
- **Path**: `/api/v2/projects/:projectIdOrKey/issueTypes/:id`
- **Scope**: Administrator, Normal User
- **Content-Type**: `application/x-www-form-urlencoded`

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectIdOrKey | String | Yes | (URL param) Project ID or Project Key |
| id | Number | Yes | (URL param) Issue Type ID |
| substituteIssueTypeId | Number | Yes | Issue Type ID to replace linked issues |

### Response
- **Status**: 200 OK

```json
{
    "id": 1,
    "projectId": 1,
    "name": "Bug",
    "color": "#990000",
    "displayOrder": 0,
    "templateSummary": "Subject",
    "templateDescription": "Description"
}
```

---

## Get Category List

Returns list of categories in the project.

- **Method**: GET
- **Path**: `/api/v2/projects/:projectIdOrKey/categories`
- **Scope**: All

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectIdOrKey | String | Yes | (URL param) Project ID or Project Key |

### Response
- **Status**: 200 OK

```json
[
    {
        "id": 12,
        "projectId": 5,
        "name": "Development",
        "displayOrder": 0
    }
]
```

---

## Add Category

Adds a new category to the project.

- **Method**: POST
- **Path**: `/api/v2/projects/:projectIdOrKey/categories`
- **Scope**: Administrator, Normal User
- **Content-Type**: `application/x-www-form-urlencoded`

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectIdOrKey | String | Yes | (URL param) Project ID or Project Key |
| name | String | Yes | Category name |

### Response
- **Status**: 200 OK

```json
{
    "id": 1,
    "projectId": 5,
    "name": "Development",
    "displayOrder": 0
}
```

---

## Update Category

Updates information about a category.

- **Method**: PATCH
- **Path**: `/api/v2/projects/:projectIdOrKey/categories/:id`
- **Scope**: Administrator, Normal User
- **Content-Type**: `application/x-www-form-urlencoded`

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectIdOrKey | String | Yes | (URL param) Project ID or Project Key |
| id | Number | Yes | (URL param) Category ID |
| name | String | Yes | Category name |

### Response
- **Status**: 200 OK

```json
{
    "id": 1,
    "projectId": 5,
    "name": "Development",
    "displayOrder": 0
}
```

---

## Delete Category

Deletes a category from the project.

- **Method**: DELETE
- **Path**: `/api/v2/projects/:projectIdOrKey/categories/:id`
- **Scope**: Administrator, Normal User

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectIdOrKey | String | Yes | (URL param) Project ID or Project Key |
| id | Number | Yes | (URL param) Category ID |

### Response
- **Status**: 200 OK

```json
{
    "id": 1,
    "projectId": 5,
    "name": "Development",
    "displayOrder": 0
}
```

---

## Get Version/Milestone List

Returns list of versions/milestones in the project.

- **Method**: GET
- **Path**: `/api/v2/projects/:projectIdOrKey/versions`
- **Scope**: All

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectIdOrKey | String | Yes | (URL param) Project ID or Project Key |

### Response
- **Status**: 200 OK

```json
[
    {
        "id": 3,
        "projectId": 1,
        "name": "wait for release",
        "description": "",
        "startDate": null,
        "releaseDueDate": null,
        "archived": false,
        "displayOrder": 0
    }
]
```

---

## Add Version/Milestone

Adds a new version/milestone to the project.

- **Method**: POST
- **Path**: `/api/v2/projects/:projectIdOrKey/versions`
- **Scope**: Administrator, Normal User
- **Content-Type**: `application/x-www-form-urlencoded`

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectIdOrKey | String | Yes | (URL param) Project ID or Project Key |
| name | String | Yes | Version name |
| description | String | No | Version description |
| startDate | String | No | Start date (yyyy-MM-dd) |
| releaseDueDate | String | No | Release due date (yyyy-MM-dd) |

### Response
- **Status**: 200 OK

```json
{
    "id": 3,
    "projectId": 1,
    "name": "wait for release",
    "description": "",
    "startDate": null,
    "releaseDueDate": null,
    "archived": false,
    "displayOrder": 0
}
```

---

## Update Version/Milestone

Updates information about a version/milestone.

- **Method**: PATCH
- **Path**: `/api/v2/projects/:projectIdOrKey/versions/:id`
- **Scope**: Administrator, Normal User
- **Content-Type**: `application/x-www-form-urlencoded`

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectIdOrKey | String | Yes | (URL param) Project ID or Project Key |
| id | Number | Yes | (URL param) Version ID |
| name | String | Yes | Version name |
| description | String | No | Version description |
| startDate | String | No | Start date (yyyy-MM-dd) |
| releaseDueDate | String | No | Release due date (yyyy-MM-dd) |
| archived | Boolean | No | Archive status |

### Response
- **Status**: 200 OK

```json
{
    "id": 3,
    "projectId": 1,
    "name": "wait for release",
    "description": "",
    "startDate": null,
    "releaseDueDate": null,
    "archived": false,
    "displayOrder": 0
}
```

---

## Delete Version

Deletes a version/milestone from the project.

- **Method**: DELETE
- **Path**: `/api/v2/projects/:projectIdOrKey/versions/:id`
- **Scope**: Administrator, Normal User

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectIdOrKey | String | Yes | (URL param) Project ID or Project Key |
| id | Number | Yes | (URL param) Version ID |

### Response
- **Status**: 200 OK

```json
{
    "id": 3,
    "projectId": 1,
    "name": "wait for release",
    "description": "",
    "startDate": null,
    "releaseDueDate": null,
    "archived": false,
    "displayOrder": 0
}
```

---

## Get Custom Field List

Returns list of custom fields in the project.

- **Method**: GET
- **Path**: `/api/v2/projects/:projectIdOrKey/customFields`
- **Scope**: All

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectIdOrKey | String | Yes | (URL param) Project ID or Project Key |

### Response
- **Status**: 200 OK

```json
[
    {
        "id": 8,
        "projectId": 5,
        "typeId": 5,
        "name": "language",
        "description": "",
        "required": false,
        "applicableIssueTypes": [],
        "allowAddItem": true,
        "items": [
            {
                "id": 1,
                "name": "java",
                "displayOrder": 0
            }
        ]
    }
]
```

### Custom Field Type IDs
| typeId | Type |
|--------|------|
| 1 | Text |
| 2 | Sentence |
| 3 | Number |
| 4 | Date |
| 5 | Single List |
| 6 | Multiple List |
| 7 | Checkbox |
| 8 | Radio |

---

## Add Custom Field

Adds a new custom field to the project.

- **Method**: POST
- **Path**: `/api/v2/projects/:projectIdOrKey/customFields`
- **Scope**: Administrator, Project Administrator
- **Content-Type**: `application/x-www-form-urlencoded`

### Common Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectIdOrKey | String | Yes | (URL param) Project ID or Project Key |
| typeId | Number | Yes | Field type: 1=Text, 2=Sentence, 3=Number, 4=Date, 5=Single List, 6=Multiple List, 7=Checkbox, 8=Radio |
| name | String | Yes | Field name |
| applicableIssueTypes[] | Number | No | Issue type IDs where this field applies. Omit to apply to all. |
| description | String | No | Field description |
| required | Boolean | No | Whether this field is mandatory |

### Number Type Parameters (typeId=3)

| Name | Type | Required | Description |
|------|------|----------|-------------|
| min | Number | No | Minimum value |
| max | Number | No | Maximum value |
| initialValue | Number | No | Default value |
| unit | String | No | Measurement unit |

### Date Type Parameters (typeId=4)

| Name | Type | Required | Description |
|------|------|----------|-------------|
| min | String | No | Minimum date (yyyy-MM-dd) |
| max | String | No | Maximum date (yyyy-MM-dd) |
| initialValueType | Number | No | Default type: 1=today, 2=today + shift, 3=specified date |
| initialDate | String | No | Specific default date (yyyy-MM-dd) |
| initialShift | Number | No | Day offset from today |

### List Type Parameters (typeId=5,6,7,8)

| Name | Type | Required | Description |
|------|------|----------|-------------|
| items[] | String | No | List option values |
| allowInput | Boolean | No | Enable "Other" text input option |
| allowAddItem | Boolean | No | Allow users to add new list items |

### Response
- **Status**: 200 OK

```json
{
    "id": 2,
    "projectId": 5,
    "typeId": 1,
    "name": "Attribute for Bug",
    "description": "",
    "required": false,
    "applicableIssueTypes": [1]
}
```

---

## Update Custom Field

Updates an existing custom field.

- **Method**: PATCH
- **Path**: `/api/v2/projects/:projectIdOrKey/customFields/:id`
- **Scope**: Administrator, Project Administrator
- **Content-Type**: `application/x-www-form-urlencoded`

### Common Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectIdOrKey | String | Yes | (URL param) Project ID or Project Key |
| id | Number | Yes | (URL param) Custom Field ID |
| name | String | No | Field name |
| applicableIssueTypes[] | Number | No | Issue type IDs where this field applies. Omit to apply to all. |
| description | String | No | Field description |
| required | Boolean | No | Whether this field is mandatory |

### Number Type Parameters (typeId=3)

| Name | Type | Required | Description |
|------|------|----------|-------------|
| min | Number | No | Minimum value |
| max | Number | No | Maximum value |
| initialValue | Number | No | Default value |
| unit | String | No | Measurement unit |

### Date Type Parameters (typeId=4)

| Name | Type | Required | Description |
|------|------|----------|-------------|
| min | String | No | Minimum date (yyyy-MM-dd) |
| max | String | No | Maximum date (yyyy-MM-dd) |
| initialValueType | Number | No | Default type: 1=today, 2=today + shift, 3=specified date |
| initialDate | String | No | Specific default date (yyyy-MM-dd) |
| initialShift | Number | No | Day offset from today |

### List Type Parameters (typeId=5,6,7,8)

| Name | Type | Required | Description |
|------|------|----------|-------------|
| items[] | String | No | List option values |
| allowInput | Boolean | No | Enable "Other" text input option |
| allowAddItem | Boolean | No | Allow users to add new list items |

### Response
- **Status**: 200 OK

```json
{
    "id": 2,
    "projectId": 5,
    "typeId": 1,
    "name": "Attribute for Bug",
    "description": "",
    "required": false,
    "applicableIssueTypes": [1]
}
```

---

## Delete Custom Field

Deletes a custom field from the project.

- **Method**: DELETE
- **Path**: `/api/v2/projects/:projectIdOrKey/customFields/:id`
- **Scope**: Administrator, Project Administrator

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectIdOrKey | String | Yes | (URL param) Project ID or Project Key |
| id | Number | Yes | (URL param) Custom Field ID |

### Response
- **Status**: 200 OK

```json
{
    "id": 2,
    "projectId": 5,
    "typeId": 1,
    "name": "Attribute for Bug",
    "description": "",
    "required": false,
    "applicableIssueTypes": [1]
}
```

---

## Add List Item for List Type Custom Field

Adds a new list item to a list-type custom field. Fails if the specified custom field is not a list type.

- **Method**: POST
- **Path**: `/api/v2/projects/:projectIdOrKey/customFields/:id/items`
- **Scope**: Administrator, Normal User (Administrator only if "Add items in adding or editing issues" is disabled)
- **Content-Type**: `application/x-www-form-urlencoded`

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectIdOrKey | String | Yes | (URL param) Project ID or Project Key |
| id | Number | Yes | (URL param) Custom Field ID |
| name | String | Yes | List item name |

### Response
- **Status**: 200 OK

```json
{
    "id": 8,
    "projectId": 5,
    "typeId": 5,
    "name": "language",
    "description": "",
    "required": false,
    "applicableIssueTypes": [],
    "allowAddItem": true,
    "items": [
        {
            "id": 1,
            "name": "java",
            "displayOrder": 0
        }
    ]
}
```

---

## Update List Item for List Type Custom Field

Updates an existing list item in a list-type custom field. Fails if the specified custom field is not a list type.

- **Method**: PATCH
- **Path**: `/api/v2/projects/:projectIdOrKey/customFields/:id/items/:itemId`
- **Scope**: Administrator, Project Administrator
- **Content-Type**: `application/x-www-form-urlencoded`

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectIdOrKey | String | Yes | (URL param) Project ID or Project Key |
| id | Number | Yes | (URL param) Custom Field ID |
| itemId | Number | Yes | (URL param) List Item ID |
| name | String | Yes | List item name |

### Response
- **Status**: 200 OK

```json
{
    "id": 8,
    "projectId": 5,
    "typeId": 5,
    "name": "language",
    "description": "",
    "required": false,
    "applicableIssueTypes": [],
    "allowAddItem": true,
    "items": [
        {
            "id": 1,
            "name": "java",
            "displayOrder": 0
        }
    ]
}
```

---

## Delete List Item for List Type Custom Field

Deletes a list item from a list-type custom field. Fails if the specified custom field is not a list type.

- **Method**: DELETE
- **Path**: `/api/v2/projects/:projectIdOrKey/customFields/:id/items/:itemId`
- **Scope**: Administrator, Project Administrator

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectIdOrKey | String | Yes | (URL param) Project ID or Project Key |
| id | Number | Yes | (URL param) Custom Field ID |
| itemId | Number | Yes | (URL param) List Item ID |

### Response
- **Status**: 200 OK

```json
{
    "id": 8,
    "projectId": 5,
    "typeId": 5,
    "name": "language",
    "description": "",
    "required": false,
    "applicableIssueTypes": [],
    "allowAddItem": true,
    "items": [
        {
            "id": 1,
            "name": "java",
            "displayOrder": 0
        }
    ]
}
```
