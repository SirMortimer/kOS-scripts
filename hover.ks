SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
SET thr TO 0.
LOCK THROTTLE TO thr.

SET setpoint TO 0.

FUNCTION print_status {
	PRINT "Alt: " + ROUND(ALT:RADAR, 2) + "         " AT (0, 0).
	PRINT "VSp: " + ROUND(SHIP:VERTICALSPEED, 2) + "           " AT (0, 1).
        PRINT "Set: " + ROUND(setpoint, 2) + "       " AT (0, 2).
	PRINT "Gsp: " + ROUND(SHIP:GROUNDSPEED, 2) + "       " AT (0, 3).
}

FUNCTION handle_input {
	IF NOT TERMINAL:INPUT:HASCHAR RETURN.

	SET ch TO TERMINAL:INPUT:GETCHAR().
	IF ch = TERMINAL:INPUT:UPCURSORONE {
		SET setpoint TO setpoint + 0.25.
	}
	IF ch = TERMINAL:INPUT:DOWNCURSERONE {
		SET setpoint TO setpoint - 0.25.
	}
	IF ch = "x" {
		SET SHIP:CONTROL:PILOTMAINTHROTTLE TO thr.
		UNLOCK all.
		CLEARSCREEN.
		die.
	}
}

SET Kp TO 0.01.
SET Ki TO 0.005.
SET Kd TO 0.005.
SET hoverPID TO PIDLOOP(Kp, Ki, Kd).

SET touchdown TO FALSE.
WHEN ALT:RADAR < 5 AND SHIP:VERTICALSPEED >= 0 SET touchdown TO TRUE.
WHEN ALT:RADAR < 15 GEAR ON.

SAS ON.
RCS ON.

UNTIL touchdown {
	handle_input.
        SET thr TO thr + hoverPID:UPDATE(TIME:SECONDS, SHIP:VERTICALSPEED - setpoint).
	print_status.
	WAIT 0.001.
}.

SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
SAS OFF.
RCS OFF.
UNLOCK all.
