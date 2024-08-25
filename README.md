# Introduction

[Chezmoi](https://www.chezmoi.io/) 를 활용한 dotfiles 관리

## 새로운 컴퓨터에서 설정 가져올 때

```bash
chezmoi init --apply git@github.com:7loro/dotfiles.git
```

## 주요 명령어

```bash
// chezmoi 작업 디렉토리 이동
chezmoi cd

// 관리할 파일 추가
chezmoi add 파일

// 파일 내용 변경 (직접 바꾸지 말고, chezmoi 통해 변경하기, git stage 느낌)
chezmoi edit 원래 경로

// 작업 내용 확인
chezmoid diff

// 작업 내용 반영
chezmoi apply -v

// 저장소로부터 받아서 내용 반영하기
chezmoi update -v
```
