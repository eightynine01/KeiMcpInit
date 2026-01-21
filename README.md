# KeiMcpInit

AI 코딩 에이전트를 위한 공통 지침 시스템

## 빠른 설치 (권장)

```bash
# 아래 명령을 터미널에 복사해서 실행하세요
curl -fsSL https://raw.githubusercontent.com/eightynine01/KeiMcpInit/main/install.sh | bash
```

> **ℹ️ LLM에게 이렇게 요청하세요:**
> "KeiMcpInit를 설치해줘. `curl -fsSL https://raw.githubusercontent.com/eightynine01/KeiMcpInit/main/install.sh | bash` 명령을 실행해줘."

## AI Agent 자동 설치

Claude Code, Cursor, Windsurf 등에서 아래 블록을 **그대로 복사하여 붙여넣기**:

---

### LLM에게 이렇게 요청하세요 (권장):

```
KeiMcpInit를 설치해줘. 다음 명령을 순서대로 실행해줘:

1. MCP 도구 설치 확인:
   claude mcp list | grep -q context7 || claude mcp add context7 -- npx -y @upstash/context7-mcp

2. KeiMcpInit 설치:
   git submodule add git@github.com:eightynine01/KeiMcpInit.git .agents 2>/dev/null || \
   git submodule add https://github.com/eightynine01/KeiMcpInit.git .agents
   .agents/scripts/setup-agents.sh --setup

3. 설치 결과 커밋:
   git add .gitmodules .agents AGENTS.md CLAUDE.md .cursorrules .windsurfrules .clinerules
   git add .github/copilot-instructions.md .amazon-q/ .codex/ .aider.conf.yml .continue/
   git commit -m "feat: KeiMcpInit 추가"

4. 설치 완료 후 다음을 확인해줘:
   - MCP 도구 상태
   - 심볼릭 링크 생성 여부
   - 커밋 성공 여부
```

### 단계별 설명

**1. MCP 도구 설치 확인**
```bash
claude mcp list | grep -q context7 || claude mcp add context7 -- npx -y @upstash/context7-mcp
```
- context7 (라이브러리 문서 참조 도구)가 설치되어 있는지 확인
- 없으면 자동으로 설치

**2. KeiMcpInit 설치**
```bash
git submodule add git@github.com:eightynine01/KeiMcpInit.git .agents 2>/dev/null || \
git submodule add https://github.com/eightynine01/KeiMcpInit.git .agents
.agents/scripts/setup-agents.sh --setup
```
- GitHub submodule로 KeiMcpInit 추가
- SSH 실패 시 HTTPS로 자동 재시도
- 심볼릭 링크 자동 설정

**3. 설치 결과 커밋**
```bash
git add .gitmodules .agents AGENTS.md CLAUDE.md .cursorrules .windsurfrules .clinerules
git add .github/copilot-instructions.md .amazon-q/ .codex/ .aider.conf.yml .continue/
git commit -m "feat: KeiMcpInit 추가"
```
- 모든 관련 파일 스테이징
- 설치 완료 커밋 생성

**4. 설치 완료 보고**
- MCP 도구 상태 확인
- 심볼릭 링크 생성 여부 확인
- 커밋 성공 여부 확인

---

## 수동 설치

```bash
# 1. Submodule 추가
git submodule add git@github.com:eightynine01/KeiMcpInit.git .agents

# 2. 심볼릭 링크 설정
.agents/scripts/setup-agents.sh --setup

# 3. 커밋
git add .gitmodules .agents AGENTS.md CLAUDE.md .cursorrules .windsurfrules .clinerules
git add .github/copilot-instructions.md .amazon-q/ .codex/ .aider.conf.yml .continue/
git commit -m "feat: KeiMcpInit 추가"
```

## MCP 도구 설치

```bash
# context7 (라이브러리 문서 참조)
claude mcp add context7 -- npx -y @upstash/context7-mcp

# keimcp (인프라 관리 - 토큰 필요)
claude mcp add keimcp --transport sse \
  --url https://mcp.keiailab.dev/sse \
  --header "Authorization: Bearer <TOKEN>"
```

## 업데이트

```bash
# .agents 서브모듈 업데이트
cd .agents && git pull origin main && cd ..
git add .agents && git commit -m "chore: KeiMcpInit 업데이트"
```

## 자주 묻는 질문 (FAQ)

### Q: 설치 스크립트의 옵션은 무엇인가요?

```bash
# Vault 연결 확인 스킵
curl -fsSL https://raw.githubusercontent.com/eightynine01/KeiMcpInit/main/install.sh | bash -s -- --skip-vault

# MCP 도구 확인 스킵
curl -fsSL https://raw.githubusercontent.com/eightynine01/KeiMcpInit/main/install.sh | bash -s -- --skip-mcp

# 모든 옵션 확인
curl -fsSL https://raw.githubusercontent.com/eightynine01/KeiMcpInit/main/install.sh | bash -s -- --help
```

### Q: 심볼릭 링크가 생성되지 않아요

**해결 방법:**
```bash
# 수동으로 심볼릭 링크 생성
.agents/scripts/setup-agents.sh --setup

# 생성된 링크 확인
ls -la AGENTS.md CLAUDE.md .cursorrules .windsurfrules .clinerules
```

### Q: MCP 도구가 설치되지 않아요

**Claude Code:**
```bash
# context7 설치
claude mcp add context7 -- npx -y @upstash/context7-mcp

# 설치 확인
claude mcp list
```

**Claude Desktop:**
- 설정 파일: `~/Library/Application Support/Claude/claude_desktop_config.json`
- 다음을 추가:
```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"]
    }
  }
}
```

### Q: git submodule이 제대로 업데이트되지 않아요

**해결 방법:**
```bash
# 서브모듈 초기화
git submodule update --init --recursive

# 최신 버전으로 업데이트
cd .agents
git fetch origin
git checkout main
git pull origin main
cd ..
```

### Q: keimcp 토큰이 필요한데 어디서 얻나요?

**해결 방법:**
```bash
# keimcp가 이미 설치된 경우
claude mcp list | grep keimcp

# LLM에게 요청:
"keimcp의 api_key_list() 도구를 사용해서 현재 API Key 목록을 조회해줘."
```

## 지원되는 AI 플랫폼

- ✅ **Claude Code**: 완전 지원
- ✅ **Claude Desktop**: 완전 지원
- ✅ **Cursor**: 완전 지원
- ✅ **Windsurf**: 완전 지원
- ✅ **Codex**: 완전 지원
- ✅ **Gemini CLI**: 완전 지원
- ✅ **OpenCode**: 완전 지원

## 문제 해결

### 설치 실패시

1. **git 저장소 확인**
   ```bash
   git status
   ```
   현재 디렉토리가 git 저장소인지 확인

2. **서브모듈 상태 확인**
   ```bash
   git submodule status
   ```

3. **심볼릭 링크 확인**
   ```bash
   ls -la | grep AGENTS.md
   ```

4. **MCP 도구 확인**
   ```bash
   claude mcp list
   ```

### MCP 도구가 작동하지 않을 때

1. **MCP 서버 재시작** (Claude Code)
   ```bash
   claude mcp restart
   ```

2. **로그 확인**
   ```bash
   claude mcp logs context7
   ```

3. **MCP 도구 재설치**
   ```bash
   claude mcp remove context7
   claude mcp add context7 -- npx -y @upstash/context7-mcp
   ```

## 기여하기

버그 리포트, 기능 요청, Pull Request를 환영합니다!

1. Fork하세요
2. feature 브랜치 생성 (`git checkout -b feature/AmazingFeature`)
3. 커밋 (`git commit -m 'feat: Add AmazingFeature'`)
4. 브랜치 푸시 (`git push origin feature/AmazingFeature`)
5. Pull Request 생성

## 라이선스

MIT License

## 연락처

GitHub: [eightynine01](https://github.com/eightynine01)

