include system/timers


type
  Stopwatch* = object
    running: bool
    start: Nanos 
    stop: Nanos 


# TODO document
proc newStopwatch*(): Stopwatch =
  result = Stopwatch(
    running: false,
    start: 0,
    stop: 0
  )


# TODO clone/copy constructor


proc running*(sw: var Stopwatch): bool {.inline.} =
  return sw.running


proc start*(sw: var Stopwatch) {.inline.} =
  sw.start = getTicks().Nanos


proc stop*(sw: var Stopwatch) {.inline.} =
  sw.stop = getTicks().Nanos


proc nsecs*(sw: var Stopwatch): int64 {.inline.} =
  return (sw.stop - sw.start).int64


#proc usecs*(sw: var Stopwatch): int64 {.inline.} =
#  return sw.nsecs / 1_000.int64
#
#
#proc msecs*(sw var Stopwatch): int64 {.inline.} =
#  return sw.nsecs / 1_000_000.int64


proc secs*(sw: var Stopwatch): float {.inline.} =
  return sw.nsecs.float / 1_000_000_000.0


{.deprecated: [clock: Stopwatch].}
{.deprecated: [nanoseconds: nsecs].}
{.deprecated: [seconds: secs].}


#template bench*(sw: Stopwatch, body: stmt): stmt {.immediate.} =
#  sw.start()
#  body
#  sw.stop()
