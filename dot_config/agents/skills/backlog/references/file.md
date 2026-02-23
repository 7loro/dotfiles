# Shared Files API

## Table of Contents
- [Get List of Shared Files](#get-list-of-shared-files)
- [Get File](#get-file)
- [Get Project Disk Usage](#get-project-disk-usage)

---

## Get List of Shared Files

- **Method**: GET
- **Path**: `/api/v2/projects/:projectIdOrKey/files/metadata/:path`
- **Scope**: Administrator, Normal User

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectIdOrKey | String | Yes | Project ID or Project Key (URL parameter) |
| path | String | Yes | Directory path for shared files (URL parameter) |
| order | String | No | Sort order: `"asc"` or `"desc"` (default: `"desc"`) |
| offset | Number | No | Starting position for pagination |
| count | Number | No | Records to retrieve (1-100, default: 20) |

### Response
- **Status**: 200 OK

```json
[
    {
        "id": 454403,
        "projectId": 26890,
        "type": "file",
        "dir": "/userIcon/",
        "name": "01_male_user_03.png",
        "size": 2735,
        "createdUser": {
            "id": 5686,
            "userId": "takada",
            "name": "takada",
            "roleType": 2,
            "lang": "ja",
            "mailAddress": "takada@nulab.example",
            "lastLoginTime": "2022-09-01T06:35:39Z"
        },
        "created": "2009-02-27T03:26:15Z",
        "updatedUser": null,
        "updated": "2009-03-03T16:57:47Z"
    }
]
```

---

## Get File

- **Method**: GET
- **Path**: `/api/v2/projects/:projectIdOrKey/files/:sharedFileId`
- **Scope**: Administrator, Normal User

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectIdOrKey | String | Yes | Project ID or Project Key (URL parameter) |
| sharedFileId | Number | Yes | Shared file ID (URL parameter) |

### Response
- **Status**: 200 OK
- **Content-Type**: `application/octet-stream`
- **Content-Disposition**: `attachment;filename="sharedFile.doc"`

Returns binary file content as a downloadable attachment.

---

## Get Project Disk Usage

- **Method**: GET
- **Path**: `/api/v2/projects/:projectIdOrKey/diskUsage`
- **Scope**: Administrator

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectIdOrKey | String | Yes | Project ID or Project Key (URL parameter) |

### Response
- **Status**: 200 OK

```json
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
```

### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| projectId | Number | Project identifier |
| issue | Number | Storage used by issues (bytes) |
| wiki | Number | Storage used by wiki pages (bytes) |
| document | Number | Storage used by documents (bytes) |
| file | Number | Storage used by shared files (bytes) |
| subversion | Number | Storage used by Subversion repository (bytes) |
| git | Number | Storage used by Git repositories (bytes) |
| gitLFS | Number | Storage used by Git LFS (bytes) |
