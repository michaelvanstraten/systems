"""Fail when the read list in tools.nix drifts from the tools upstream marks read-only."""

import asyncio
import sys

from fastmcp import Client
from mcp_bugzilla import server


async def upstream_read_only() -> set[str]:
    async with Client(server.mcp) as client:
        tools = await client.list_tools()
    return {
        tool.name
        for tool in tools
        if tool.annotations and tool.annotations.read_only_hint is True
    }


expected = set(sys.argv[1:])
actual = asyncio.run(upstream_read_only())

for name in sorted(actual - expected):
    print(f"read-only upstream but missing from tools.nix: {name}")
for name in sorted(expected - actual):
    print(f"in tools.nix but not read-only upstream: {name}")

sys.exit(expected != actual)
