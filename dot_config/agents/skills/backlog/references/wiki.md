# Wiki API

## Table of Contents

- [Get Wiki Page List](#get-wiki-page-list)
- [Count Wiki Page](#count-wiki-page)
- [Get Wiki Page Tag List](#get-wiki-page-tag-list)
- [Add Wiki Page](#add-wiki-page)
- [Get Wiki Page](#get-wiki-page)
- [Update Wiki Page](#update-wiki-page)
- [Delete Wiki Page](#delete-wiki-page)
- [Get List of Wiki Attachments](#get-list-of-wiki-attachments)
- [Attach File to Wiki](#attach-file-to-wiki)
- [Get Wiki Page Attachment](#get-wiki-page-attachment)
- [Remove Wiki Attachment](#remove-wiki-attachment)
- [Get List of Shared Files on Wiki](#get-list-of-shared-files-on-wiki)
- [Link Shared Files to Wiki](#link-shared-files-to-wiki)
- [Remove Link to Shared File from Wiki](#remove-link-to-shared-file-from-wiki)
- [Get Wiki Page History](#get-wiki-page-history)
- [Get Wiki Page Star](#get-wiki-page-star)

---

## Get Wiki Page List

Returns list of Wiki pages.

- **Method**: GET
- **Path**: `/api/v2/wikis`
- **Scope**: All

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectIdOrKey | String | Yes | Project ID or project key |
| keyword | String | No | Search keyword to filter wiki pages |

### Response
- **Status**: 200 OK

```json
[
    {
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
    }
]
```

---

## Count Wiki Page

Returns the number of Wiki pages.

- **Method**: GET
- **Path**: `/api/v2/wikis/count`
- **Scope**: All

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectIdOrKey | String | Yes | Project ID or project key |

### Response
- **Status**: 200 OK

```json
{
    "count": 5
}
```

---

## Get Wiki Page Tag List

Returns list of tags that are used in the project.

- **Method**: GET
- **Path**: `/api/v2/wikis/tags`
- **Scope**: All

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectIdOrKey | String | Yes | Project ID or project key |

### Response
- **Status**: 200 OK

```json
[
    {
        "id": 1,
        "name": "test"
    }
]
```

---

## Add Wiki Page

Adds new Wiki page.

- **Method**: POST
- **Path**: `/api/v2/wikis`
- **Scope**: Administrator, Normal User
- **Content-Type**: `application/x-www-form-urlencoded`

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectId | Number | Yes | Project ID |
| name | String | Yes | Page name |
| content | String | Yes | Page content |
| mailNotify | Boolean | No | If true, sends email notification to project members |

### Response
- **Status**: 201 Created

```json
{
    "id": 1,
    "projectId": 1,
    "name": "Home",
    "content": "test",
    "tags": [
        {
            "id": 12,
            "name": "proceedings"
        }
    ],
    "attachments": [],
    "sharedFiles": [],
    "stars": [],
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
    "created": "2012-07-23T06:09:48Z",
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
    "updated": "2012-07-23T06:09:48Z"
}
```

---

## Get Wiki Page

Returns information about Wiki page.

- **Method**: GET
- **Path**: `/api/v2/wikis/:wikiId`
- **Scope**: All

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| wikiId | Number | Yes | Wiki page ID (URL parameter) |

### Response
- **Status**: 200 OK

```json
{
    "id": 1,
    "projectId": 1,
    "name": "Home",
    "content": "test",
    "tags": [
        {
            "id": 12,
            "name": "proceedings"
        }
    ],
    "attachments": [
        {
            "id": 1,
            "name": "test.json",
            "size": 8857,
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
            "created": "2014-01-06T11:10:45Z"
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
    "stars": [],
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
    "created": "2012-07-23T06:09:48Z",
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
    "updated": "2012-07-23T06:09:48Z"
}
```

---

## Update Wiki Page

Updates information about Wiki page.

- **Method**: PATCH
- **Path**: `/api/v2/wikis/:wikiId`
- **Scope**: Administrator, Normal User
- **Content-Type**: `application/x-www-form-urlencoded`

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| wikiId | Number | Yes | Wiki page ID (URL parameter) |
| name | String | No | Page name |
| content | String | No | Page content |
| mailNotify | Boolean | No | If true, sends email notification |

### Response
- **Status**: 200 OK

Response body is the same structure as [Get Wiki Page](#get-wiki-page).

---

## Delete Wiki Page

Deletes Wiki page.

- **Method**: DELETE
- **Path**: `/api/v2/wikis/:wikiId`
- **Scope**: Administrator, Normal User
- **Content-Type**: `application/x-www-form-urlencoded`

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| wikiId | Number | Yes | Wiki page ID (URL parameter) |
| mailNotify | Boolean | No | If true, sends email notification |

### Response
- **Status**: 200 OK

Response body is the same structure as [Get Wiki Page](#get-wiki-page).

---

## Get List of Wiki Attachments

Returns list of files attached to Wiki.

- **Method**: GET
- **Path**: `/api/v2/wikis/:wikiId/attachments`
- **Scope**: All

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| wikiId | Number | Yes | Wiki page ID (URL parameter) |

### Response
- **Status**: 200 OK

```json
[
    {
        "id": 1,
        "name": "IMGP0088.JPG",
        "size": 85079
    }
]
```

---

## Attach File to Wiki

Attaches file to Wiki. Files must be uploaded first via the Post Attachment File API.

- **Method**: POST
- **Path**: `/api/v2/wikis/:wikiId/attachments`
- **Scope**: Administrator, Normal User
- **Content-Type**: `application/x-www-form-urlencoded`

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| wikiId | Number | Yes | Wiki page ID (URL parameter) |
| attachmentId[] | Number | Yes | Attachment file ID (returned by Post Attachment File API). Multiple values supported. |

### Response
- **Status**: 200 OK

```json
[
    {
        "id": 2,
        "name": "Duke.png",
        "size": 196186,
        "createdUser": {
            "id": 1,
            "userId": "admin",
            "name": "admin",
            "roleType": 1,
            "mailAddress": "eguchi@nulab.example",
            "lastLoginTime": "2022-09-01T06:35:39Z"
        },
        "created": "2014-07-11T06:26:05Z"
    }
]
```

---

## Get Wiki Page Attachment

Downloads Wiki page's attachment file.

- **Method**: GET
- **Path**: `/api/v2/wikis/:wikiId/attachments/:attachmentId`
- **Scope**: All

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| wikiId | Number | Yes | Wiki page ID (URL parameter) |
| attachmentId | Number | Yes | Attachment file ID (URL parameter) |

### Response
- **Status**: 200 OK
- **Content-Type**: `application/octet-stream`
- **Content-Disposition**: `attachment;filename="<filename>"`

Response body is the binary file content.

---

## Remove Wiki Attachment

Removes files attached to Wiki.

- **Method**: DELETE
- **Path**: `/api/v2/wikis/:wikiId/attachments/:attachmentId`
- **Scope**: Administrator, Normal User

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| wikiId | Number | Yes | Wiki page ID (URL parameter) |
| attachmentId | Number | Yes | Attachment file ID (URL parameter) |

### Response
- **Status**: 200 OK

```json
{
    "id": 2,
    "name": "Duke.png",
    "size": 196186,
    "createdUser": {
        "id": 1,
        "userId": "admin",
        "name": "admin",
        "roleType": 1,
        "mailAddress": "eguchi@nulab.example",
        "lastLoginTime": "2022-09-01T06:35:39Z"
    },
    "created": "2014-07-11T06:26:05Z"
}
```

---

## Get List of Shared Files on Wiki

Returns the list of Shared Files on Wiki.

- **Method**: GET
- **Path**: `/api/v2/wikis/:wikiId/sharedFiles`
- **Scope**: Administrator, Normal User

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| wikiId | Number | Yes | Wiki page ID (URL parameter) |

### Response
- **Status**: 200 OK

```json
[
    {
        "id": 825952,
        "projectId": 5,
        "type": "file",
        "dir": "/PressRelease/20091130/",
        "name": "20091130.txt",
        "size": 4836,
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
        "created": "2009-11-30T01:22:21Z",
        "updatedUser": null,
        "updated": "2009-11-30T01:22:21Z"
    }
]
```

---

## Link Shared Files to Wiki

Links shared files to Wiki.

- **Method**: POST
- **Path**: `/api/v2/wikis/:wikiId/sharedFiles`
- **Scope**: Administrator, Normal User
- **Content-Type**: `application/x-www-form-urlencoded`

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| wikiId | Number | Yes | Wiki page ID (URL parameter) |
| fileId[] | Number | Yes | Shared file ID. Multiple values supported. |

### Response
- **Status**: 200 OK

Response body is an array of shared file objects. See [Get List of Shared Files on Wiki](#get-list-of-shared-files-on-wiki) for structure.

---

## Remove Link to Shared File from Wiki

Removes link to shared file from Wiki.

- **Method**: DELETE
- **Path**: `/api/v2/wikis/:wikiId/sharedFiles/:id`
- **Scope**: Administrator, Normal User

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| wikiId | Number | Yes | Wiki page ID (URL parameter) |
| id | Number | Yes | Shared file ID (URL parameter) |

### Response
- **Status**: 200 OK

Response body is a shared file object. See [Get List of Shared Files on Wiki](#get-list-of-shared-files-on-wiki) for structure.

---

## Get Wiki Page History

Returns history of Wiki page.

- **Method**: GET
- **Path**: `/api/v2/wikis/:wikiId/history`
- **Scope**: All

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| wikiId | Number | Yes | Wiki page ID (URL parameter) |
| minId | Number | No | Minimum version ID |
| maxId | Number | No | Maximum version ID |
| count | Number | No | Number of records to retrieve (1-100, default: 20) |
| order | String | No | Sort order: `asc` or `desc` (default: `desc`) |

### Response
- **Status**: 200 OK

```json
[
    {
        "pageId": 1,
        "version": 1,
        "name": "test",
        "content": "hello world",
        "createdUser": {
            "id": 1,
            "userId": "admin",
            "name": "admin",
            "roleType": 1,
            "lang": null,
            "nulabAccount": {
                "nulabId": "Prm9ZD9DQD5snNWcSYSwZiQoA9WFBUEa2ySznrSnSQRhdC2X8G",
                "name": "admin",
                "uniqueId": "admin"
            },
            "mailAddress": "eguchi@nulab.example",
            "lastLoginTime": "2022-09-01T06:35:39Z"
        },
        "created": "2014-06-24T05:04:48Z"
    }
]
```

---

## Get Wiki Page Star

Returns list of stars received on the Wiki page.

- **Method**: GET
- **Path**: `/api/v2/wikis/:wikiId/stars`
- **Scope**: All

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| wikiId | Number | Yes | Wiki page ID (URL parameter) |

### Response
- **Status**: 200 OK

```json
[
    {
        "id": 75,
        "comment": null,
        "url": "https://xx.backlogtool.com/alias/wiki/1",
        "title": "[TEST1] Home | Wiki - Backlog",
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
