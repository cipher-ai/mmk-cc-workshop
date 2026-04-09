# /stock-monitor

한국 증시 유튜브 채널을 모니터링하여 새 영상을 감지하고, 자막 요약 → Slack 알림 → Notion 저장 파이프라인을 실행한다.

`/loop 1h /stock-monitor` 로 1시간마다 자동 실행된다.

## 실행 절차

### 1단계: 준비

1. 현재 시각 출력: `🕐 모니터링 시작: YYYY-MM-DD HH:MM`
2. `.claude/config/channels.json` 파일이 존재하는지 확인
   - 없으면 오류 메시지 출력 후 종료

### 2단계: 새 영상 수집

3. `/youtube-fetch` 실행하여 새 영상 목록 가져오기
   - 새 영상이 없으면: "✅ 새 영상 없음. 다음 실행 대기 중..." 출력 후 종료

### 3단계: 영상별 파이프라인 실행

4. 새 영상 목록의 각 영상에 대해 순서대로 처리:

   ```
   처리 중: [채널명] 영상 제목 (N/전체)
   ```

   a. **자막 추출 & 요약**:
      - `/summarize-video <video_url>` 실행
      - 실패 시: 해당 영상 건너뜀, 오류 로그 출력 후 다음 영상으로 계속
      - 성공 시: summary_json 보관

   b. **Slack 알림**:
      - `/slack-notify <channel_name> <video_title> <video_url> <summary_json>` 실행
      - 실패해도 다음 단계 계속 진행 (알림 실패가 전체를 중단하면 안 됨)

   c. **Notion 저장**:
      - `/save-notion <channel_name> <video_title> <video_url> <published_date> <summary_json>` 실행
      - 실패해도 다음 단계 계속 진행

   d. **처리 완료 기록**:
      - `video_id`를 `.claude/state/processed-videos.txt` 에 한 줄 추가
      - 파일이 1000줄을 초과하면 가장 오래된 200줄 삭제 (파일 크기 관리)

### 4단계: 완료 요약

5. 실행 결과 요약 출력:
   ```
   ━━━━━━━━━━━━━━━━━━━━━━━━
   📊 모니터링 완료 요약
   ━━━━━━━━━━━━━━━━━━━━━━━━
   🔍 확인한 채널: N개
   📹 새 영상 발견: N개
   ✅ 성공적으로 처리: N개
   ⚠️  처리 실패: N개
   ⏰ 다음 실행: 1시간 후
   ━━━━━━━━━━━━━━━━━━━━━━━━
   ```

## 스케줄 실행

이 스킬은 아래 명령어로 1시간마다 자동 반복 실행된다:
```
/loop 1h /stock-monitor
```

## 주의사항
- 각 단계의 실패가 전체 파이프라인을 중단시키면 안 됨 (fail-safe 방식)
- Notion DB가 아직 없으면 `/save-notion` 이 최초 실행 시 자동 생성
- `channels.json` 의 `channel_id` 가 잘못되면 `/youtube-fetch` 에서 경고 출력
