# File:         stopwatch/js_target.nim
# Authors:      Benjamin N. Summerton <define-private-public>
# License:      MIT; See the file `LICENSE` for details.
# Description:  A Browser JS specific implementation, it uses milliseconds instead




# Handy conversion functions
proc secs*(msecs: int): float {.inline.}


# The Stopwatch object
type
  Tick* = distinct int

  Stopwatch* = object
    running: bool
    startTicks: Ticks
    recordLaps: bool
    previousLap: Ticks
    laps: seq[Ticks]
    total: Nanos


proc getTicks_internal(): Ticks {.inline.}

# Basic stopwatch functionality
proc stopwatch*(enableLapping:bool = true): Stopwatch
proc clone*(sw: var Stopwatch): Stopwatch
proc running*(sw: var Stopwatch): bool {.inline.}
proc start*(sw: var Stopwatch) {.inline.}
proc stop*(sw: var Stopwatch) {.inline.}
proc reset*(sw: var Stopwatch) {.inline.}
proc restart*(sw: var Stopwatch) {.inline.}

# Lap functions
proc isRecordingLaps*(sw: var Stopwatch;): bool {.inline.}
proc numLaps*(sw: var Stopwatch; incCur: bool = false): int {.inline.}
proc lap*(sw: var Stopwatch; num: int; incCur: bool = false): int {.inline.}
proc laps*(sw: var Stopwatch; incCur: bool = false): seq[int] {.inline.}
proc rmLap*(sw: var Stopwatch; num: int) {.inline.}
proc clearLaps(sw: var Stopwatch) {.inline.}

# Getting the time of the current lap (or previously ran one, if the stopwatch is stopped)
proc msecs*(sw: var Stopwatch): int {.inline.}
proc secs*(sw: var Stopwatch): float {.inline.}

# These functions include the time for all laps (plus the current lap, if there is one)
proc totalMsecs*(sw: var Stopwatch): int {.inline.}
proc totalSecs*(sw: var Stopwatch): float {.inline.}


# Deprecations from the older Stopwatch module
{.deprecated: [clock: Stopwatch].}
{.deprecated: [seconds: secs].}

# Deprecation for v1.0 -> v1.1
{.deprecated: [newStopwatch: stopwatch].}



#===============#
#== Templates ==#
#===============#

## A simple template that will wrap the `start()` and `stop()` calls around
## a block of code.  Make sure that the passed in Stopwatch has been
## initialized.  If the Stopwatch is already running, it will stop it it first.
template bench*(sw: Stopwatch; body: untyped): untyped =
  sw.stop()
  sw.start()
  body
  sw.stop()


#====================#
#== Internal Procs ==#
#====================#

# This needs to choose a different getTicks_internal() function depending upon 
# the target platform.
proc getTicks_internal(): Ticks =
  {.emit: ["return performance.now();"].}


#===============================#
#== Time Conversion Functions ==#
#===============================#


## Converts milliseconds to seconds (represented as a float)
proc secs*(msecs: int): float =
  return msecs.float / 1_000.0




#=====================#
#== Stopwatch procs ==#
#=====================#

## Creates a new Stopwatch.  It has no laps and isn't running.  If you want to
## turn of lapping then pass `false` to the `enableLapping` paramater.  By
## default it is on.
proc stopwatch*(enableLapping:bool): Stopwatch =
  result = Stopwatch(
    running: false,
    startTicks: 0.Ticks,
    recordLaps: enableLapping,
    previousLap: 0.Ticks,
    laps: if enableLapping: @[] else: nil,
    total: 0
  )


## Clones the state of an existing Stopwatch.  Will copy over it's laps and if
## it is currently running or not.
proc clone*(sw: var Stopwatch): Stopwatch =
  result = Stopwatch(
    running: sw.running,
    startTicks: sw.startTicks,
    recordLaps: sw.recordLaps,
    previousLap: sw.previousLap,
    laps: sw.laps,
    total: sw.total
  )


## Checks to see if the Stopwatch is measuring time.
proc running*(sw: var Stopwatch): bool =
  return sw.running


## Makes the Stopwatch measure time.  Will do nothing if the Stopwatch is
## already doing that.
proc start*(sw: var Stopwatch) =
  # If we are already running, ignore
  if sw.running:
    return

  # Start the lap
  sw.running = true
  sw.startTicks = getTicks_internal()


## Makes the Stopwatch stop measuring time.  It will record the lap it has
## taken.  If the Stopwatch wasn't running before, nothing will happen
proc stop*(sw: var Stopwatch) =
  # First thing, measure the time
  let stopTicks = getTicks_internal()

  # If not running, ignore
  if not sw.running:
    return

  # Get lap time
  let lapTime = stopTicks - sw.startTicks

  # Save it to the laps
  if sw.isRecordingLaps:
    sw.laps.add(lapTime.Ticks)
  sw.previousLap = lapTime.Ticks

  # Add it to the accum
  sw.total += lapTime

  # Reset timer state
  sw.running = false
  sw.startTicks = 0.Ticks


## Clears out the state of the Stopwatch.  This deletes all of the lap data (if
## lapping is enabled) and will stop the stopwatch.
proc reset*(sw: var Stopwatch) =
  sw.running = false
  sw.startTicks = 0.Ticks
  sw.previousLap = 0.Ticks
  sw.total = 0        # Zero the accum

  # Clear the laps
  if sw.isRecordingLaps:
    sw.laps.setLen(0)


## This function will clear out the state of the Stopwatch and tell it to start
## recording time.  It is the same as calling reset() then start().
proc restart*(sw: var Stopwatch) =
  sw.reset()
  sw.start()


## Checks to see if a stopwatch it recording laps or not.  Returns true if so,
## false otherwise
proc isRecordingLaps*(sw: var Stopwatch;): bool =
  return sw.recordLaps

## Returns the number of laps the Stopwatch has recorded so far.  If `incCur` is
## set to `true`, it will include the current lap in the count.  By default it
## set to `false`.
##
## If lapping is not enabled, this will 0
proc numLaps*(sw: var Stopwatch; incCur: bool = false): int =
  if sw.isRecordingLaps:
    return sw.laps.len + (if incCur and sw.running: 1 else: 0)
  else:
    return 0


## Returns the time (in milliseconds) of a lap with the provided index of `num`.
## If `incCur` is set to `true`, it will include the current lap in the range
## (as the last lap).  By default it is set to `false`.  This function can raise
## an `IndexError` if `num` isn't a valid lap index.
##
## If you want to convert the returned value to a different time measurement,
## use one of the functions: `msecs()`, `usecs()` or `secs()`.
##
## If lapping is not enabled then this will return 0
proc lap*(sw: var Stopwatch; num: int; incCur: bool = false): int =
  # Check for not lapping
  if not sw.isRecordingLaps:
    return 0

  # Else we've got laps
  if incCur and sw.running:
    # Check if the index is good or not
    if num < sw.laps.len:
      # Return the previous lap
      return sw.previousLap.int
    elif num == sw.laps.len:
      # Return the current lap
      return sw.msecs
    else:
      # Out of bounds
      raise newException(IndexError, "provided lap number isn't valid.")
  else:
    # only look at completed laps
    return sw.laps[num].int


## Returns a list of all the recorded laps (in milliseconds).  If `incCur` is set
## `true`, then it will include the current lap in the result.  By default it is
## `false`.  If no lap is being recored, than `incCur` will be ignored.
##
## If you want to convert the returned value to a different time measurement,
## use one of the functions: `msecs()`, `usecs()` or `secs()` in conjunction
## with the `map()` function from the `sequtils` module.  Example:
##
## .. code-block:: nim
##   var sw = stopwatch()
##
##   # some time measurements later...
##
##   var lapsSecs = sw2.laps.map(proc(x: int): float = secs(x))
##   echo lapsSecs
##   # --> @[1.000117, 0.500115, 0.200212]
##
## If lapping is turned off this will return an empty sequence
proc laps*(sw: var Stopwatch; incCur: bool = false): seq[int] =
  # Check for lapping=off
  if not sw.isRecordingLaps:
    return @[]

  # Nope, we've got laps
  var
    curLap = sw.msecs
    allLaps = cast[seq[int]](sw.laps)

  if sw.running and incCur:
    allLaps.add(curLap)

  return allLaps


## Removes a lap from the Stopwatch's record with the given index of `num`.
## This function has the possibility of raising an `IndexError`.
##
## If lapping is disabled, this function will do nothing.
proc rmLap*(sw: var Stopwatch; num: int) =
  # Check for no laps
  if not sw.isRecordingLaps:
    return

  # Remove its time from the accum
  let t = sw.laps[num]
  sw.total = sw.total.Ticks - t

  sw.laps.delete(num)


## This clears out all of the lap records from a Stopwatch.  This will not
## effect the current lap (if one is being measured).
##
## If lapping is disabled nothing will happen.
proc clearLaps(sw: var Stopwatch) =
  # Check for no laps
  if not sw.isRecordingLaps:
    return

  sw.laps.setLen(0)
  sw.total = 0
  sw.previousLap = 0.Ticks


## This will return either the length of the current lap (if `stop()` has not
## been called, or the time of the previously measured lap.  The return value is
## in milliseconds.  If no laps have been run yet, then this will return 0.
##
## If lapping is turned off then this will act the same as `totalMsecs()`
proc msecs*(sw: var Stopwatch): int =
  let curTicks = getTicks_internal()

  if sw.running:
    # Return current lap
    return (curTicks - sw.startTicks).int
  elif not sw.isRecordingLaps:
    # Lapping is off
    return sw.previousLap.int
  elif sw.laps.len != 0:
    # Return previous lap
    return sw.previousLap.int
  else:
    # No laps yet
    return 0


## The same as `msecs()`, except the return value is in seconds (as floats).
proc secs*(sw: var Stopwatch): float =
  return secs(sw.msecs)


## This returns the time of all laps combined, plus the current lap (if
## Stopwatch is running).  The return value is in milliseconds.
proc totalMsecs*(sw: var Stopwatch): int =
  let curTicks = getTicks_internal()

  if sw.running:
    # Return total + current lap
    return (sw.total + (curTicks - sw.startTicks)).int
  else:
    return sw.total.int


## The same as `totalMsecs()`, except the return value is in seconds (as a
## float).
proc totalSecs*(sw: var Stopwatch): float =
  return secs(sw.totalMsecs)

