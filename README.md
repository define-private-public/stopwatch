Stopwatch
=========
This is a fork of rbmz's stopwatch: https://github.com/rbmz/stopwatch
It adds features such as multiple starting & stopping, lapping, and handy time
measurement conversion utility functions.

It is based off of Nim's builting `system/timers` module

The offical repo can be found here:
https://gitlab.com/define-private-public/stopwatch

All other places should be considered mirrors.


Documentation
-------------
All of the functions should be documented in the file `stopwatch.nim`.  At the
top of the file are function prototypes.  Their definition and documentation is
found after the deprecation markers.

The Stopwatch is "lap-based," meaning that it can make multiple measurements and
store them.  So for instance, if you created a new Stopwatch, then call the
`start()` and `stop()` methods twice (in that order).  It would have recorded
two completed laps.  You can retrive the laps by using the `laps()` function or
`lap()`.

After calling `start()`, a lap begins.  You can query it's elapsed time by
calling a function like `nsecs()` or `secs()` on the Stopwatch object; there
exist other methods to get measurements in different time formats.

There exist more functions than what is described here.  Read the documentation
in `stopwatch.nim` to find out.  Some samples are at the end of this document.


Breaking Changes
----------------
Here is what has changed names:

 - `clock` -> `Stopwatch`
 - `nanoseconds` -> `nsecs`
 - `seconds` -> `secs`

All of the fields in `Stopwatch` have been marked invisible.


Examples
--------

Simple usage:

```nim
import stopwatch

var sw = stopwatch()
sw.start()
# ... Long computation time
sw.stop()

let totalSeconds = sw.secs  # Gets the time of the previous lap in this case
```


Using laps, record only the code you want to time:

```
import stopwatch
from sequtils import map

var sw = stopwatch()

# We're operating on a large image...
for y in countup(0, imgHeight - 1):
  for x in countup(0, imgWidth -1 ):
    sw.start()
    # ... lengthy pixel operation
    sw.stop()

# Query an individual lap's time
let firstPixelTime = sw.lap(0).msecs    # Gets time in milliseconds

# Total time (all laps) in microseconds
let micros = sw.totalUsecs

# Get each lap's time into seconds from nanoseconds (as a seq[float])
let lapsSecs = sw.laps.map(proc(x: int64): float = secs(x))
```

