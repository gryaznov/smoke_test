# SmokeTest

### Usage

```elixir
$ iex -S mix
iex(1)> SmokeTest.run |> IO.puts

Result:
- requests made: 1;
- succeed: 1;
- failed: 0;
- avg. time per request: 137ms;
- time (in ms): 137;

:ok

iex(2)> SmokeTest.run("https://httpbin.org/get", sequence: 1, parallel: 199) |> IO.puts

Result:
- requests made: 200;
- succeed: 200;
- failed: 0;
- avg. time per request: 230ms;
- time (in ms): 135, 1006, 134, 137, 140...

:ok
```
