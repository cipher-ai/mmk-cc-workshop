# /youtube-fetch

채널 설정 파일을 읽어 유튜브 RSS 피드에서 최신 영상을 수집하고, 키워드 필터링 후 처리되지 않은 새 영상 목록을 반환한다.

## 실행 절차

1. `.claude/config/channels.json` 파일을 읽어 채널 목록과 설정 로드

2. 각 채널에 대해 YouTube RSS 피드 수집:
   ```bash
   curl -s "https://www.youtube.com/feeds/videos.xml?channel_id=CHANNEL_ID"
   ```

3. 아래 Python 스크립트로 RSS XML 파싱 (python3 사용):
   ```python
   import xml.etree.ElementTree as ET
   import sys, json

   xml_text = sys.stdin.read()
   root = ET.fromstring(xml_text)
   ns = {
       'atom': 'http://www.w3.org/2005/Atom',
       'yt': 'http://www.youtube.com/xml/schemas/2015',
       'media': 'http://search.yahoo.com/mrss/'
   }
   videos = []
   for entry in root.findall('atom:entry', ns):
       video_id = entry.find('yt:videoId', ns).text
       title = entry.find('atom:title', ns).text
       link = entry.find('atom:link', ns).get('href')
       published = entry.find('atom:published', ns).text
       videos.append({'video_id': video_id, 'title': title, 'url': link, 'published': published})
   print(json.dumps(videos[:5]))
   ```

4. 각 영상에 대해 필터링:
   - 제목에 채널의 `keywords` 중 하나 이상 포함 여부 확인
   - `.claude/state/processed-videos.txt`에서 이미 처리된 video_id 확인 → 건너뜀
   - `mmk youtube videotype <url>` 실행 → "short" 이면 건너뜀 (일반 영상만 처리)

5. 결과를 다음 형식의 JSON으로 출력:
   ```json
   [
     {
       "channel_name": "삼프로TV",
       "video_id": "xxxxxxxxxxx",
       "title": "영상 제목",
       "url": "https://www.youtube.com/watch?v=xxxxxxxxxxx",
       "published": "2024-01-01T00:00:00+00:00"
     }
   ]
   ```

6. 새 영상이 없으면 "새 영상 없음"을 출력하고 종료

## 주의사항
- `max_videos_per_channel` 설정값(기본 5)만큼만 확인
- channel_id가 실제와 다를 경우 RSS 피드가 비어있을 수 있음 → 오류 메시지 출력 후 다음 채널로 계속
- Short 판별 실패 시 일반 영상으로 간주하고 계속 진행
