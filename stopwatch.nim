# File:         stopwatch.nim
# Authors:      Benjamin N. Summerton <define-private-public>
#               rbmz
# License:      MIT; See the file `LICENSE` for details.
# Description:  A handly Stopwatch for timing code execution and other things.


include system/timers

# Because of issues with 64 integers in browser JS, we need to do this
when defined(js) and not defined(nodejs):
  # For browser JS
  include stopwatch/js_target

else:
  # For Everthing else
  include stopwatch/regular


