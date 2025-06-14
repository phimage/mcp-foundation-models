# mcp-foundation-models

A Model Context Protocol (MCP) server that provides text generation capabilities using Apple's Foundation Models framework. This server enables MCP clients to access Apple's on-device language models for secure, private text generation.

## Features

- **Apple Foundation Models Integration**: Leverages Apple's on-device language models for text generation

## Requirements

- macOS 26.0 or later (macOS Tahoe)
- Xcode 26.0 or later
- Swift 6.2 or later
- Apple Silicon Mac (for optimal Foundation Models)

## Installation

### Building from Source

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd mcp-foundation-models
   ```

2. Build the project:
   ```bash
   swift build -c release
   ```

3. The executable will be available at:
   ```
   .build/release/mcp-foundation-models
   ```

### Use it in Claude Desktop for instance

Edit Claude configuration file '$HOME/Library/Application Support/Claude/claude_desktop_config.json'

Add this server full path as "mcpServers" sub object 
```json
{
  "mcpServers": {
    "foundation-models": {
      "command": "/path/to/mcp-foundation-models/.build/release/mcp-foundation-models",
      "args": [
      ]
    }
```

#### Environment Variables

The server supports configuration through environment variables:

- `SYSTEM_INSTRUCTIONS`: Set default system instructions for the AI assistant
- `DEBUG`: Enable debug logging (any non-empty value)

 
### Dependencies

- [swift-argument-parser](https://github.com/apple/swift-argument-parser): Command line argument parsing
- [swift-sdk (MCP)](https://github.com/modelcontextprotocol/swift-sdk): Model Context Protocol implementation
- [swift-service-lifecycle](https://github.com/swift-server/swift-service-lifecycle): Graceful service lifecycle management

## TODO
- manage some session id to keep some conversation history

## License

MIT

