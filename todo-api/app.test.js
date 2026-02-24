const request = require('supertest');
const app = require('./app');

beforeEach(() => {
  app.resetState();
});

describe('GET /todos', () => {
  test('빈 목록 반환', async () => {
    const res = await request(app).get('/todos');
    expect(res.status).toBe(200);
    expect(res.body).toEqual([]);
  });

  test('추가된 todo 목록 반환', async () => {
    await request(app).post('/todos').send({ title: '첫 번째 할 일' });
    await request(app).post('/todos').send({ title: '두 번째 할 일' });

    const res = await request(app).get('/todos');
    expect(res.status).toBe(200);
    expect(res.body).toHaveLength(2);
    expect(res.body[0].title).toBe('첫 번째 할 일');
    expect(res.body[1].title).toBe('두 번째 할 일');
  });
});

describe('GET /todos/:id', () => {
  test('존재하는 todo 단건 조회', async () => {
    const created = await request(app).post('/todos').send({ title: '단건 조회 테스트' });
    const id = created.body.id;

    const res = await request(app).get(`/todos/${id}`);
    expect(res.status).toBe(200);
    expect(res.body.id).toBe(id);
    expect(res.body.title).toBe('단건 조회 테스트');
  });

  test('존재하지 않는 id → 404', async () => {
    const res = await request(app).get('/todos/999');
    expect(res.status).toBe(404);
    expect(res.body).toHaveProperty('error');
  });

  test('유효하지 않은 id → 400', async () => {
    const res = await request(app).get('/todos/abc');
    expect(res.status).toBe(400);
    expect(res.body).toHaveProperty('error');
  });
});

describe('POST /todos', () => {
  test('정상적인 todo 생성', async () => {
    const res = await request(app).post('/todos').send({ title: '새 할 일' });
    expect(res.status).toBe(201);
    expect(res.body).toMatchObject({
      id: expect.any(Number),
      title: '새 할 일',
      completed: false,
      createdAt: expect.any(String),
    });
  });

  test('title 앞뒤 공백 제거', async () => {
    const res = await request(app).post('/todos').send({ title: '  공백 테스트  ' });
    expect(res.status).toBe(201);
    expect(res.body.title).toBe('공백 테스트');
  });

  test('title 누락 → 400', async () => {
    const res = await request(app).post('/todos').send({});
    expect(res.status).toBe(400);
    expect(res.body).toHaveProperty('error');
  });

  test('title 빈 문자열 → 400', async () => {
    const res = await request(app).post('/todos').send({ title: '' });
    expect(res.status).toBe(400);
    expect(res.body).toHaveProperty('error');
  });

  test('title 공백만 있는 경우 → 400', async () => {
    const res = await request(app).post('/todos').send({ title: '   ' });
    expect(res.status).toBe(400);
    expect(res.body).toHaveProperty('error');
  });

  test('title이 문자열이 아닌 경우 → 400', async () => {
    const res = await request(app).post('/todos').send({ title: 123 });
    expect(res.status).toBe(400);
    expect(res.body).toHaveProperty('error');
  });
});

describe('PUT /todos/:id', () => {
  let todoId;

  beforeEach(async () => {
    const res = await request(app).post('/todos').send({ title: '수정 전 할 일' });
    todoId = res.body.id;
  });

  test('title 수정', async () => {
    const res = await request(app).put(`/todos/${todoId}`).send({ title: '수정 후 할 일' });
    expect(res.status).toBe(200);
    expect(res.body.title).toBe('수정 후 할 일');
  });

  test('completed 수정', async () => {
    const res = await request(app).put(`/todos/${todoId}`).send({ completed: true });
    expect(res.status).toBe(200);
    expect(res.body.completed).toBe(true);
  });

  test('title과 completed 동시 수정', async () => {
    const res = await request(app)
      .put(`/todos/${todoId}`)
      .send({ title: '동시 수정', completed: true });
    expect(res.status).toBe(200);
    expect(res.body.title).toBe('동시 수정');
    expect(res.body.completed).toBe(true);
  });

  test('존재하지 않는 id → 404', async () => {
    const res = await request(app).put('/todos/999').send({ title: '없음' });
    expect(res.status).toBe(404);
    expect(res.body).toHaveProperty('error');
  });

  test('유효하지 않은 id → 400', async () => {
    const res = await request(app).put('/todos/abc').send({ title: '없음' });
    expect(res.status).toBe(400);
    expect(res.body).toHaveProperty('error');
  });

  test('빈 title로 수정 → 400', async () => {
    const res = await request(app).put(`/todos/${todoId}`).send({ title: '' });
    expect(res.status).toBe(400);
    expect(res.body).toHaveProperty('error');
  });

  test('completed가 boolean이 아닌 경우 → 400', async () => {
    const res = await request(app).put(`/todos/${todoId}`).send({ completed: 'yes' });
    expect(res.status).toBe(400);
    expect(res.body).toHaveProperty('error');
  });
});

describe('DELETE /todos/:id', () => {
  let todoId;

  beforeEach(async () => {
    const res = await request(app).post('/todos').send({ title: '삭제할 할 일' });
    todoId = res.body.id;
  });

  test('정상적인 todo 삭제 → 204', async () => {
    const res = await request(app).delete(`/todos/${todoId}`);
    expect(res.status).toBe(204);
  });

  test('삭제 후 목록에서 제거됨', async () => {
    await request(app).delete(`/todos/${todoId}`);
    const res = await request(app).get('/todos');
    expect(res.body).toHaveLength(0);
  });

  test('존재하지 않는 id → 404', async () => {
    const res = await request(app).delete('/todos/999');
    expect(res.status).toBe(404);
    expect(res.body).toHaveProperty('error');
  });

  test('유효하지 않은 id → 400', async () => {
    const res = await request(app).delete('/todos/abc');
    expect(res.status).toBe(400);
    expect(res.body).toHaveProperty('error');
  });
});
