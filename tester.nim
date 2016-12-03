import stopwatch
from os import sleep

var sw = newStopwatch()

sw.start()
sleep(1000)
sw.stop()

echo sw.secs
#echo sw.msecs
#echo sw.usecs
#echo sw.nsecs
echo ""

sw.start()
sleep(500)
echo sw.secs
sw.stop()
echo sw.secs
echo ""


sw.start()
echo sw.secs
sleep(100)
echo sw.secs
echo sw.secs
echo sw.secs
echo sw.secs
echo sw.secs
sleep(100)
sw.stop()
echo sw.secs

