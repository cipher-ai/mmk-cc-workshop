# /slack-notify

유튜브 영상 요약 결과를 Slack `#cc-workshop` 채널에 알림으로 전송한다.

## Slack 채널 정보

- **채널**: `#cc-workshop`
- **전송 방식**: Slack MCP (우선) → Incoming Webhook (대안)

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

2. `summary_json` 에서 필드 추출:
   - `summary`: 요약 텍스트 (500자 초과 시 잘라서 사용)
   - `keywords`: 키워드 배열
   - `mentioned_stocks`: 언급 종목 배열

3. 알림 메시지 포맷 구성:
   ```
   📊 *[채널명] 새 영상 요약*

   *제목:* 영상 제목
   🔗 https://...

   📝 *요약:*
   요약 내용

   🏷️ 키워드: #증시 #시황 ...
   📈 언급 종목: 삼성전자, SK하이닉스
   ```

4. **Slack MCP 확인**: 현재 세션에서 Slack 관련 MCP 도구가 사용 가능한지 확인
   - Slack MCP 도구가 있으면 채널 `#cc-workshop` 에 메시지 전송
   - 없으면 5번으로 이동

5. **Slack Webhook 방식 (Slack MCP 없을 경우)**:
   - `SLACK_WEBHOOK_URL` 환경변수 확인
   - 없으면 오류 메시지 출력:
     ```
     ⚠️ Slack 전송 실패: SLACK_WEBHOOK_URL 환경변수가 없습니다.
     Slack 앱 설정에서 #cc-workshop 채널용 Incoming Webhook URL을 생성 후:
     export SLACK_WEBHOOK_URL="https://hooks.slack.com/services/..."
     ```
   - 있으면 curl로 전송:
     ```bash
     curl -s -X POST "$SLACK_WEBHOOK_URL" \
       -H "Content-Type: application/json" \
       -d "{\"channel\": \"#cc-workshop\", \"text\": \"메시지\"}"
     ```

6. 전송 성공: `✅ Slack #cc-workshop 알림 전송 완료`
   전송 실패: HTTP 상태 코드와 오류 내용 출력

## 주의사항
- 메시지 내 `"`, `\`, 개행 문자는 JSON 이스케이프 처리
- 요약은 500자로 제한
