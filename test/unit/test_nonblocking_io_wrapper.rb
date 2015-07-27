require 'minitest/autorun'
require 'tempfile'

# prepend lib/ dir to LOAD_PATH so we can 'require' from the tree
$:.unshift File.join(File.expand_path(File.dirname(__FILE__)), '..', '..', 'lib')
require 'bel/nonblocking_io_wrapper'

class TestNonblockingIOWrapper < Minitest::Test

  SUBPROCESS_WRITE_LENGTH_BYTES  = 32
  THIS_PROCESS_READ_LENGTH_BYTES = 128
  SCRIPT_DIR         = File.join(File.expand_path('..', __FILE__))

  def setup
    @read_io, @write_io = IO.pipe
    @pid = spawn(
      "ruby io_generator.rb #{SUBPROCESS_WRITE_LENGTH_BYTES}",
      :chdir => SCRIPT_DIR,
      :out => @write_io
    )
    @write_io.close
    @io_wrapper = NonblockingIOWrapper.new(
      @read_io,
      THIS_PROCESS_READ_LENGTH_BYTES
    )
  end

  def test_if_chunked_read
    @io_wrapper.each { |buffer|
      assert (buffer.length < THIS_PROCESS_READ_LENGTH_BYTES), "Blocking read"
    }
  end

  def teardown
    Process.wait @pid
    @read_io.close
  end
end
