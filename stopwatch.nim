include system/timers


type
  Stopwatch* = object
    running: bool
    startTicks: Nanos 
    stop: Nanos
    laps: seq[Nanos]


# Function prototypes
proc newStopwatch*(): Stopwatch
proc running*(sw: var Stopwatch): bool {.inline.}
proc start*(sw: var Stopwatch) {.inline.}
proc stop*(sw: var Stopwatch) {.inline.}
proc nsecs*(sw: var Stopwatch): int64 {.inline.}
#proc usecs*(sw: var Stopwatch): int64 {.inline.}
#proc msecs*(sw var Stopwatch): int64 {.inline.}
proc secs*(sw: var Stopwatch): float {.inline.}


# TODO document
proc newStopwatch*(): Stopwatch =
  result = Stopwatch(
    running: false,
    stop: 0,
    laps: @[]
  )


# TODO clone/copy constructor


proc running*(sw: var Stopwatch): bool =
  return sw.running


proc start*(sw: var Stopwatch) =
  # If we are already running, ignore
  if sw.running:
    return

  # 

  sw.startTicks = getTicks().Nanos


proc stop*(sw: var Stopwatch) =
  sw.stop = getTicks().Nanos


proc nsecs*(sw: var Stopwatch): int64 =
  return (sw.stop - sw.startTicks).int64


#proc usecs*(sw: var Stopwatch): int64 =
#  return sw.nsecs / 1_000.int64
#
#
#proc msecs*(sw var Stopwatch): int64 =
#  return sw.nsecs / 1_000_000.int64


proc secs*(sw: var Stopwatch): float =
  return sw.nsecs.float / 1_000_000_000.0


{.deprecated: [clock: Stopwatch].}
{.deprecated: [nanoseconds: nsecs].}
{.deprecated: [seconds: secs].}


#template bench*(sw: Stopwatch, body: stmt): stmt {.immediate.} =
#  sw.start()
#  body
#  sw.stop()

