# Document API

## Table of Contents

- [Get Document List](#get-document-list)
- [Add Document](#add-document)
- [Get Document](#get-document)
- [Get Document Tree](#get-document-tree)
- [Get Document Attachments](#get-document-attachments)
- [Delete Document](#delete-document)

---

## Get Document List

Returns list of Document pages.

- **Method**: GET
- **Path**: `/api/v2/documents`
- **Scope**: All

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectId[] | Number | No | Project ID. Multiple values supported. |
| keyword | String | No | Search keyword for filtering documents |
| sort | String | No | Sort field: `created` or `updated` |
| order | String | No | Sort direction: `asc` or `desc` (default: `desc`) |
| offset | Number | Yes | Pagination offset |
| count | Number | No | Number of records (1-100, default: 20) |

### Response
- **Status**: 200 OK

```json
[
    {
        "id": "01939983409c79d5a06a49859789e38f",
        "projectId": 1,
        "title": "Hello",
        "plain": "hello",
        "json": "{}",
        "statusId": 1,
        "emoji": "🎉",
        "attachments": [
            {
                "id": 22067,
                "name": "test.png",
                "size": 8718,
                "createdUser": {
                    "id": 3,
                    "userId": "woody",
                    "name": "woody",
                    "roleType": 2,
                    "lang": "ja",
                    "mailAddress": "woody@nulab.com",
                    "nulabAccount": {
                        "nulabId": "aaa",
                        "name": "woody",
                        "uniqueId": "woody",
                        "iconUrl": "https://photo"
                    },
                    "keyword": "woody",
                    "lastLoginTime": "2025-05-22T23:04:03Z"
                },
                "created": "2025-05-29T02:19:54Z"
            }
        ],
        "tags": [
            {
                "id": 1,
                "name": "Backlog"
            }
        ],
        "createdUser": {
            "id": 2,
            "userId": "woody",
            "name": "woody",
            "roleType": 1,
            "lang": "en",
            "mailAddress": "woody@nulab.com",
            "nulabAccount": null,
            "keyword": "Woody",
            "lastLoginTime": "2025-05-28T22:24:36Z"
        },
        "created": "2024-12-06T01:08:56Z",
        "updatedUser": {
            "id": 2,
            "userId": "woody",
            "name": "woody",
            "roleType": 1,
            "lang": "en",
            "mailAddress": "woody@nulab.com",
            "nulabAccount": null,
            "keyword": "Woody",
            "lastLoginTime": "2025-05-28T22:24:36Z"
        },
        "updated": "2025-04-28T01:47:02Z"
    }
]
```

---

## Add Document

Adds new Document page.

- **Method**: POST
- **Path**: `/api/v2/documents`
- **Scope**: Administrator, Normal User
- **Content-Type**: `application/x-www-form-urlencoded`

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectId | Number | Yes | Project ID |
| title | String | No | Document title |
| content | String | No | Document body content (parsed as Markdown) |
| emoji | String | No | Icon emoji displayed next to the document title |
| parentId | String | No | Parent document ID for tree hierarchy nesting |
| addLast | Boolean | No | If true, positions as last sibling (default: false) |

### Response
- **Status**: 201 Created

```json
{
    "id": "019b4e27b88b7cc4ae16d72c3de62299",
    "projectId": 1,
    "title": "document title",
    "json": {
        "type": "doc",
        "content": [
            {
                "type": "heading",
                "attrs": {
                    "id": "NmU",
                    "level": 1
                },
                "content": [
                    {
                        "type": "text",
                        "text": "head"
                    }
                ]
            },
            {
                "type": "paragraph",
                "content": [
                    {
                        "type": "text",
                        "text": "hello"
                    }
                ]
            }
        ]
    },
    "plain": "# head \n hello",
    "statusId": 1,
    "emoji": "👍",
    "createdUserId": 2,
    "created": "2025-12-24T02:19:42Z",
    "updatedUserId": 2,
    "updated": "2025-12-24T02:19:42Z"
}
```

---

## Get Document

Returns information about Document page.

- **Method**: GET
- **Path**: `/api/v2/documents/:documentId`
- **Scope**: All

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| documentId | String | Yes | Document ID (URL parameter) |

### Response
- **Status**: 200 OK

```json
{
    "id": "0193b335c62173de9547bab5dd0b5324",
    "projectId": 1,
    "title": "top",
    "plain": "hello",
    "json": "{}",
    "statusId": 1,
    "emoji": null,
    "attachments": [
        {
            "id": 22067,
            "name": "test.png",
            "size": 8718,
            "createdUser": {
                "id": 3,
                "userId": "woody",
                "name": "woody",
                "roleType": 2,
                "lang": "ja",
                "mailAddress": "woody@nulab.com",
                "nulabAccount": {
                    "nulabId": "aaa",
                    "name": "woody",
                    "uniqueId": "woody",
                    "iconUrl": "https://photo"
                },
                "keyword": "woody",
                "lastLoginTime": "2025-05-22T23:04:03Z"
            },
            "created": "2025-05-29T02:19:54Z"
        }
    ],
    "tags": [
        {
            "id": 1,
            "name": "Backlog"
        }
    ],
    "createdUser": {
        "id": 2,
        "userId": "woody",
        "name": "woody",
        "roleType": 1,
        "lang": "en",
        "mailAddress": "woody@nulab.com",
        "nulabAccount": null,
        "keyword": "Woody",
        "lastLoginTime": "2025-05-28T22:24:36Z"
    },
    "created": "2024-12-06T01:08:56Z",
    "updatedUser": {
        "id": 2,
        "userId": "woody",
        "name": "woody",
        "roleType": 1,
        "lang": "en",
        "mailAddress": "woody@nulab.com",
        "nulabAccount": null,
        "keyword": "Woody",
        "lastLoginTime": "2025-05-28T22:24:36Z"
    },
    "updated": "2025-04-28T01:47:02Z"
}
```

---

## Get Document Tree

Returns information about Document Tree.

- **Method**: GET
- **Path**: `/api/v2/documents/tree`
- **Scope**: All

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectIdOrKey | String | Yes | Project ID or project key |

### Response
- **Status**: 200 OK

```json
{
    "projectId": 1,
    "activeTree": {
        "id": "Active",
        "children": [
            {
                "id": "01934345404771adb2113d7792bb4351",
                "name": "local test",
                "children": [
                    {
                        "id": "019347fc760c7b0abff04b44628c94d7",
                        "name": "test2",
                        "children": [
                            {
                                "id": "0192ff5990da76c289dee06b1f11fa01",
                                "name": "aaatest234",
                                "children": []
                            }
                        ],
                        "emoji": ""
                    }
                ],
                "emoji": ""
            }
        ]
    },
    "trashTree": {
        "id": "Trash",
        "children": []
    }
}
```

### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| projectId | Number | Project ID |
| activeTree | Object | Active document tree root |
| activeTree.id | String | Tree identifier (`"Active"`) |
| activeTree.children | Array | Array of document nodes |
| trashTree | Object | Trash document tree root |
| trashTree.id | String | Tree identifier (`"Trash"`) |
| trashTree.children | Array | Array of deleted document nodes |

Each document node contains:

| Field | Type | Description |
|-------|------|-------------|
| id | String | Document ID |
| name | String | Document title |
| children | Array | Nested child document nodes |
| emoji | String | Optional emoji icon |

---

## Get Document Attachments

Downloads Document page's attachment file.

- **Method**: GET
- **Path**: `/api/v2/documents/:documentId/attachments/:attachmentId`
- **Scope**: All

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| documentId | String | Yes | Document ID (URL parameter) |
| attachmentId | Number | Yes | Attachment file ID (URL parameter) |

### Response
- **Status**: 200 OK
- **Content-Type**: `application/octet-stream`
- **Content-Disposition**: `attachment;filename="<filename>"`

Response body is the binary file content.

---

## Delete Document

Deletes document.

- **Method**: DELETE
- **Path**: `/api/v2/documents/:documentId`
- **Scope**: Administrator, Normal User

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| documentId | String | Yes | Document ID (URL parameter) |

### Response
- **Status**: 200 OK

```json
{
    "id": "019b4e27b88b7cc4ae16d72c3de62299",
    "projectId": 17,
    "title": "Document Title",
    "json": null,
    "plain": null,
    "statusId": 1,
    "emoji": "👍",
    "createdUserId": 2,
    "created": "2025-12-24T02:19:42Z",
    "updatedUserId": 2,
    "updated": "2025-12-24T02:19:42Z"
}
```

### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| id | String | Document ID |
| projectId | Number | Project ID |
| title | String | Document title |
| json | Object/null | JSON-formatted content (null after deletion) |
| plain | String/null | Plain text content (null after deletion) |
| statusId | Number | Document status ID |
| emoji | String/null | Associated emoji |
| createdUserId | Number | Creator user ID |
| created | String | Creation timestamp (ISO 8601) |
| updatedUserId | Number | Last modifier user ID |
| updated | String | Last update timestamp (ISO 8601) |
