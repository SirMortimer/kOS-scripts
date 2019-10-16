set ship:control:pilotmainthrottle to 0.
set thr to 0.
lock throttle to thr.

lock setpoint to MIN(-0.5, MAX(-50, -alt:radar / 5)).

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

when alt:radar < 5 and ship:verticalspeed >= 0 then set touchdown to true.
when alt:radar < 10 then gear on.
when alt:radar < 15 then lock steering to up.
when ship:verticalspeed > -0.1 then { lock steering to up. preserve. }
when ship:verticalspeed < -10 then { lock steering to srfretrograde. preserve. }

lock steering to srfretrograde.
sas off.
rcs on.

set thr to 1.
until setpoint - ship:verticalspeed > -5 {
	print_status.
	wait 0.001.
}
set thr to 0.

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
