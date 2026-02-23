# Star API

## Table of Contents
- [Add Star](#add-star)
- [Remove Star](#remove-star)

---

## Add Star

- **Method**: POST
- **Path**: `/api/v2/stars`
- **Scope**: All
- **Content-Type**: `application/x-www-form-urlencoded`

### Parameters

At least one parameter must be provided.

| Name | Type | Required | Description |
|------|------|----------|-------------|
| issueId | Number | No* | Issue ID to star |
| commentId | Number | No* | Comment ID to star |
| wikiId | Number | No* | Wiki page ID to star |
| pullRequestId | Number | No* | Pull request ID to star |
| pullRequestCommentId | Number | No* | Pull request comment ID to star |

> *Exactly one of these parameters should be provided per request.

### Response
- **Status**: 204 No Content

---

## Remove Star

- **Method**: DELETE
- **Path**: `/api/v2/stars/:starId`
- **Scope**: All

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| starId | Number | Yes | Star ID to remove (URL parameter) |

### Response
- **Status**: 204 No Content
