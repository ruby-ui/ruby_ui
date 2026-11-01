require "test_helper"
require "chunky_png"

class CollectPixelDiffTest < Minitest::Test
  PixelDiff = ShadcnAudit::Collect::PixelDiff

  def setup = @tmp = Dir.mktmpdir

  def teardown = FileUtils.remove_entry(@tmp)

  def png(name, width = 4, height = 4, changes = {})
    image = ChunkyPNG::Image.new(width, height, ChunkyPNG::Color.rgba(100, 100, 100, 255))
    changes.each { |(x, y), color| image[x, y] = color }
    path = File.join(@tmp, name)
    image.save(path)
    path
  end

  def compare(a, b) = PixelDiff.compare(rubyui_png: a, shadcn_png: b, diff_png: File.join(@tmp, "diff.png"))

  def test_identical_images
    result = compare(png("a.png"), png("b.png"))
    assert_equal 0, result["pixels"]
    assert_equal 0.0, result["ratio"]
  end

  def test_small_channel_difference_is_tolerated
    result = compare(png("a.png"), png("b.png", 4, 4, [0, 0] => ChunkyPNG::Color.rgba(110, 100, 100, 255)))
    assert_equal 0, result["pixels"]
  end

  def test_large_difference_counts_and_writes_diff
    result = compare(png("a.png"), png("b.png", 4, 4, [1, 2] => ChunkyPNG::Color.rgba(140, 100, 100, 255)))
    assert_equal 1, result["pixels"]
    assert_equal 0.0625, result["ratio"]
    assert File.exist?(result["diff"])
    assert_equal ChunkyPNG::Color.rgba(255, 0, 0, 255), ChunkyPNG::Image.from_file(result["diff"])[1, 2]
  end

  def test_size_mismatch_is_an_error
    diff = File.join(@tmp, "diff.png")
    assert_equal({"error" => "size 4x4 vs 4x3"}, compare(png("a.png"), png("b.png", 4, 3)))
    refute File.exist?(diff)
  end
end
