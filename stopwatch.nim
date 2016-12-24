# File:         stopwatch.nim
# Authors:      Benjamin N. Summerton <define-private-public>
#               rbmz
# License:      MIT; See the file `LICENSE` for details.
# Description:  A handly Stopwatch for timing code execution and other things.


from times import epochTime


# Handy conversion functions
proc msecs*(secs: float): float {.inline.}
proc usecs*(secs: float): float {.inline.}
proc nsecs*(secs: float): float {.inline.}


# The Stopwatch object
type
  Stopwatch* = object
    running: bool
    startTicks: float 
    laps: seq[float]
    total: float

# Basic stopwatch functionality
proc stopwatch*(): Stopwatch
proc clone*(sw: var Stopwatch): Stopwatch
proc running*(sw: var Stopwatch): bool {.inline.}
proc start*(sw: var Stopwatch) {.inline.}
proc stop*(sw: var Stopwatch) {.inline.}
proc reset*(sw: var Stopwatch) {.inline.}
proc restart*(sw: var Stopwatch) {.inline.}

# Lap functions
proc numLaps*(sw: var Stopwatch; incCur: bool = false): int {.inline.}
proc lap*(sw: var Stopwatch; num: int; incCur: bool = false): float {.inline.}
proc laps*(sw: var Stopwatch; incCur: bool = false): seq[float] {.inline.}
proc rmLap*(sw: var Stopwatch; num: int) {.inline.}
proc clearLaps(sw: var Stopwatch) {.inline.}

# Getting the time of the current lap (or previously ran one, if the stopwatch is stopped)
proc secs*(sw: var Stopwatch): float {.inline.}
proc msecs*(sw: var Stopwatch): float {.inline.}
proc usecs*(sw: var Stopwatch): float {.inline.}
proc nsecs*(sw: var Stopwatch): float {.inline.}

# These functions include the time for all laps (plus the current lap, if there is one)
proc totalSecs*(sw: var Stopwatch): float {.inline.}
proc totalMsecs*(sw: var Stopwatch): float {.inline.}
proc totalUsecs*(sw: var Stopwatch): float {.inline.}
proc totalNsecs*(sw: var Stopwatch): float {.inline.}


# Deprecations from the older Stopwatch module
{.deprecated: [clock: Stopwatch].}
{.deprecated: [nanoseconds: nsecs].}
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



#===============================#
#== Time Conversion Functions ==#
#===============================#


## Converts seconds to microseconds
proc msecs*(secs: float): float =
  return secs * 1_000


## Converts seconds to microseconds
proc usecs*(secs: float): float =
  return secs * 1_000_000


## Converts seconds to nanoseconds
proc nsecs*(secs: float): float =
  return secs * 1_000_000_000.0




#=====================#
#== Stopwatch procs ==#
#=====================#

## Creates a new Stopwatch.  It has no laps and isn't running
proc stopwatch*(): Stopwatch =
  result = Stopwatch(
    running: false,
    startTicks: 0,
    laps: @[],
    total: 0
  )


## Clones the state of an existing Stopwatch.  Will copy over it's laps and if
## it is currently running or not.
proc clone*(sw: var Stopwatch): Stopwatch =
  result = Stopwatch(
    running: sw.running,
    startTicks: sw.startTicks,
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
  sw.startTicks = epochTime()


## Makes the Stopwatch stop measuring time.  It will record the lap it has
## taken.  If the Stopwatch wasn't running before, nothing will happen
proc stop*(sw: var Stopwatch) =
  # First thing, measure the time
  let stopTicks = epochTime()

  # If not running, ignore
  if not sw.running:
    return

  # save the lap that we just made (and add it to the accum)
  let lapTime = stopTicks - sw.startTicks
  sw.laps.add(lapTime)
  sw.total += lapTime

  # Reset timer state
  sw.running = false
  sw.startTicks = 0


## Clears out the state of the Stopwatch.  This deletes all of the lap data and
## will make it stop measuring time.
proc reset*(sw: var Stopwatch) =
  sw.running = false
  sw.startTicks = 0
  sw.laps.setLen(0)   # Clear the laps
  sw.total = 0        # Zero the accum


## This function will clear out the state of the Stopwatch and tell it to start
## recording time.  It is the same as calling reset() then start().
proc restart*(sw: var Stopwatch) =
  sw.reset()
  sw.start()


## Returns the number of laps the Stopwatch has recorded so far.  If `incCur` is
## set to `true`, it will include the current lap in the count.  By default it
## set to `false`.
proc numLaps*(sw: var Stopwatch; incCur: bool = false): int =
  return sw.laps.len + (if incCur and sw.running: 1 else: 0)


## Returns the time (in seconds) of a lap with the provided index of `num`.
## If `incCur` is set to `true`, it will include the current lap in the range
## (as the last lap).  By default it is set to `false`.  This function can raise
## an `IndexError` if `num` isn't a valid lap index.
##
## If you want to convert the returned value to a different time measurement,
## use one of the functions: `msecs()`, `usecs()` or `nsecs()`.
proc lap*(sw: var Stopwatch; num: int; incCur: bool = false): float =
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


## Returns a list of all the recorded laps (in seconds).  If `incCur` is set
## `true`, then it will include the current lap in the result.  By default it is
## `false`.  If no lap is being recored, than `incCur` will be ignored.
##
## If you want to convert the returned value to a different time measurement,
## use one of the functions: `msecs()`, `usecs()` or `nsecs()` in conjunction
## with the `map()` function from the `sequtils` module.  Example:
##
## .. code-block:: nim
##   var sw = stopwatch()
##
##   # some time measurements later...
##
##   var lapsMsecs = sw2.laps.map(proc(x: float): float = msecs(x))
##   echo lapsMsecs
##   # --> @[1000.117, 500.115, 200.212]
proc laps*(sw: var Stopwatch; incCur: bool = false): seq[float] =
  var
    curLap = sw.secs
    allLaps = sw.laps

  if sw.running and incCur:
    allLaps.add(curLap)

  return allLaps


## Removes a lap from the Stopwatch's record with the given index of `num`.
## This function has the possibility of raising an `IndexError`.  
proc rmLap*(sw: var Stopwatch; num: int) =
  # Remove its time from the accum
  let t = sw.laps[num]
  sw.total -= t

  sw.laps.delete(num)


## This clears out all of the lap records from a Stopwatch.  This will not
## effect the current lap (if one is being measured).
proc clearLaps(sw: var Stopwatch) =
  sw.laps.setLen(0)
  sw.total = 0


## This will return either the length of the current lap (if `stop()` has not
## been called, or the time of the previously measured lap.  The return value is
## in seconds.  If no laps have been run yet, then this will return 0.
##
## See also: `usecs()`, `msecs()`, `secs()`
proc secs*(sw: var Stopwatch): float =
  let curTicks = epochTime()

  if sw.running:
    # Return current lap
    return (curTicks - sw.startTicks)
  elif sw.laps.len != 0:
    # Return previous lap
    return sw.laps[high(sw.laps)]
  else:
    # No laps yet
    return 0


## The same as `secs()`, except the return value is in milliseconds.
##
## See also: `secs()`, `usecs()`, `nsecs()`
proc msecs*(sw: var Stopwatch): float =
  return msecs(sw.secs)


## The same as `secs()`, except the return value is in microseconds.
##
## See also: `ssecs()`, `msecs()`, `nsecs()`
proc usecs*(sw: var Stopwatch): float =
  return usecs(sw.secs)


## The same as `secs()`, except the return value is in nanoseconds
##
## See also: `ssecs()`, `usecs()`, `msecs()`
proc nsecs*(sw: var Stopwatch): float =
  return nsecs(sw.secs)


## This returns the time of all laps combined, plus the current lap (if
## Stopwatch is running).  The return value is in seconds.
##
## See also: `totalUsecs()`, `totalMsecs()`, `totalSecs()`
proc totalSecs*(sw: var Stopwatch): float =
  let curTicks = epochTime()

  if sw.running:
    # Return total + current lap
    return (sw.total + (curTicks - sw.startTicks))
  else:
    return sw.total


## The same as `totalSecs()`, except the return value is in milliseconds.
##
## See also: `totalSecs()`, `totalUsecs()`,`totalNSecs()`
proc totalMsecs*(sw: var Stopwatch): float =
  return msecs(sw.totalSecs)


## The same as `totalSecs()`, except the return value is in microseconds.
##
## See also: `totalSecs()`, `totalMsecs()`, `totalNSecs()`
proc totalUsecs*(sw: var Stopwatch): float =
  return usecs(sw.totalSecs)


## The same as `totalSecs()`, except the return value is in nanoseconds
##
## See also: `totalSecs()`, `totalUsecs()`, `totalMsecs()`
proc totalNsecs*(sw: var Stopwatch): float =
  return nsecs(sw.totalSecs)

