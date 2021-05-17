require "./fiber"

struct Timeout
  VERSION = "0.1.0"

  class Error < Exception
  end
end

def sleep(seconds : Number)
  # This is because of a funky behavior where the first sleep inside of the block
  # that the timout wraps doesn't actually sleep at all - it returns immediately.
  Crystal::Scheduler.sleep(0.seconds)
  Crystal::Scheduler.sleep(seconds.seconds)
end

def sleep(time : Time::Span)
  # This is because of a funky behavior where the first sleep inside of the block
  # that the timout wraps doesn't actually sleep at all - it returns immediately.
  Crystal::Scheduler.sleep(0.seconds)
  Crystal::Scheduler.sleep(time)
end

# This timeout implementation wraps a block inside of another fiber.
# Because there isn't a pre-emptive scheduler, timeouts can not be externally
# forced if the code inside of the block doesn't allow opportunities for
# the scheduler to move execution to another fiber. If that is permitted,
# through IO, or sleep, or yields, then this method can work to enforce a
# timeout around code that might otherwise block.
def timeout(
  seconds : Number,
  raise_on_timeout : Bool = true,
  raise_on_exception : Bool = true,
  &blk
)
  current_fiber = Fiber.current
  fiber_state, fiber_error = current_fiber.timeout_state_and_error = {:unstarted, nil}

  timeout_fiber = Fiber.new(name: "Timeout --#{blk}--#{seconds}") {
    fiber_state = current_fiber.timeout_state = :started
    begin
      blk.call
    rescue e : Exception
      fiber_state, fiber_error = current_fiber.timeout_state_and_error = {:error, e}
    end
    fiber_state = current_fiber.timeout_state = :finished unless fiber_state == :error
    current_fiber.resume
  }

  Fiber.timeout(seconds.seconds)
  timeout_fiber.resume
  current_fiber.timeout_state = fiber_state
  Fiber.cancel_timeout

  if fiber_state != :finished
    if fiber_error
      fiber_state, fiber_error = current_fiber.timeout_state_and_error = {:error, fiber_error}
      raise fiber_error.not_nil! if raise_on_exception
    else
      fiber_state = current_fiber.timeout_state = :timed_out
      raise Timeout::Error.new if raise_on_timeout
    end
  end

  fiber_state
end
