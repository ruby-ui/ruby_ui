require File.expand_path('../helper', __FILE__)

describe "recipe download" do
  include Minitest::Hooks

  attr :recipe

  def server_must_receive_connection(connections = 3, &block)
    request_count = 0

    server = TCPServer.open('localhost', TestCase::HTTP_PORT)
    thread = Thread.new do
      connections.times do
        conn = server.accept
        request_count += 1
        conn.puts "CONNECTION SUCESSFULLY MADE" rescue SystemCallError
        conn.close
      end
    end

    begin
      block.call
    ensure
      thread.kill
      server.close
    end

    assert_operator(request_count, :>, 0)
  end

  before do
    @request_count = 0
    @logger = StringIO.new
    @recipe = MiniPortile.new("test-download", "1.1.1", logger: @logger)
  end

  describe "urls" do
    it "ftp" do
      @recipe.files << "ftp://localhost:#{TestCase::HTTP_PORT}/foo"
      server_must_receive_connection 1 do
        @recipe.download
      end
    end

    it "handles http" do
      @recipe.files << "http://localhost:#{TestCase::HTTP_PORT}/foo"
      server_must_receive_connection 3 do
        @recipe.download
      end
    end

    it "handles https" do
      @recipe.files << "https://localhost:#{TestCase::HTTP_PORT}/foo"
      server_must_receive_connection 3 do
        @recipe.download
      end
    end

    it "file" do
      dest = "ports/archives/test-download-archive.tar.gz"
      FileUtils.rm_f dest
      path = File.expand_path(File.join(File.dirname(__FILE__), "assets", "test-download-archive.tar.gz"))
      @recipe.files << "file://#{path}"
      @recipe.download
      assert File.exist?(dest)
      assert_equal("ee0e9f44e72213015ef976d5ac23931d", Digest::MD5.file(dest).hexdigest)
    end

    it "other" do
      @recipe.files << "foo://foo"
      assert_raises(ArgumentError) { @recipe.download }
    end
  end
end
