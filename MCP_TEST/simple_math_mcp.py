from mcp.server.fastmcp import FastMCP

mcp = FastMCP("simple-math")

@mcp.tool()
def add(a: float, b: float) -> float:
    """두 숫자를 더합니다."""
    return a + b

@mcp.tool()
def subtract(a: float, b: float) -> float:
    """두 숫자를 뺍니다."""
    return a - b

@mcp.tool()
def multiply(a: float, b: float) -> float:
    """두 숫자를 곱합니다."""
    return a * b

@mcp.tool()
def divide(a: float, b: float) -> float:
    """두 숫자를 나눕니다."""
    if b == 0:
        raise ValueError("0으로 나눌 수 없습니다.")
    return a / b

if __name__ == "__main__":
    mcp.run()