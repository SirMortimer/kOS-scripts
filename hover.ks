set ship:control:pilotmainthrottle to 0.
until ship:availablethrust > 0 {
  wait 0.5.
  stage.
}.

lock steering to up.
lock g to body:mu / ((ship:altitude + body:radius)^2).

// calculate initial hover PID gains
set Kp to 100.
set Ki to 100.
set Kd to 10.

set hoverPID to PIDLOOP(Kp, Ki, Kd).

on ag5 { set Kd to Kd + 5. print "Kd: " + Kd. set hoverPID:KD to Kd. preserve. }
on ag6 { set Kd to Kd - 5. print "Kd: " + Kd. set hoverPID:KD to Kd. preserve. }
on ag7 { set Ki to Ki + 5. print "Ki: " + Ki. set hoverPID:KI to Ki. preserve. }
on ag8 { set Ki to Ki - 5. print "Ki: " + Ki. set hoverPID:KI to Ki. preserve. }
on ag9 { set Kp to Kp + 5. print "Kp: " + Kp. set hoverPID:KP to Kp. preserve. }
on ag10 { set Kp to Kp - 5. print "Kp: " + Kp. set hoverPID:KP to Kp. preserve. }

gear on. gear off. // on then off because of the weird KSP 'have to hit g twice' bug.

set thr to 0.
lock throttle to thr.

set thr to 1.
wait 1.5.
set thr to 0.
wait until ship:verticalspeed < 2.

until gear {
	// update hover pid and thrust
        set thr to thr + hoverPID:UPDATE(TIME:SECONDS, ship:verticalspeed).
	wait 0.001.
}.

set ship:control:pilotmainthrottle to throttle.
unlock all.

