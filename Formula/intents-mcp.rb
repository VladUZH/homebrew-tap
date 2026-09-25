# intents-mcp: https://github.com/VladUZH/intents-mcp
class IntentsMcp < Formula
  desc "Expose your Mac's App Intents to AI agents as MCP tools, through Shortcuts"
  homepage "https://github.com/VladUZH/intents-mcp"
  url "https://github.com/VladUZH/intents-mcp/archive/refs/tags/v0.1.1.tar.gz"
  sha256 "7d55a85437d2cb3de637b422f025b9e8e2bb43664335711dd00f15d730f7ca33"
  license "MIT"

  bottle do
    root_url "https://github.com/VladUZH/homebrew-tap/releases/download/intents-mcp-0.1.1"
    sha256 cellar: :any_skip_relocation, arm64_tahoe: "07dfd4cc1bbe26714fee4023381b35251c7fa30dc36e8aee35339e585caa0e56"
  end

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
        claude mcp add mac -- #{opt_bin}/intents-mcp serve
        codex mcp add mac -- #{opt_bin}/intents-mcp serve
      Each tool needs one "Add Shortcut" click and one "Always Allow" on first run.
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
