import stopwatch
from os import sleep
from sequtils import map


var sw = stopwatch()
echo "laps=", sw.laps(true)

echo "total=", sw.totalSecs
sw.start()
echo "laps=", sw.laps(true)
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
echo "lapCount=", sw.numLaps(false)
echo "lapCount=", sw.numLaps(true)
echo sw.secs
echo sw.secs
sleep(100)
sw.stop()
echo sw.secs
echo "total=", sw.totalSecs
echo ""

var sw2 = sw.clone()

echo "lapCount=", sw.numLaps
echo "L1=", sw.lap(0)
echo "L2=", sw.laps[1]
sw.rmLap(0)
echo "all laps=", sw.laps
echo "lapCount=", sw.numLaps
echo "----"
echo "lapCount=", sw2.numLaps

var lapsMsecs = sw2.laps.map(proc(x: float): float = msecs(x))

echo "all laps(ms)=", lapsMsecs
echo ""

sw.reset()
echo "lapCount=", sw.numLaps
sw.start()
sleep(10)
echo "total=", sw.totalSecs
sw.restart()
echo "total=", sw.totalSecs
sleep(250)
echo "total(s)=", sw.totalSecs
echo "total(m)=", sw.totalMsecs
echo "total(u)=", sw.totalUsecs
echo "total(n)=", sw.totalNsecs
echo ""

bench(sw, sleep(1000))
echo "bench(sleep(1000))=", sw.secs

