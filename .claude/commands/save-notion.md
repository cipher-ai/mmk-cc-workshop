# /save-notion

유튜브 영상 요약 결과를 Notion 데이터베이스에 저장한다. Notion MCP를 사용한다.

## Notion DB 정보

- **데이터베이스 URL**: https://www.notion.so/a82f06fb97f74f629210db8a24ad8b82
- **데이터소스 ID**: `collection://034f1f36-6e8c-4a7e-8746-fde0aef38a91`
- **부모 페이지**: cc-workshop (https://www.notion.so/33db64d8b15a806bb526d52a5113190d)

## 사용법

```
/save-notion <channel_name> <video_title> <video_url> <published_date> <summary_json>
```

## 실행 절차

1. 인자 파싱:
   - `channel_name`: 채널 이름 (예: 삼프로TV)
   - `video_title`: 영상 제목
   - `video_url`: 유튜브 URL
   - `published_date`: 게시일 (ISO 8601 형식, 예: 2024-01-15)
   - `summary_json`: `/summarize-video` 가 반환한 JSON

2. `summary_json` 에서 다음 필드 추출:
   - `summary`: 요약 텍스트
   - `keywords`: 키워드 배열 (예: ["증시", "시황"])
   - `mentioned_stocks`: 언급 종목 배열 (예: ["삼성전자", "SK하이닉스"])
   - `sentiment`: 감성 (긍정/중립/부정)

3. `notion-create-pages` MCP 도구로 페이지 생성:

   다음 속성으로 페이지를 생성한다:
   - **데이터베이스**: `https://www.notion.so/a82f06fb97f74f629210db8a24ad8b82`
   - **제목** (title): 영상 제목
   - **채널** (select): channel_name — "삼프로TV", "한국경제TV", 그 외는 "기타"
   - **URL** (url): video_url
   - **요약** (rich_text): summary 텍스트 (2000자 초과 시 잘라서 저장)
   - **게시일** (date): `date:게시일:start` = published_date
   - **처리일시** (date): `date:처리일시:start` = 현재 시각 (ISO 8601)
   - **키워드** (multi_select): keywords 배열의 각 항목
   - **언급종목** (multi_select): mentioned_stocks 배열의 각 항목
   - **감성** (select): sentiment

4. 저장 성공 시: `✅ Notion 저장 완료: [생성된 페이지 URL]` 출력
   저장 실패 시: 오류 내용 출력

## 채널 이름 매핑
- "삼프로TV" → select: 삼프로TV
- "한국경제TV" → select: 한국경제TV
- 그 외 → select: 기타

## 주의사항
- Notion MCP 도구(`mcp__*__notion-create-pages`)가 없으면 오류 메시지와 함께 종료
- 요약 텍스트가 2000자를 초과하면 잘라서 저장
- 키워드/언급종목의 새 값은 Notion이 자동으로 옵션에 추가함
