VAR_GLOBAL
    bPartPresent       : BOOL;
    bClampClosed       : BOOL;
    bDrillAtTop        : BOOL;
    bDrillAtBottom     : BOOL;
    bToolOK            : BOOL;
    bEmergencyStop     : BOOL;
    bStartButton       : BOOL;
    bResetButton       : BOOL;

    bClampActivate     : BOOL;
    bSpindleRun        : BOOL;
    bDrillFeedDown     : BOOL;
    bDrillFeedUp       : BOOL;
    bCoolantOn         : BOOL;
    bGreenLight        : BOOL;
    bRedLight          : BOOL;
    bYellowLight       : BOOL;

    nCycleCount        : INT;
    nCurrentHole       : INT;
    nTotalHoles        : INT := 6;
    rSpindleSpeed      : REAL := 8000.0;
    rFeedRate          : REAL := 0.05;
    tDwellTime         : TIME := T#500MS;
END_VAR
