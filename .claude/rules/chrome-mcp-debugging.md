# Chrome MCP Debugging

## Rule

When running or debugging the Flutter app, use the Chrome DevTools MCP server to:
- Navigate to the app URL (typically `http://localhost:<port>`)
- Take screenshots to verify UI state
- Inspect console messages for errors
- Monitor network requests
- Evaluate JavaScript/Dart-compiled code in the browser

## Workflow

1. Run the Flutter app in Chrome (`flutter run -d chrome`)
2. Use `mcp__chrome-devtools__navigate_page` to load the app
3. Use `mcp__chrome-devtools__take_screenshot` to verify visual output
4. Use `mcp__chrome-devtools__list_console_messages` to check for errors
5. Use `mcp__chrome-devtools__list_network_requests` to debug API calls

## When to Use

- Any time the app needs to be run or tested visually
- When debugging UI issues or layout problems
- When verifying Figma-to-code visual parity
- When investigating runtime errors in the browser
