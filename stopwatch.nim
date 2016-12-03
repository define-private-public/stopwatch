include system/timers
from sequtils import foldl


type
  Stopwatch* = object
    running: bool
    startTicks: Nanos 
    laps: seq[Nanos]


# Function prototypes
proc newStopwatch*(): Stopwatch
proc running*(sw: var Stopwatch): bool {.inline.}
proc start*(sw: var Stopwatch) {.inline.}
proc stop*(sw: var Stopwatch) {.inline.}

# TODO lap functions
# lap(int) -> single compleded laps   # TODO: flag to include current lap?
# laps() -> all completed laps
# numLaps() -> count of completed laps


# These functions are for the current lap (or previous one if not running)
#  TODO fix them up
proc nsecs*(sw: var Stopwatch): int64 {.inline.}
#proc usecs*(sw: var Stopwatch): int64 {.inline.}
#proc msecs*(sw var Stopwatch): int64 {.inline.}
proc secs*(sw: var Stopwatch): float {.inline.}

# These functions include the time for all laps (plus the current lap, if there is one)
proc totalNsecs*(sw: var Stopwatch): int64 {.inline.}
#proc totalUsecs*(sw: var Stopwatch): int64 {.inline.}
#proc totalMsecs*(sw var Stopwatch): int64 {.inline.}
proc totalSecs*(sw: var Stopwatch): float {.inline.}



# TODO document
proc newStopwatch*(): Stopwatch =
  result = Stopwatch(
    running: false,
    startTicks: 0,
    laps: @[]
  )


# TODO clone/copy constructor


proc running*(sw: var Stopwatch): bool =
  return sw.running


proc start*(sw: var Stopwatch) =
  # If we are already running, ignore
  if sw.running:
    return

  # Start the lap
  sw.running = true
  sw.startTicks = getTicks().Nanos


proc stop*(sw: var Stopwatch) =
  # First thing, measure the time
  let stopTicks = getTicks().Nanos

  # If not running, ignore
  if not sw.running:
    return

  # save the lap that we just made
  sw.laps.add(stopTicks - sw.startTicks)

  # Reset timer state
  sw.running = false
  sw.startTicks = 0


proc nsecs*(sw: var Stopwatch): int64 =
  let curTicks = getTicks().Nanos

  if sw.running:
    # Return current lap
    return (curTicks - sw.startTicks).int64
  else:
    # Return previous lap
    return sw.laps[high(sw.laps)].int64


#proc usecs*(sw: var Stopwatch): int64 =
#  return sw.nsecs / 1_000.int64
#
#
#proc msecs*(sw var Stopwatch): int64 =
#  return sw.nsecs / 1_000_000.int64


proc secs*(sw: var Stopwatch): float =
  return sw.nsecs.float / 1_000_000_000.0


# These functions include the time for all laps (plus the current lap, if there is one)
proc totalNsecs*(sw: var Stopwatch): int64 =
  let curTicks = getTicks().Nanos
  let total = if sw.laps.len != 0: foldl(sw.laps, a + b) else: 0

  if sw.running:
    # Return total + current lap
    return (total + (curTicks - sw.startTicks)).int64
  else:
    return total.int64


proc totalSecs*(sw: var Stopwatch): float =
  return sw.totalNsecs.float / 1_000_000_000.0


{.deprecated: [clock: Stopwatch].}
{.deprecated: [nanoseconds: nsecs].}
{.deprecated: [seconds: secs].}


#template bench*(sw: Stopwatch, body: stmt): stmt {.immediate.} =
#  sw.start()
#  body
#  sw.stop()

