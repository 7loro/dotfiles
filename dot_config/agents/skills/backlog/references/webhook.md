# Webhook API

## Table of Contents
- [Get List of Webhooks](#get-list-of-webhooks)
- [Add Webhook](#add-webhook)
- [Get Webhook](#get-webhook)
- [Update Webhook](#update-webhook)
- [Delete Webhook](#delete-webhook)

---

## Get List of Webhooks

- **Method**: GET
- **Path**: `/api/v2/projects/:projectIdOrKey/webhooks`
- **Scope**: Administrator, Project Administrator

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectIdOrKey | String | Yes | Project ID or Project Key (URL parameter) |

### Response
- **Status**: 200 OK

```json
[
    {
        "id": 3,
        "name": "webhook",
        "description": "",
        "hookUrl": "http://nulab.test/",
        "allEvent": false,
        "activityTypeIds": [1, 2, 3, 4, 5],
        "createdUser": {
            "id": 1,
            "userId": "admin",
            "name": "admin",
            "roleType": 1,
            "lang": "ja",
            "nulabAccount": {
                "nulabId": "abcdefghijklmnopqrstuvwxyz",
                "name": "admin",
                "uniqueId": "admin"
            },
            "mailAddress": "eguchi@nulab.example",
            "lastLoginTime": "2022-09-01T06:35:39Z"
        },
        "created": "2014-11-30T01:22:21Z",
        "updatedUser": {
            "id": 1,
            "userId": "admin",
            "name": "admin",
            "roleType": 1,
            "lang": "ja",
            "nulabAccount": {
                "nulabId": "abcdefghijklmnopqrstuvwxyz",
                "name": "admin",
                "uniqueId": "admin"
            },
            "mailAddress": "eguchi@nulab.example",
            "lastLoginTime": "2022-09-01T06:35:39Z"
        },
        "updated": "2014-11-30T01:22:21Z"
    }
]
```

---

## Add Webhook

- **Method**: POST
- **Path**: `/api/v2/projects/:projectIdOrKey/webhooks`
- **Scope**: Administrator, Project Administrator
- **Content-Type**: `application/x-www-form-urlencoded`

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectIdOrKey | String | Yes | Project ID or Project Key (URL parameter) |
| name | String | Yes | Webhook name |
| description | String | No | Webhook description |
| hookUrl | String | Yes | Destination URL for webhook notifications |
| allEvent | Boolean | No | Set to `true` to trigger on all events |
| activityTypeIds[] | Number | No | Event type IDs that trigger the webhook (multiple allowed) |

### Response
- **Status**: 200 OK

```json
{
    "id": 3,
    "name": "webhook",
    "description": "",
    "hookUrl": "http://nulab.test/",
    "allEvent": false,
    "activityTypeIds": [1, 2, 3, 4, 5],
    "createdUser": {
        "id": 1,
        "userId": "admin",
        "name": "admin",
        "roleType": 1,
        "lang": "ja",
        "nulabAccount": {
            "nulabId": "abcdefghijklmnopqrstuvwxyz",
            "name": "admin",
            "uniqueId": "admin"
        },
        "mailAddress": "eguchi@nulab.example",
        "lastLoginTime": "2022-09-01T06:35:39Z"
    },
    "created": "2014-11-30T01:22:21Z",
    "updatedUser": {
        "id": 1,
        "userId": "admin",
        "name": "admin",
        "roleType": 1,
        "lang": "ja",
        "nulabAccount": {
            "nulabId": "abcdefghijklmnopqrstuvwxyz",
            "name": "admin",
            "uniqueId": "admin"
        },
        "mailAddress": "eguchi@nulab.example",
        "lastLoginTime": "2022-09-01T06:35:39Z"
    },
    "updated": "2014-11-30T01:22:21Z"
}
```

---

## Get Webhook

- **Method**: GET
- **Path**: `/api/v2/projects/:projectIdOrKey/webhooks/:webhookId`
- **Scope**: Administrator, Project Administrator

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectIdOrKey | String | Yes | Project ID or Project Key (URL parameter) |
| webhookId | String | Yes | Webhook ID (URL parameter) |

### Response
- **Status**: 200 OK

```json
{
    "id": 3,
    "name": "webhook",
    "description": "",
    "hookUrl": "http://nulab.test/",
    "allEvent": false,
    "activityTypeIds": [1, 2, 3, 4, 5],
    "createdUser": {
        "id": 1,
        "userId": "admin",
        "name": "admin",
        "roleType": 1,
        "lang": "ja",
        "nulabAccount": {
            "nulabId": "abcdefghijklmnopqrstuvwxyz",
            "name": "admin",
            "uniqueId": "admin"
        },
        "mailAddress": "eguchi@nulab.example",
        "lastLoginTime": "2022-09-01T06:35:39Z"
    },
    "created": "2014-11-30T01:22:21Z",
    "updatedUser": {
        "id": 1,
        "userId": "admin",
        "name": "admin",
        "roleType": 1,
        "lang": "ja",
        "nulabAccount": {
            "nulabId": "abcdefghijklmnopqrstuvwxyz",
            "name": "admin",
            "uniqueId": "admin"
        },
        "mailAddress": "eguchi@nulab.example",
        "lastLoginTime": "2022-09-01T06:35:39Z"
    },
    "updated": "2014-11-30T01:22:21Z"
}
```

---

## Update Webhook

- **Method**: PATCH
- **Path**: `/api/v2/projects/:projectIdOrKey/webhooks/:webhookId`
- **Scope**: Administrator, Project Administrator
- **Content-Type**: `application/x-www-form-urlencoded`

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectIdOrKey | String | Yes | Project ID or Project Key (URL parameter) |
| webhookId | String | Yes | Webhook ID (URL parameter) |
| name | String | No | Webhook name |
| description | String | No | Webhook description |
| hookUrl | String | No | Target URL for webhook delivery |
| allEvent | Boolean | No | Set to `true` to trigger on all events |
| activityTypeIds[] | Number | No | Event type IDs that trigger the webhook (multiple allowed) |

### Response
- **Status**: 200 OK

```json
{
    "id": 3,
    "name": "webhook",
    "description": "",
    "hookUrl": "http://nulab.test/",
    "allEvent": false,
    "activityTypeIds": [1, 2, 3, 4, 5],
    "createdUser": {
        "id": 1,
        "userId": "admin",
        "name": "admin",
        "roleType": 1,
        "lang": "ja",
        "nulabAccount": {
            "nulabId": "abcdefghijklmnopqrstuvwxyz",
            "name": "admin",
            "uniqueId": "admin"
        },
        "mailAddress": "eguchi@nulab.example",
        "lastLoginTime": "2022-09-01T06:35:39Z"
    },
    "created": "2014-11-30T01:22:21Z",
    "updatedUser": {
        "id": 1,
        "userId": "admin",
        "name": "admin",
        "roleType": 1,
        "lang": "ja",
        "nulabAccount": {
            "nulabId": "abcdefghijklmnopqrstuvwxyz",
            "name": "admin",
            "uniqueId": "admin"
        },
        "mailAddress": "eguchi@nulab.example",
        "lastLoginTime": "2022-09-01T06:35:39Z"
    },
    "updated": "2014-11-30T01:22:21Z"
}
```

---

## Delete Webhook

- **Method**: DELETE
- **Path**: `/api/v2/projects/:projectIdOrKey/webhooks/:webhookId`
- **Scope**: Administrator, Project Administrator

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| projectIdOrKey | String | Yes | Project ID or Project Key (URL parameter) |
| webhookId | String | Yes | Webhook ID (URL parameter) |

### Response
- **Status**: 200 OK

Returns the deleted webhook object (same structure as Get Webhook response).
