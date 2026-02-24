# Todo API

Node.js + Express 기반의 간단한 Todo REST API입니다.

## 기술 스택

- Node.js + Express 5
- 메모리 저장 (DB 없음)
- Jest + Supertest (테스트)

## 실행 방법

```bash
npm install
npm start       # 서버 실행 (포트 3000)
npm test        # 테스트 실행
```

## API 엔드포인트

### 목록 조회
```
GET /todos
```
응답: `200 OK` + Todo 배열

### 단건 조회
```
GET /todos/:id
```
응답: `200 OK` + Todo 객체
오류: `404` (없는 id), `400` (유효하지 않은 id)

### 생성
```
POST /todos
Content-Type: application/json

{ "title": "할 일 내용" }
```
응답: `201 Created` + 생성된 Todo 객체
오류: `400` (title 누락, 빈 문자열, 문자열 아닌 경우)

### 수정
```
PUT /todos/:id
Content-Type: application/json

{ "title": "수정된 내용", "completed": true }
```
응답: `200 OK` + 수정된 Todo 객체
오류: `404` (없는 id), `400` (유효하지 않은 값)

### 삭제
```
DELETE /todos/:id
```
응답: `204 No Content`
오류: `404` (없는 id), `400` (유효하지 않은 id)

## Todo 객체 구조

```json
{
  "id": 1,
  "title": "할 일 내용",
  "completed": false,
  "createdAt": "2026-02-24T00:00:00.000Z"
}
```

## 테스트

22개 테스트 케이스:
- GET /todos: 2개
- GET /todos/:id: 3개
- POST /todos: 6개
- PUT /todos/:id: 8개
- DELETE /todos/:id: 4개
