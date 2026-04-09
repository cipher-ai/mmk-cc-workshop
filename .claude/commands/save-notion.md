# /save-notion

유튜브 영상 요약 결과를 Notion 데이터베이스에 저장한다. Notion MCP를 사용한다.

## 사용법

```
/save-notion <channel_name> <video_title> <video_url> <published_date> <summary_json>
```

## 실행 절차

### 최초 실행: Notion DB 생성

1. `.claude/config/channels.json` 의 `notion_database_id` 값 확인
2. 값이 비어있으면 Notion DB를 새로 생성:
   - `notion-create-database` MCP 도구 사용
   - 적절한 부모 페이지나 워크스페이스에 "📊 한국 증시 유튜브 요약" 데이터베이스 생성
   - 스키마:
     | 컬럼명 | 타입 |
     |--------|------|
     | 제목 | title |
     | 채널 | select |
     | URL | url |
     | 요약 | rich_text |
     | 게시일 | date |
     | 처리일시 | date |
     | 키워드 | multi_select |
     | 언급종목 | multi_select |
     | 감성 | select (긍정/중립/부정) |
   - 생성된 database_id를 `.claude/config/channels.json` 의 `notion_database_id` 에 저장

### 매번 실행: 페이지 저장

3. 인자 파싱:
   - `channel_name`: 채널 이름
   - `video_title`: 영상 제목
   - `video_url`: 유튜브 URL
   - `published_date`: 게시일 (ISO 8601 형식)
   - `summary_json`: `/summarize-video` 가 반환한 JSON

4. `summary_json` 에서 다음 필드 추출:
   - `summary`: 요약 텍스트
   - `keywords`: 키워드 배열
   - `mentioned_stocks`: 언급 종목 배열
   - `sentiment`: 감성 (긍정/중립/부정)

5. `notion-create-pages` MCP 도구로 페이지 생성:
   - 데이터베이스 ID: channels.json의 `notion_database_id`
   - 제목: 영상 제목
   - 채널: channel_name
   - URL: video_url
   - 요약: summary
   - 게시일: published_date
   - 처리일시: 현재 시각 (ISO 8601)
   - 키워드: keywords 배열
   - 언급종목: mentioned_stocks 배열
   - 감성: sentiment

6. 저장 성공 시: "✅ Notion 저장 완료: [페이지 URL]" 출력
   저장 실패 시: 오류 내용 출력

## 주의사항
- Notion MCP 도구(`mcp__*__notion-*`)가 없으면 오류 메시지와 함께 종료
- 요약 텍스트가 2000자를 초과하면 잘라서 저장 (Notion rich_text 제한)
- database_id 저장 후 channels.json 파일 업데이트 필수
