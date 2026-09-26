# intents-mcp: https://github.com/VladUZH/intents-mcp
class IntentsMcp < Formula
  desc "Expose your Mac's App Intents to AI agents as MCP tools, through Shortcuts"
  homepage "https://github.com/VladUZH/intents-mcp"
  url "https://github.com/VladUZH/intents-mcp/archive/refs/tags/v0.1.4.tar.gz"
  sha256 "1bd139ca2fd27c70adb672d217d8f2137a786ce402b2325f4081bf1304a9df25"
  license "MIT"

  depends_on xcode: ["26.0", :build]
  depends_on macos: :tahoe
  uses_from_macos "swift" => :build

  def install
    system "swift", "build", "--disable-sandbox", *std_swift_args
    bin.install ".build/release/intents-mcp"
  end

  def caveats
    <<~EOS
      Enable tools, then add the server to your agent:
        intents-mcp enable reminders.add calendar.create-event
        claude mcp add --scope user mac -- #{opt_bin}/intents-mcp serve
        codex mcp add mac -- #{opt_bin}/intents-mcp serve
      Click "Add Shortcut" for each tool, and once more for its read-back helper (Reminders,
      Calendar). Shortcuts may also ask to "Always Allow" on a tool's first run.
      Signing a shortcut uses your iCloud account; Apple receives a copy for validation.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/intents-mcp --version")
    ENV["INTENTS_MCP_HOME"] = testpath.to_s
    request = <<~JSON
      {"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{"experimental":{"x":{}}}}}
      {"jsonrpc":"2.0","id":2,"method":"tools/list"}
    JSON
    output = pipe_output("#{bin}/intents-mcp serve", request, 0)
    assert_match '"protocolVersion":"2025-06-18"', output
    assert_match '"tools":[]', output
  end
end
