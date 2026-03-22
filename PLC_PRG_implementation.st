(* ═══════════════════════════════════════ *)
(*  EMERGENCY STOP - checked every scan   *)
(* ═══════════════════════════════════════ *)
IF GVL_IO.bEmergencyStop THEN
    eState := 99;
END_IF

(* ═══════════════════════════════════════ *)
(*  TOOL BREAKAGE CHECK                   *)
(* ═══════════════════════════════════════ *)
IF NOT GVL_IO.bToolOK AND bCycleRunning THEN
    eState := 99;
    bFault := TRUE;
END_IF

(* ═══════════════════════════════════════ *)
(*  STATE MACHINE                         *)
(* ═══════════════════════════════════════ *)
CASE eState OF

0: (* IDLE *)
    GVL_IO.bClampActivate  := FALSE;
    GVL_IO.bSpindleRun     := FALSE;
    GVL_IO.bDrillFeedDown  := FALSE;
    GVL_IO.bDrillFeedUp    := FALSE;
    GVL_IO.bCoolantOn      := FALSE;
    GVL_IO.bGreenLight     := TRUE;
    GVL_IO.bRedLight       := FALSE;
    GVL_IO.bYellowLight    := FALSE;
    bCycleRunning          := FALSE;
    GVL_IO.nCurrentHole    := 0;

    IF GVL_IO.bStartButton
        AND GVL_IO.bPartPresent
        AND GVL_IO.bDrillAtTop
        AND GVL_IO.bToolOK
        AND NOT GVL_IO.bEmergencyStop THEN
        eState := 1;
        bCycleRunning := TRUE;
        GVL_IO.bGreenLight := FALSE;
    END_IF

1: (* CLAMP *)
    GVL_IO.bClampActivate := TRUE;
    tonClamp(IN := TRUE, PT := T#800MS);
    IF tonClamp.Q AND GVL_IO.bClampClosed THEN
        tonClamp(IN := FALSE);
        GVL_IO.nCurrentHole := GVL_IO.nCurrentHole + 1;
        eState := 2;
    END_IF

2: (* SPINDLE START *)
    GVL_IO.bSpindleRun := TRUE;
    tonSpindle(IN := TRUE, PT := T#1S);
    IF tonSpindle.Q THEN
        tonSpindle(IN := FALSE);
        eState := 3;
    END_IF

3: (* COOLANT ON *)
    GVL_IO.bCoolantOn := TRUE;
    eState := 4;

4: (* FEED DOWN *)
    GVL_IO.bDrillFeedDown := TRUE;
    GVL_IO.bDrillFeedUp   := FALSE;
    IF GVL_IO.bDrillAtBottom THEN
        GVL_IO.bDrillFeedDown := FALSE;
        eState := 5;
    END_IF

5: (* DWELL *)
    tonDwell(IN := TRUE, PT := GVL_IO.tDwellTime);
    IF tonDwell.Q THEN
        tonDwell(IN := FALSE);
        eState := 6;
    END_IF

6: (* RETRACT *)
    GVL_IO.bDrillFeedDown := FALSE;
    GVL_IO.bDrillFeedUp   := TRUE;
    IF GVL_IO.bDrillAtTop THEN
        GVL_IO.bDrillFeedUp := FALSE;
        eState := 7;
    END_IF

7: (* CHECK NEXT HOLE *)
    IF GVL_IO.nCurrentHole >= GVL_IO.nTotalHoles THEN
        eState := 8;
    ELSE
        GVL_IO.nCurrentHole := GVL_IO.nCurrentHole + 1;
        eState := 4;
    END_IF

8: (* CYCLE COMPLETE *)
    GVL_IO.bSpindleRun    := FALSE;
    GVL_IO.bCoolantOn     := FALSE;
    GVL_IO.bClampActivate := FALSE;
    GVL_IO.bYellowLight   := TRUE;
    GVL_IO.bGreenLight    := FALSE;
    IF bCycleRunning THEN
        GVL_IO.nCycleCount := GVL_IO.nCycleCount + 1;
    END_IF
    bCycleRunning         := FALSE;

    IF GVL_IO.bResetButton THEN
        GVL_IO.bYellowLight := FALSE;
        eState := 0;
    END_IF

99: (* FAULT / E-STOP *)
    GVL_IO.bSpindleRun    := FALSE;
    GVL_IO.bDrillFeedDown := FALSE;
    GVL_IO.bDrillFeedUp   := FALSE;
    GVL_IO.bCoolantOn     := FALSE;
    GVL_IO.bRedLight      := TRUE;
    GVL_IO.bGreenLight    := FALSE;
    GVL_IO.bYellowLight   := FALSE;
    bCycleRunning         := FALSE;

    IF NOT GVL_IO.bEmergencyStop
        AND GVL_IO.bResetButton THEN
        bFault := FALSE;
        GVL_IO.bRedLight := FALSE;
        eState := 0;
    END_IF

END_CASE
