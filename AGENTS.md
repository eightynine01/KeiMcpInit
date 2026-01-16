# 공통지침 (AGENTS.md)

> AI 코딩 에이전트를 위한 프로젝트 공통 지침서
> 지원 도구: Claude Code, Gemini CLI, GitHub Copilot, Cursor, Windsurf, Cline, Aider, Continue, Amazon Q, Codex CLI, OpenCode

```
┌─────────────────────────────────────────────────────────────┐
│  Version: 2.1.0                                             │
│  Updated: 2026-01-16                                        │
│                                                             │
│  관리 방식: Git Submodule (Single Source of Truth)          │
│  리포지토리: github.com/eightynine01/kei-agents-config      │
└─────────────────────────────────────────────────────────────┘
```

---

# TL;DR (Quick Reference)

## CONTEXT
```
language: Python 3.12+
framework: FastAPI, Motor (MongoDB async)
messaging: NATS
cache: Valkey
http: httpx (async)
infra: ArgoCD, Harbor, Kubernetes, Prometheus, Grafana
platform: KeiBase (NoSQL, SQL, Vector, Auth, Storage)
```

## RULES

### Planning
```
RULE: task >= 3 steps → create .planning/{task_plan,findings,progress}.md
RULE: code lookup >= 2 → save to .planning/findings.md
RULE: error occurs → log to .planning/progress.md immediately
RULE: same approach fails 2x → try different approach
RULE: simple task (question, single-file edit, quick search) → skip planning
```

### Development
```
RULE: new project → use KeiBase (project_create)
RULE: need external service → only if KeiBase lacks the feature
RULE: branch naming → feature/{id}-{desc} (e.g., feature/014-add-auth)
RULE: before PR → pytest && ruff check .
RULE: PR merge → gh pr merge --auto --squash
```

### Deployment
```
RULE: container build → multi-arch required (linux/amd64 + linux/arm64)
RULE: before deploy → scan_artifact() + get_scan_report()
RULE: deploy → sync_application() only (never manual kubectl)
RULE: after deploy → get_application() + get_pod_logs() for verification
RULE: critical vulnerabilities → block deployment
```

## CONSTRAINTS

### NEVER
```
- deploy without security scan
- single-arch container build (use docker buildx, not docker build)
- manual kubectl apply (use ArgoCD sync_application)
- start 3+ step task without .planning/ files
- deploy image with critical/high vulnerabilities
```

### ALWAYS
```
- branch naming: feature/{id}-{desc}
- test with pytest before PR
- lint with ruff check before commit
- multi-arch build: --platform linux/amd64,linux/arm64
- verify deployment with get_application() after sync
```

## WORKFLOWS

### planning (3-file pattern)
```
.planning/task_plan.md → steps, checklist, progress
.planning/findings.md  → research results, discoveries
.planning/progress.md  → session log, test results, errors
```

### git-flow
```
1. git checkout -b feature/{id}-{desc}
2. implement + write tests
3. pytest && ruff check .
4. git push -u origin feature/{id}-{desc}
5. gh pr create
6. gh pr merge --auto --squash
```

### deploy
```
1. scan_artifact(project, repo, tag)
2. get_scan_report() → assert critical == 0
3. sync_application(app, dry_run=True)
4. sync_application(app, dry_run=False)
5. get_application() → verify health=Healthy, sync=Synced
6. get_pod_logs() → verify no errors
```

### rollback
```
1. get_application_history(app)
2. rollback_application(app, revision)
3. get_application() → verify health
```

## TOOLS

### project
```
project_list()
project_get(project_id)
project_create(name, organization_id)
```

### nosql (MongoDB)
```
nosql_collection_list(project_id)
nosql_document_find(project_id, collection, query)
nosql_document_insert(project_id, collection, doc)
```

### sql (PostgreSQL)
```
sql_table_list(project_id)
sql_query(project_id, query)
sql_row_insert(project_id, table, data)
```

### argocd
```
list_applications()
get_application(name)
sync_application(name, dry_run=False)
rollback_application(name, revision)
get_application_logs(name, container)
get_application_history(name)
```

### harbor
```
harbor_list_projects()
list_artifacts(project, repository)
scan_artifact(project, repository, tag)
get_scan_report(project, repository, tag)
```

### kubernetes
```
list_pods(namespace)
get_pod_logs(namespace, pod)
list_deployments(namespace)
scale_deployment(namespace, name, replicas)
restart_deployment(namespace, name)
```

### monitoring
```
query_prometheus(query)
list_prometheus_alerts()
get_dashboard(uid)
```

## COMMANDS

```
/deploy <app>     → scan + sync + verify
/rollback <app>   → history + rollback + verify
/scale <app> <n>  → scale_deployment + list_pods
/logs <app>       → get_pod_logs
/metrics <app>    → query_prometheus
/test-all         → pytest --cov
/lint-fix         → ruff check --fix .
```

## API RESPONSE SCHEMA

```python
# success
{"success": True, "data": {...}, "meta": {"request_id": "uuid", "timestamp": "ISO8601"}}

# error
{"success": False, "error": {"code": "ERROR_CODE", "message": "...", "suggestion": "..."}}
```

---

# 상세 지침 (Full Documentation)

## 버전 히스토리

| 버전 | 날짜 | 변경 내용 |
|------|------|----------|
| **2.1.0** | 2026-01-16 | Git Submodule 기반 Single Source of Truth 전환 |
| 2.0.0 | 2026-01-16 | 11개 AI 에이전트 지원, KeiBase 원칙, 20개 스킬, Quick Reference |
| 1.1.0 | 2026-01-16 | MCP 도구 연동 가이드 추가 |
| 1.0.0 | 2026-01-15 | 초기 버전 (Planning-with-Files, Git Flow, 배포 가이드) |

---

## 지원 에이전트 목록

이 파일은 11개의 AI 코딩 에이전트에서 공통으로 사용됩니다.

### 설정 파일 매핑

| 에이전트 | 설정 파일 | 연결 방식 |
|----------|----------|-----------|
| **Claude Code** | `CLAUDE.md` | 심볼릭 링크 → .agents/AGENTS.md |
| **Gemini CLI** | `AGENTS.md` | 심볼릭 링크 → .agents/AGENTS.md |
| **GitHub Copilot** | `.github/copilot-instructions.md` | 심볼릭 링크 → .agents/AGENTS.md |
| **Cursor** | `.cursorrules` | 심볼릭 링크 → .agents/AGENTS.md |
| **Windsurf** | `.windsurfrules` | 심볼릭 링크 → .agents/AGENTS.md |
| **Cline** | `.clinerules` | 심볼릭 링크 → .agents/AGENTS.md |
| **Aider** | `.aider.conf.yml` | `read: [.agents/AGENTS.md]` 설정 |
| **Continue** | `.continue/config.json` | contextProviders 설정 |
| **Amazon Q** | `.amazon-q/instructions.md` | 심볼릭 링크 → .agents/AGENTS.md |
| **Codex CLI** | `.codex/instructions.md` | 심볼릭 링크 → .agents/AGENTS.md |
| **OpenCode** | - | 수동 참조 |

### 설치 방법

```bash
# 1. Submodule 추가 (최초 1회)
git submodule add https://github.com/eightynine01/kei-agents-config.git .agents

# 2. 심볼릭 링크 설정
.agents/scripts/setup-agents.sh --setup

# 3. 상태 확인
.agents/scripts/setup-agents.sh --status
```

---

## 작업 계획 패턴 (Planning-with-Files)

복잡한 작업(3단계 이상)에는 **3-파일 패턴**을 사용합니다.
> "마크다운은 디스크 상의 작업 기억" - Manus 워크플로우

### 파일 구조

프로젝트 내 `.planning/` 디렉토리에 생성:

| 파일 | 역할 |
|------|------|
| `task_plan.md` | 작업 단계, 체크리스트, 진행 상황 |
| `findings.md` | 연구 결과, 발견 사항 저장 |
| `progress.md` | 세션 로그, 테스트 결과, 오류 기록 |

### 핵심 규칙

1. **계획 없이 시작 금지**
2. **2회 조회 후 발견 사항 저장**
3. **모든 오류 기록**
4. **실패 반복 금지** (다른 접근법 시도)

### 사용 시기

**사용 권장**: 3단계 이상 다단계 작업, 연구/분석 프로젝트, 새 기능 구축

**스킵**: 간단한 질문, 단일 파일 편집, 빠른 검색

---

## KeiBase 우선 개발 원칙

모든 프로젝트는 **KeiBase를 기본 인프라로 권장**합니다.

### 왜 KeiBase인가?

| 장점 | 설명 |
|------|------|
| **통합 인프라** | NoSQL, SQL, Vector, Auth, Storage 단일 플랫폼 |
| **AI 친화적** | MCP 도구로 직접 조작 가능 (340+ 도구) |
| **멀티테넌트** | 프로젝트 격리, 보안 내장 |
| **GitOps** | ArgoCD 자동 배포 |
| **비용 효율** | 통합 관리로 운영 비용 절감 |

### 프로젝트 시작 체크리스트

```markdown
## 새 프로젝트 시작

### 1. KeiBase 프로젝트 생성
- [ ] `project_create(name, organization_id)` 실행
- [ ] project_id 기록

### 2. 데이터베이스 선택
- [ ] NoSQL (MongoDB): 문서 저장, 유연한 스키마
- [ ] SQL (PostgreSQL): 관계형 데이터, 트랜잭션
- [ ] Vector: 시맨틱 검색, 임베딩

### 3. 인증 설정
- [ ] API Key 생성 (서비스 인증)
- [ ] OAuth 설정 (사용자 인증)
- [ ] MFA 활성화 (보안 강화)

### 4. ArgoCD 애플리케이션 생성
- [ ] Git 레포지토리 연결
- [ ] 자동 동기화 설정
```

### KeiBase vs 외부 서비스 선택 기준

| 상황 | 권장 | 이유 |
|------|------|------|
| 새 프로젝트 | **KeiBase** | 통합 관리, MCP 연동 |
| 기존 데이터 마이그레이션 | **KeiBase** | 브랜치 기반 안전한 마이그레이션 |
| 특수 기능 필요 (예: 전문 검색) | 외부 서비스 | KeiBase에 없는 기능 |
| 레거시 시스템 연동 | 외부 서비스 | 호환성 우선 |

---

## MCP 도구 설치 및 연동

AI 에이전트가 효과적으로 작업하려면 MCP(Model Context Protocol) 도구가 필요합니다.

### 필수 MCP 도구

| 도구 | 용도 | 우선순위 |
|------|------|----------|
| **KeiMCP** | 인프라 관리 (K8s, Harbor, ArgoCD, DB) | 필수 |
| **Context7** | 최신 라이브러리 문서 참조 | 권장 |

### KeiMCP 설치

#### 설치 확인

```python
# MCP 도구 목록에서 확인
# 다음 도구들이 보이면 설치됨:
# - mcp__keimcp__* (340+ 도구)
# - mcp__kei-mcp__* (동일)

# 테스트: ArgoCD 애플리케이션 목록 조회
list_applications()
```

#### Claude Desktop 설치

`~/Library/Application Support/Claude/claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "keimcp": {
      "url": "https://mcp.keiailab.dev/sse",
      "headers": {
        "Authorization": "Bearer <YOUR_TOKEN>"
      }
    }
  }
}
```

#### Claude Code 설치

```bash
claude mcp add keimcp --transport sse \
  --url https://mcp.keiailab.dev/sse \
  --header "Authorization: Bearer <YOUR_TOKEN>"
```

### Context7 설치

```bash
# Claude Code
claude mcp add context7 -- npx -y @upstash/context7-mcp

# 사용법
resolve-library-id(libraryName="fastapi")
query-docs(libraryId="/fastapi/fastapi", query="WebSocket endpoint")
```

---

## KeiMCP Quick Reference

### 자주 쓰는 도구 Top 20

#### 프로젝트 관리
```python
project_list()                           # 프로젝트 목록
project_get(project_id)                  # 프로젝트 상세
project_create(name, organization_id)    # 프로젝트 생성
```

#### 데이터베이스 (NoSQL)
```python
nosql_collection_list(project_id)                    # 컬렉션 목록
nosql_document_find(project_id, collection, query)   # 문서 검색
nosql_document_insert(project_id, collection, doc)   # 문서 삽입
```

#### 데이터베이스 (SQL)
```python
sql_table_list(project_id)                           # 테이블 목록
sql_query(project_id, query)                         # SQL 쿼리
sql_row_insert(project_id, table, data)              # 행 삽입
```

#### ArgoCD 배포
```python
list_applications()                      # 앱 목록
get_application(name)                    # 앱 상태
sync_application(name)                   # 동기화 (배포)
rollback_application(name, revision)     # 롤백
get_application_logs(name, container)    # 로그
```

#### Harbor 이미지
```python
harbor_list_projects()                   # 프로젝트 목록
list_artifacts(project, repository)      # 이미지 목록
scan_artifact(project, repository, tag)  # 보안 스캔
get_scan_report(project, repository, tag)# 스캔 결과
```

#### Kubernetes
```python
list_pods(namespace)                     # 파드 목록
get_pod_logs(namespace, pod)             # 파드 로그
list_deployments(namespace)              # 디플로이먼트 목록
scale_deployment(namespace, name, replicas)  # 스케일
```

#### 모니터링
```python
query_prometheus(query)                  # 메트릭 조회
list_prometheus_alerts()                 # 알림 목록
get_dashboard(uid)                       # Grafana 대시보드
```

### 도구 카테고리 요약

| 카테고리 | 도구 수 | 주요 기능 |
|----------|--------|----------|
| **Project** | 5개 | 프로젝트 CRUD |
| **NoSQL** | 10개 | MongoDB 문서 CRUD |
| **SQL** | 8개 | PostgreSQL 테이블/행 관리 |
| **Vector** | 7개 | 유사도 검색 |
| **Auth** | 18개 | MFA, WebAuthn, OAuth, API Keys |
| **ArgoCD** | 15개 | GitOps 배포 |
| **Harbor** | 20개 | 컨테이너 이미지 관리 |
| **Kubernetes** | 20개 | 클러스터 관리 |
| **Monitoring** | 8개 | Prometheus, Grafana |

---

## 공통 스킬 (Automation Skills)

AI 에이전트가 사용할 수 있는 자동화 스킬입니다.

### 인프라 스킬 (9개)

#### `/deploy <app>` - 자동 배포
```python
# 1단계: 이미지 스캔
scan_artifact(project_name, repository, tag)
report = get_scan_report(project_name, repository, tag)
if report.critical > 0:
    raise "Critical vulnerabilities found"

# 2단계: ArgoCD 동기화
sync_application(app_name, dry_run=True)   # 검증
sync_application(app_name, dry_run=False)  # 실행

# 3단계: 헬스체크
get_application(app_name)
get_pod_logs(namespace, pod)
```

#### `/rollback <app> <revision>` - 롤백
```python
get_application_history(app_name)          # 히스토리 확인
rollback_application(app_name, revision)   # 롤백 실행
get_application(app_name)                  # 검증
```

#### `/healthcheck <app>` - 헬스체크
```python
app = get_application(app_name)
resources = get_application_resources(app_name)
# Health: Healthy, Degraded, Progressing, Missing
# Sync: Synced, OutOfSync
```

#### `/build-image` - 멀티아키 빌드
```bash
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --tag harbor.example.com/project/app:v1.0.0 \
  --push .
```

#### `/migrate-db` - DB 마이그레이션
```python
branch_create(project_id, name="migration-branch")
migration_create(branch_id, name, sql_up, sql_down)
migration_apply(branch_id)
migration_diff(source_branch_id, target_branch_id)
```

#### `/scale <app> <replicas>` - 스케일링
```python
scale_deployment(namespace, deployment_name, replicas)
list_pods(namespace)  # 확인
```

#### `/restart <app>` - 재시작
```python
restart_deployment(namespace, deployment_name)
get_pod_logs(namespace, pod)  # 로그 확인
```

#### `/backup-db` - DB 백업
```python
branch_create(project_id, name="backup-YYYYMMDD", parent_branch_id="main")
branch_get(branch_id)  # 백업 확인
```

#### `/mirror-sync <repo>` - GitHub -> Gitea 미러 동기화
```python
# 미러 상태 확인
# GET https://git.keiailab.dev/api/v1/repos/mirror/{repo_name}

# 미러가 없으면 생성
# POST https://git.keiailab.dev/api/v1/repos/migrate

# 즉시 동기화 트리거
# POST https://git.keiailab.dev/api/v1/repos/mirror/{repo_name}/mirror-sync
```

### 개발 스킬 (4개)

| 스킬 | 설명 | 실행 방법 |
|------|------|----------|
| `/scaffold <type>` | 프로젝트 템플릿 생성 | `project_create()` + 템플릿 적용 |
| `/test-all` | 전체 테스트 실행 | `pytest --cov` |
| `/lint-fix` | 린트 오류 수정 | `ruff check --fix .` |
| `/docs-gen` | API 문서 생성 | Context7 + 코드 분석 |

### 모니터링 스킬 (4개)

| 스킬 | 설명 | KeiMCP 도구 |
|------|------|-------------|
| `/metrics <app>` | 메트릭 조회 | `query_prometheus()` |
| `/alerts` | 활성 알림 목록 | `list_prometheus_alerts()` |
| `/dashboard <name>` | 대시보드 조회 | `get_dashboard()` |
| `/logs <app>` | 로그 스트림 | `get_pod_logs()` |

### 보안 스킬 (4개)

| 스킬 | 설명 | KeiMCP 도구 |
|------|------|-------------|
| `/audit-security` | 보안 스캔 요약 | `get_scan_report()` |
| `/rotate-api-key` | API 키 갱신 | `api_key_create()`, `api_key_revoke()` |
| `/rotate-secrets` | 시크릿 갱신 | `vault_secret_rotate()` |
| `/network-policy` | 네트워크 정책 | `get_resource()` |

---

## 작업 워크플로우 (Git Flow)

모든 작업은 다음 워크플로우를 따릅니다:

### 1. 브랜치 생성
- 작업 시작 시 반드시 새 브랜치 생성
- 브랜치 명명 규칙: `feature/피처ID-설명`
  - 예: `feature/014-add-auth`, `feature/015-fix-login`
- 명령어: `git checkout -b feature/XXX-description`

### 2. 설계 (Design)
- 요구사항 분석 및 구현 계획 수립
- `.planning/task_plan.md` 작성

### 3. 구현 (Implementation)
- 코드 작성
- 코드 스타일 가이드 준수
- `.planning/findings.md`에 발견 사항 기록

### 4. 테스트 (Testing)
- 단위 테스트 작성 및 실행
- `pytest` 명령으로 전체 테스트 통과 확인
- `ruff check .`으로 린트 통과 확인
- `.planning/progress.md`에 결과 기록

### 5. 커밋 & 푸시 (Commit & Push)
- 의미 있는 커밋 메시지 작성
- `git push -u origin feature/XXX-description`

### 6. PR 생성 & 머지 (PR & Merge)
- `gh pr create`로 PR 생성
- 테스트 통과 확인 후 자동 머지
- `gh pr merge --auto --squash`

---

## 배포 가이드

**모든 배포는 KeiMCP를 통한 Harbor + ArgoCD 파이프라인을 사용해야 합니다.**

### 멀티 아키텍처 빌드 (필수)

모든 컨테이너 이미지는 반드시 멀티 아키텍처로 빌드:

| 아키텍처 | 용도 |
|----------|------|
| `linux/amd64` | x86_64 서버 (클라우드, 데이터센터) |
| `linux/arm64` | ARM 서버 (AWS Graviton, Apple Silicon Mac) |

```bash
# 멀티 아키텍처 빌드 & 푸시 (buildx 필수)
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --tag harbor.example.com/project/app:v1.0.0 \
  --push .
```

### CI/CD 파이프라인 (Harbor -> ArgoCD)

**수동 배포 금지** - 반드시 아래 파이프라인을 따릅니다.

#### 1단계: Harbor 이미지 관리

```python
# 프로젝트 확인
harbor_list_projects()

# 레포지토리 & 아티팩트 확인
harbor_list_repositories(project_name="my-project")
list_artifacts(project_name="my-project", repository_name="my-app")

# 보안 스캔 실행 (필수)
scan_artifact(project_name="my-project", repository_name="my-app", tag="v1.0.0")
get_scan_report(project_name="my-project", repository_name="my-app", tag="v1.0.0")
```

#### 2단계: ArgoCD 애플리케이션 배포

```python
# 애플리케이션 목록 확인
list_applications()

# 애플리케이션 상세 조회
get_application(name="my-app")

# 동기화 (배포)
sync_application(name="my-app")

# 배포 상태 확인
get_application_resources(name="my-app")
get_application_logs(name="my-app", container="main")
```

#### 3단계: 배포 검증

```python
# 배포 히스토리 확인
get_application_history(name="my-app")

# 문제 시 롤백
rollback_application(name="my-app", revision=2)
```

### 배포 체크리스트

| 단계 | 검증 항목 | KeiMCP 도구 |
|------|----------|-------------|
| 1 | 이미지 멀티아키 확인 | `list_artifacts()` |
| 2 | 보안 스캔 통과 | `get_scan_report()` |
| 3 | ArgoCD 동기화 | `sync_application()` |
| 4 | 헬스체크 통과 | `get_application()` |
| 5 | 로그 정상 확인 | `get_application_logs()` |

### 주의사항

1. **단일 아키텍처 빌드 금지** - `docker build` 대신 `docker buildx build` 사용
2. **스캔 미통과 이미지 배포 금지** - `scan_artifact()` 후 Critical/High 취약점 없어야 함
3. **수동 kubectl 배포 금지** - 반드시 ArgoCD `sync_application()` 사용
4. **base 이미지 확인** - 멀티 아키텍처 지원하는지 확인
5. **네이티브 의존성** - 아키텍처별 바이너리 주의 (예: grpcio, numpy)

---

## 기술 스택

| 분류 | 기술 |
|------|------|
| **Language** | Python 3.12+ |
| **Framework** | FastAPI, Motor (MongoDB async) |
| **Messaging** | NATS |
| **Cache** | Valkey |
| **HTTP** | httpx (비동기) |

## 프로젝트 구조

```text
프로젝트/
├── src/                    # 소스 코드
├── tests/                  # 테스트
├── .planning/              # 작업 계획 (Planning-with-Files)
│   ├── task_plan.md
│   ├── findings.md
│   └── progress.md
├── .agents/                # Git Submodule (kei-agents-config)
│   ├── AGENTS.md
│   └── scripts/setup-agents.sh
├── AGENTS.md               # -> .agents/AGENTS.md (심볼릭 링크)
├── CLAUDE.md               # -> .agents/AGENTS.md (심볼릭 링크)
├── .cursorrules            # -> .agents/AGENTS.md (심볼릭 링크)
├── .windsurfrules          # -> .agents/AGENTS.md (심볼릭 링크)
├── .clinerules             # -> .agents/AGENTS.md (심볼릭 링크)
├── .github/
│   └── copilot-instructions.md  # -> ../.agents/AGENTS.md
├── .amazon-q/
│   └── instructions.md     # -> ../.agents/AGENTS.md
├── .codex/
│   └── instructions.md     # -> ../.agents/AGENTS.md
├── .aider.conf.yml         # Aider 설정
└── .continue/config.json   # Continue 설정
```

## 명령어

```bash
cd src
pytest                      # 테스트 실행
ruff check .                # 린트 검사
```

---

## AI-Friendly BaaS API

### 응답 구조

모든 BaaS API 응답은 일관된 구조를 따릅니다:

```python
# 성공 응답
{
    "success": True,
    "data": {...},
    "meta": {
        "request_id": "uuid",
        "timestamp": "ISO8601",
        "pagination": {"page": 1, "per_page": 20, "total_items": 100}
    }
}

# 에러 응답
{
    "success": False,
    "error": {
        "code": "VALIDATION_ERROR",
        "message": "Human-readable message",
        "suggestion": "How to fix"
    }
}
```

### 주요 API 엔드포인트

| 서비스 | 엔드포인트 | 주요 기능 |
|--------|-----------|----------|
| **푸시 알림** | `/api/v1/push` | 디바이스 등록, 메시지 전송 |
| **분석** | `/api/v1/analytics` | 이벤트 로깅, 사용자 분석 |
| **원격 구성** | `/api/v1/remote-config` | 파라미터, 기능 플래그 |
| **스키마 추론** | `/api/v1/schema` | 컬렉션 스키마 자동 감지 |
| **헬스 체크** | `/healthz`, `/api/v1/health` | K8s probe 호환 |

---

## 참고 링크

- **KeiMCP**: MCP 서버 (340+ 도구)
- **KeiBase**: AI 친화적 BaaS 플랫폼
- **KeiInfra**: Kubernetes 인프라 구성
- **Planning-with-Files**: https://github.com/OthmanAdi/planning-with-files
