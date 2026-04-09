# /slack-notify

유튜브 영상 요약 결과를 Slack에 알림으로 전송한다.

## 사용법

```
/slack-notify <channel_name> <video_title> <video_url> <summary_json>
```

## 실행 절차

1. 인자 파싱:
   - `channel_name`: 채널 이름 (예: 삼프로TV)
   - `video_title`: 영상 제목
   - `video_url`: 유튜브 URL
   - `summary_json`: `/summarize-video` 가 반환한 JSON 문자열

2. 알림 메시지 포맷 구성:
   ```
   📊 *[채널명] 새 영상 요약*
   
   *제목:* 영상 제목
   🔗 https://...
   
   📝 *요약:*
   요약 내용
   
   🏷️ 키워드: #증시 #시황 ...
   📈 언급 종목: 삼성전자, SK하이닉스
   ```

3. **Slack MCP 확인**: 현재 세션에서 Slack 관련 MCP 도구가 사용 가능한지 확인
   - Slack MCP 도구가 있으면 해당 도구로 메시지 전송
   - 없으면 4번으로 이동

4. **Slack Webhook 방식 (Slack MCP 없을 경우)**:
   - `SLACK_WEBHOOK_URL` 환경변수 확인
   - 환경변수가 없으면 오류 메시지 출력 후 종료:
     ```
     ⚠️ Slack 전송 실패: SLACK_WEBHOOK_URL 환경변수가 설정되지 않았습니다.
     export SLACK_WEBHOOK_URL="https://hooks.slack.com/services/..." 를 설정해주세요.
     ```
   - 환경변수가 있으면 curl로 전송:
     ```bash
     curl -s -X POST "$SLACK_WEBHOOK_URL" \
       -H "Content-Type: application/json" \
       -d '{"text": "메시지 내용"}'
     ```

5. 전송 성공 시: "✅ Slack 알림 전송 완료" 출력
   전송 실패 시: HTTP 상태 코드와 오류 내용 출력

## 주의사항
- 메시지 내 특수문자(`"`, `\` 등)는 JSON 이스케이프 처리
- 요약이 너무 길면 500자로 잘라서 전송
