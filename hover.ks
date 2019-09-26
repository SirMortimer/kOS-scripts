set ship:control:pilotmainthrottle to 0.
set thr to 0.
lock throttle to thr.

// descend at -0.2 to -10 m/s
lock setpoint to MIN(-0.2, MAX(-10, -alt:radar / 5)).

function print_status {
	clearscreen.
	print "Alt: " + ROUND(alt:radar, 2) + "         " AT (0, 0).
	print "VSp: " + ROUND(ship:verticalspeed, 2) + "           " AT (0, 1).
        print "Set: " + ROUND(setpoint, 2) + "       " AT (0, 2).
	print "Gsp: " + ROUND(ship:groundspeed, 2) + "       " AT (0, 3).
}

set Kp to 0.01.
set Ki to 0.005.
set Kd to 0.005.
set hoverPID to PIDLOOP(Kp, Ki, Kd).

set touchdown to false.
when alt:radar < 5 and ship:verticalspeed >= 0 set touchdown to true.
when alt:radar < 10 gear on.

lock steering to up.
sas off.
rcs on.

until touchdown {
        set thr to thr + hoverPID:UPDATE(TIME:SECONDS, ship:verticalspeed - setpoint).
	print_status.
	wait 0.001.
}.

set ship:control:pilotmainthrottle to 0.
sas off.
rcs off.
unlock all.
clearscreen.
