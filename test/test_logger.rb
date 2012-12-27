require 'test/unit'
require 'alfa/logger'
require 'tempfile'

class TestAlfaLogger < Test::Unit::TestCase
  # test of nested Formatter class
  def test_01
    formatter = Alfa::Logger::Formatter.new
    time = Time.now
    progname = 'unknown'
    assert_equal("Hello\n", formatter.call(Logger::Severity::DEBUG, time, progname, 'Hello'))
    assert_equal("Hello\n", formatter.call(Logger::Severity::INFO, time, progname, 'Hello'))
    assert_equal("Hello\n", formatter.call(Logger::Severity::WARN, time, progname, 'Hello'))
    assert_equal("Hello\n", formatter.call(Logger::Severity::ERROR, time, progname, 'Hello'))
    assert_equal("Hello\n", formatter.call(Logger::Severity::FATAL, time, progname, 'Hello'))
    assert_equal("Hello\n", formatter.call(Logger::Severity::UNKNOWN, time, progname, 'Hello'))
  end

  # test of nested VirtualIO class
  def test_02
    io = Alfa::Logger::VirtualIO.new
    assert io.respond_to?(:write)
    assert io.respond_to?(:close)
    io.write("Hello")
    io.write("World")
    assert_equal(["Hello", "World"], io)
  end

  # base test with virtual receiver
  def test_03
    io = Alfa::Logger::VirtualIO.new
    logger = Alfa::Logger.new(io)
    logger.info("Hello")
    logger.info("World")
    logger << "zz"
    assert_equal(["Hello\n", "World\n", "zz"], io)
  end

  # base test with real file
  def test_04
    Tempfile.open('loggertest_04_') do |f|
      logger = Alfa::Logger.new(f)
      logger.info "Hello"
      logger.info "World"
      logger << "zz"
      f.rewind
      assert_equal("Hello\nWorld\nzz", f.read)
    end
  end

  # simulate 2 threads with virtual receiver
  # threads write to receiver in their close order
  def test_05
    io = Alfa::Logger::VirtualIO.new
    logger = Alfa::Logger.new(io)
    logger.portion do |l1|
      l1.info "Hello"
      logger.portion do |l2|
        l2.info "Baramba"
        l2.info "Caramba!"
        l2 << "\n"
        # first closed thread -> first write to receiver
      end
      l1.info "World"
      l1 << "\n"
      # last closed thread -> last write to receiver
    end
    assert_equal(["Baramba\nCaramba!\n\n", "Hello\nWorld\n\n"], io)
  end

  # simulate 2 threads with real file
  # threads write to receiver in their close order
  def test_06
    Tempfile.open('loggertest_06_') do |f|
      logger = Alfa::Logger.new(f)
      logger.portion do |l1|
        l1.info "Hello"
        logger.portion do |l2|
          l2.info "Baramba"
          l2.info "Caramba!"
          l2 << "\n"
          # first closed thread -> first write to receiver
        end
        l1.info "World"
        l1 << "\n"
        # last closed thread -> last write to receiver
      end
      f.rewind
      assert_equal("Baramba\nCaramba!\n\nHello\nWorld\n\n", f.read)
    end
  end

  # NullLogger
  def test_07
    assert Alfa::NullLogger.instance_methods.include?(:portion)
  end
end
