import stopwatch
from os import sleep

var sw = newStopwatch()

sw.start()
sleep(1000)
sw.stop()

echo sw.secs
#echo sw.msecs
#echo sw.usecs
echo sw.nsecs

