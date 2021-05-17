require "./spec_helper"

describe Timeout do
  it "doesn't do anything if a wrapped block returns in time" do
    it_worked = false
    fiber_state = timeout(1) do
      it_worked = true
    end
    fiber_state.should eq :finished
    Fiber.current.timeout_state.should eq :finished
    it_worked.should be_true
  end

  it "handles a timeout without raising exceptions" do
    fiber_state = timeout(
      seconds: 1,
      raise_on_timeout: false
    ) do
      sleep 2
    end

    fiber_state.should eq :timed_out
    Fiber.current.timeout_state.should eq :timed_out
  end

  it "handles a timeout by raising an exception" do
    exception = nil
    begin
      timeout(1) do
        sleep 2
      end
    rescue e : Exception
      exception = e
    end

    exception.class.should eq Timeout::Error
    Fiber.current.timeout_state.should eq :timed_out
  end

  it "handles a raised exception in a timeout " do
    exception = nil
    begin
      timeout(1) do
        raise "Test Exception"
      end
    rescue e : Exception
      exception = e
    end

    exception.class.should eq Exception
    exception.try(&.message).should eq "Test Exception"
    Fiber.current.timeout_error.class.should eq Exception
    Fiber.current.timeout_error.should eq exception
  end

  it "makes error status and exception available even when swallowing exceptions in the block" do
    status = timeout(
      seconds: 1,
      raise_on_exception: false
    ) do
      raise "Test Exception"
    end

    Fiber.current.timeout_state.should eq :error
    Fiber.current.timeout_state.should eq status
    Fiber.current.timeout_error.class.should eq Exception
    Fiber.current.timeout_error.try(&.message).should eq "Test Exception"
  end

  it "can timeout a tight loop if yields are included" do
    n = 0_u64
    timeout(1, false) do
      loop do
        n += 1
        Fiber.yield
      end
    end

    Fiber.current.timeout_state.should eq :timed_out
  end

end
