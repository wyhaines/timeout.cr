class Fiber
  alias TimeoutState = Tuple(Symbol?, Exception?)
  # :nodoc:
  property tstate = TimeoutState.new(nil, nil)

  # Get the state of the last timeout call within this Fiber.
  def timeout_state
    tstate[0]
  end

  # Set the state of the current timeout block within this Fiber.
  def timeout_state=(val : Symbol?)
    error = tstate[1]
    @tstate = TimeoutState.new(val, error)
    val
  end

  # Get the exception thrown, if any, of the last timeout call within this Fiber.
  def timeout_error
    tstate[1]
  end

  # Set the exception that was thrown within the timeout block in the current timeout call in this Fiber.
  def timeout_error=(val : Exception?)
    state = tstate[0]
    @tstate = TimeoutState.new(state, val)
    val
  end

  def timeout_state_and_error
    @tstate
  end

  def timeout_state_and_error=(state : TimeoutState)
    @tstate = state
  end
end