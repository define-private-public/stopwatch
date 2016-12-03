import stopwatch
from os import sleep

var sw = newStopwatch()

echo "total=", sw.totalSecs

sw.start()
sleep(1000)
echo "total=", sw.totalSecs
sw.stop()

echo sw.secs
#echo sw.msecs
#echo sw.usecs
#echo sw.nsecs
echo "total=", sw.totalSecs
echo ""

sw.start()
sleep(500)
echo "total=", sw.totalSecs
echo sw.secs
sw.stop()
echo sw.secs
echo "total=", sw.totalSecs
echo ""


sw.start()
echo sw.secs
sleep(100)
echo sw.secs
echo sw.secs
echo sw.secs
echo "total=", sw.totalSecs
echo sw.secs
echo sw.secs
sleep(100)
sw.stop()
echo sw.secs
echo "total=", sw.totalSecs
echo ""

sw.reset()
sw.start()
sleep(10)
echo "total=", sw.totalSecs
sw.restart()
echo "total=", sw.totalSecs
sleep(250)
echo "total=", sw.totalSecs

