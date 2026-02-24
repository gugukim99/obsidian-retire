# todo-api 폴더 안에 생성
cat > CLAUDE.md << 'EOF'
# Todo API 프로젝트

## 기술 스택
- Node.js + Express
- 데이터: 메모리 저장 (DB 없음)
- 테스트: Jest

## 완료 기준
- GET /todos → 목록 조회
- POST /todos → 항목 추가
- PUT /todos/:id → 수정
- DELETE /todos/:id → 삭제
- 모든 테스트 통과
- README.md 작성 완료
EOF