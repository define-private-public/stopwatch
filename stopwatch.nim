include system/timers


type
  Stopwatch* = object
    start*: int64
    stop*: int64

{.deprecated: [clock: Stopwatch].}




proc start*(sw: var Stopwatch) {.inline.} =
  sw.start = getTicks().Nanos


proc stop*(sw: var Stopwatch) {.inline.} =
  sw.stop = getTicks().Nanos


proc nanoseconds*(sw: Stopwatch): int64 {.inline.} =
  return (sw.stop - sw.start)


proc seconds*(sw: Stopwatch): float {.inline.} =
  return sw.nanoseconds / 1_000_000_000.0


template bench*(sw: Stopwatch, body: stmt): stmt {.immediate.} =
  sw.start()
  body
  sw.stop()

