include system/timers
from sequtils import foldl


# Handy conversion functions
proc usecs*(nsecs: int64): int64 {.inline.}
proc msecs*(nsecs: int64): int64 {.inline.}
proc secs*(nsecs: int64): float {.inline.}


type
  Stopwatch* = object
    running: bool
    startTicks: Nanos 
    laps: seq[Nanos]


# Function prototypes
proc newStopwatch*(): Stopwatch
proc clone*(sw: var Stopwatch): Stopwatch
proc running*(sw: var Stopwatch): bool {.inline.}
proc start*(sw: var Stopwatch) {.inline.}
proc stop*(sw: var Stopwatch) {.inline.}
proc reset*(sw: var Stopwatch) {.inline.}
proc restart*(sw: var Stopwatch) {.inline.}

# Lap functions
proc numLaps*(sw: var Stopwatch; incCur: bool = false): int {.inline.}
proc lap*(sw: var Stopwatch; num: int; incCur: bool = false): int64 {.inline.}
proc laps*(sw: var Stopwatch; incCur: bool = false): seq[int64] {.inline.}
proc rmLap*(sw: var Stopwatch; num: int) {.inline.}
proc clearLaps(sw: var Stopwatch) {.inline.}

# These functions are for the current lap (or previous one if not running)
proc nsecs*(sw: var Stopwatch): int64 {.inline.}
proc usecs*(sw: var Stopwatch): int64 {.inline.}
proc msecs*(sw: var Stopwatch): int64 {.inline.}
proc secs*(sw: var Stopwatch): float {.inline.}

# These functions include the time for all laps (plus the current lap, if there is one)
proc totalNsecs*(sw: var Stopwatch): int64 {.inline.}
proc totalUsecs*(sw: var Stopwatch): int64 {.inline.}
proc totalMsecs*(sw: var Stopwatch): int64 {.inline.}
proc totalSecs*(sw: var Stopwatch): float {.inline.}


# Deprecations from the older stopwatch module
{.deprecated: [clock: Stopwatch].}
{.deprecated: [nanoseconds: nsecs].}
{.deprecated: [seconds: secs].}


# TODO document
proc newStopwatch*(): Stopwatch =
  result = Stopwatch(
    running: false,
    startTicks: 0,
    laps: @[]
  )


proc clone*(sw: var Stopwatch): Stopwatch =
  result = Stopwatch(
    running: sw.running,
    startTicks: sw.startTicks,
    laps: sw.laps
  )


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


# TODO document
proc reset*(sw: var Stopwatch) =
  sw.running = false
  sw.startTicks = 0
  sw.laps.setLen(0)   # Clear the laps


# TODO document
proc restart*(sw: var Stopwatch) =
  sw.reset()
  sw.start()


proc numLaps*(sw: var Stopwatch; incCur: bool = false): int =
  return sw.laps.len + (if incCur and sw.running: 1 else: 0)


proc lap*(sw: var Stopwatch; num: int; incCur: bool = false): int64 =
  if incCur and sw.running:
    # Check if the index is good or not
    if num < sw.laps.len:
      # Return one of the previous laps
      return sw.laps[num]
    elif num == sw.laps.len:
      # Return the current lap
      return sw.nsecs
    else:
      # Out of bounds
      raise newException(IndexError, "provided lap number isn't valid.")
  else:
    # only look at completed laps
    return sw.laps[num]


proc laps*(sw: var Stopwatch; incCur: bool = false): seq[int64] =
  return sw.laps


proc rmLap*(sw: var Stopwatch; num: int) =
  sw.laps.delete(num)


proc clearLaps(sw: var Stopwatch) =
  sw.laps.setLen(0)


proc nsecs*(sw: var Stopwatch): int64 =
  let curTicks = getTicks().Nanos

  if sw.running:
    # Return current lap
    return (curTicks - sw.startTicks).int64
  else:
    # Return previous lap
    return sw.laps[high(sw.laps)].int64


proc usecs*(sw: var Stopwatch): int64 =
  return usecs(sw.nsecs)


proc msecs*(sw: var Stopwatch): int64 =
  return msecs(sw.nsecs)


proc secs*(sw: var Stopwatch): float =
  return secs(sw.nsecs)


# These functions include the time for all laps (plus the current lap, if there is one)
proc totalNsecs*(sw: var Stopwatch): int64 =
  let curTicks = getTicks().Nanos
  let total = if sw.laps.len != 0: foldl(sw.laps, a + b) else: 0

  if sw.running:
    # Return total + current lap
    return (total + (curTicks - sw.startTicks)).int64
  else:
    return total.int64


proc totalUsecs*(sw: var Stopwatch): int64 =
  return usecs(sw.totalNsecs)


proc totalMsecs*(sw: var Stopwatch): int64 =
  return msecs(sw.totalNsecs)


proc totalSecs*(sw: var Stopwatch): float =
  return secs(sw.totalNsecs)




proc usecs*(nsecs: int64): int64 =
  return (nsecs div 1_000).int64


proc msecs*(nsecs: int64): int64 =
  return (nsecs div 1_000_000).int64


proc secs*(nsecs: int64): float =
  return nsecs.float / 1_000_000_000.0

