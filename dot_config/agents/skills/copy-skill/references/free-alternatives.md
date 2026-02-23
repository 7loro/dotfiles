# 유료/외부 의존성 → 무료/빌트인 대체 매핑

## AI API 대체

| 유료/외부 서비스 | 무료/빌트인 대체 | 비고 |
|---|---|---|
| Google Gemini API | Claude 빌트인 (WebFetch, WebSearch) | Gemini로 요약/분석하는 경우 → Claude가 직접 처리 |
| OpenAI API (GPT) | Claude 빌트인 | 외부 LLM 호출 불필요 |
| Google Cloud Vision | Claude 빌트인 이미지 분석 (Read tool) | Claude는 이미지 직접 분석 가능 |
| Whisper API | 로컬 whisper.cpp 또는 빌트인 불가 표시 | 음성 처리는 대체 제한적 |

## 웹 스크래핑/검색 대체

| 유료/외부 서비스 | 무료/빌트인 대체 | 비고 |
|---|---|---|
| SerpAPI | WebSearch (빌트인) | 기본 웹 검색 |
| ScraperAPI | WebFetch (빌트인) | 직접 웹페이지 fetch |
| Browserless | WebFetch (빌트인) | JS 렌더링 필요 시 제한적 |
| YouTube Data API | WebFetch로 페이지 파싱 | 자막은 yt-dlp로 대체 가능 |
| Firecrawl | WebFetch (빌트인) | 페이지 크롤링 |

## 파일 처리 대체

| 유료/외부 서비스 | 무료/빌트인 대체 | 비고 |
|---|---|---|
| Adobe PDF API | Python pdfplumber/PyPDF2 (표준) | pip install로 충분 |
| Cloudinary | 로컬 Pillow/ImageMagick | 이미지 변환 |
| AWS S3 | 로컬 파일시스템 | 스킬 내부 저장 |

## 패키지 경량화

| 무거운 패키지 | 경량 대체 | 비고 |
|---|---|---|
| selenium/playwright | WebFetch (빌트인) | 브라우저 자동화 → 단순 fetch |
| requests + beautifulsoup4 | WebFetch (빌트인) | 스크래핑 |
| langchain | 직접 구현 | LLM 체인은 Claude가 직접 처리 |
| openai (Python SDK) | 불필요 (Claude 빌트인) | LLM 호출 제거 |

## 유료 도구 대체

| 유료 도구 | 무료 대체 | 비고 |
|---|---|---|
| yt-dlp + API 키 | yt-dlp (키 불필요) | YouTube 자막 추출은 키 없이 가능 |
| Notion API | 로컬 Markdown 파일 | Obsidian 등으로 대체 |
| Slack API (유료 플랜) | 빌트인 Slack MCP | MCP 서버 활용 |

## 대체 불가능한 서비스

다음은 빌트인이나 무료로 완전히 대체하기 어려운 서비스:

- **음성 인식/TTS**: Whisper API → 로컬 whisper.cpp로 부분 대체 가능
- **고품질 이미지 생성**: DALL-E, Midjourney → 대체 없음
- **실시간 데이터**: 주식/날씨 등 실시간 데이터 API → WebFetch로 부분 대체
- **데이터베이스 서비스**: Firebase, Supabase → 로컬 SQLite로 부분 대체
