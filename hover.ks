set ship:control:pilotmainthrottle to 0.

// calculate initial hover PID gains
set Kp to 0.01.
set Ki to 0.005.
set Kd to 0.005.
set touchdown to false.
set thr to 0.
lock throttle to thr.

// wait until we reach max alt
wait until ship:verticalspeed < 0.
when alt:radar < 5 then gear on.
when alt:radar < 2 then set touchdown to true.

// descend at -0.2 to -10 m/s
lock setpoint to MIN(-0.2, MAX(-10, -alt:radar / 5)).

lock steer_retro to ship:groundspeed > 1 AND ship:verticalspeed < -1.

function print_status {
	clearscreen.
	print "Alt: " + ROUND(alt:radar, 2) + "         " AT (0, 0).
	print "VSp: " + ROUND(ship:verticalspeed, 2) + "           " AT (0, 1).
        print "Set: " + ROUND(setpoint, 2) + "       " AT (0, 2).
	print "Gsp: " + ROUND(ship:groundspeed, 2) + "       " AT (0, 3).
	print "RE :  " + steer_retro + "     " AT (0, 4).
}

sas off.
rcs on.

set hoverPID to PIDLOOP(Kp, Ki, Kd).
until touchdown {
        set thr to thr + hoverPID:UPDATE(TIME:SECONDS, ship:verticalspeed - setpoint).
	if steer_retro {
		lock steering to srfretrograde.
	} else {
		lock steering to up.
	}
	print_status.
	wait 0.001.
}.

set ship:control:pilotmainthrottle to 0.
unlock all.
clearscreen.
