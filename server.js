// MCP 서버 예제: 할일 목록 관리
// Node.js 환경에서 실행

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";

// 할일 목록 저장 (실제로는 데이터베이스 사용)
const todos = [];

// MCP 서버 생성
const server = new Server(
  {
    name: "todo-server",
    version: "1.0.0",
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

// 도구 목록 제공
server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      {
        name: "add_todo",
        description: "새로운 할일을 추가합니다",
        inputSchema: {
          type: "object",
          properties: {
            task: {
              type: "string",
              description: "할일 내용",
            },
          },
          required: ["task"],
        },
      },
      {
        name: "list_todos",
        description: "모든 할일 목록을 조회합니다",
        inputSchema: {
          type: "object",
          properties: {},
        },
      },
      {
        name: "complete_todo",
        description: "할일을 완료 처리합니다",
        inputSchema: {
          type: "object",
          properties: {
            id: {
              type: "number",
              description: "완료할 할일의 ID",
            },
          },
          required: ["id"],
        },
      },
    ],
  };
});

// 도구 실행 처리
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  switch (name) {
    case "add_todo":
      const newTodo = {
        id: todos.length + 1,
        task: args.task,
        completed: false,
        createdAt: new Date().toISOString(),
      };
      todos.push(newTodo);
      return {
        content: [
          {
            type: "text",
            text: `할일이 추가되었습니다: ${args.task}`,
          },
        ],
      };

    case "list_todos":
      return {
        content: [
          {
            type: "text",
            text: JSON.stringify(todos, null, 2),
          },
        ],
      };

    case "complete_todo":
      const todo = todos.find((t) => t.id === args.id);
      if (todo) {
        todo.completed = true;
        return {
          content: [
            {
              type: "text",
              text: `할일이 완료되었습니다: ${todo.task}`,
            },
          ],
        };
      }
      return {
        content: [
          {
            type: "text",
            text: `ID ${args.id}인 할일을 찾을 수 없습니다`,
          },
        ],
      };

    default:
      throw new Error(`알 수 없는 도구: ${name}`);
  }
});

// 서버 시작
async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error("할일 MCP 서버가 시작되었습니다");
}

main().catch((error) => {
  console.error("서버 오류:", error);
  process.exit(1);
});