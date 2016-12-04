Stopwatch
=========
This is a fork of rbmz's stopwatch: https://github.com/rbmz/stopwatch
It adds features such as multiple starting & stopping, lapping, and handy time
measurement conversino utility functions.

It is based off of Nim's builting `system/timers` module


Documentation
-------------
All of the functions should be documented in the file `stopwatch.nim`.  At the
top of the file are 




```nim

import stopwatch
from os import sleep

var c: clock

# example without using the bench abstraction
c.start()
sleep(1)
c.stop()
echo ($(c.clockStop - c.clockStart) & "ns") # in nanoseconds
echo c.seconds, "s"

# another example using bench, a template that generates the clock.start/stop code as shown in the first example
var c0, c1, c2: clock

bench(c):
  bench(c0):
    sleep(100)
  bench(c1):
    sleep(50)
  bench(c2):
    for i in 0..<2:
      sleep(1)

echo "bench 0): ", c0.seconds, "s"
echo "bench 1): ", c1.seconds, "s"
echo "bench 2): ", c2.seconds, "s"
echo "total: ", c.seconds, "s"
```
