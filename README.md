# timeout

This timeout implementation wraps a block inside of another fiber. Because the fiber scheduler is not pre-emptive, a fiber that is in a tight, CPU bound loop that offers no opportunities for the scheduler to run a different fiber will not time out. This is because the execution context never switches away from the running fiber, so there is never any opportunity to determine if it has timed out or not.

For example:

```crystal
timeout(1) do
  loop do
    n += 1
  end
end
```

Will not work to time that block out after one second, because a tight loop like that, in Crystal, will never provide the code with any opportunity to determine if it has timed out. To make this time out, an opportunity must be provided.

[https://crystal-lang.org/api/1.0.0/Fiber.html#yield-class-method](https://crystal-lang.org/api/1.0.0/Fiber.html#yield-class-method)

> Yields to the scheduler and allows it to swap execution to other waiting fibers.
>
> This is equivalent to sleep 0.seconds. It gives the scheduler an option to interrupt the current fiber's execution. If no other fibers are ready to be resumed, it immediately resumes the current fiber.
>
> This method is particularly useful to break up tight loops which are only computation intensive and don't offer natural opportunities for swapping fibers as with IO operations.

`Fiber.yield` will do the job. It just needs to be inserted somewhere inside of the tight, otherwise CPU bound loop.

```crystal
timeout(1) do
  loop do
    n += 1
    Fiber.yield
  end
end
```

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     timeout:
       github: your-github-user/timeout
   ```

2. Run `shards install`

## Usage

```crystal
require "timeout"
```


## Development


## Contributing

1. Fork it (<https://github.com/wyhaines/timeout/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Kirk Haines](https://github.com/wyhaines) - creator and maintainer
