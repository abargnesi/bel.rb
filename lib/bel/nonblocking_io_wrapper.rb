class NonblockingIOWrapper

  def initialize(io, max_read_length)
    @io              = io
    @max_read_length = max_read_length
    @read_method     = nonblocking_read(@io)
  end

  def each
    begin
      while buffer = @read_method[@max_read_length]
        yield buffer
      end
    rescue IO::WaitReadable
      IO.select([@io])
      retry
    rescue EOFError
      # end of stream; parsing complete
    end
  end

  private

  def nonblocking_read(io)
    if Gem.win_platform?
      io.method(:read)
    else
      io.method(:read_nonblock)
    end
  end
end
