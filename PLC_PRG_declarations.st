PROGRAM PLC_PRG
VAR
    eState         : INT := 0;
    tonDwell       : TON;
    tonSpindle     : TON;
    tonClamp       : TON;
    bFault         : BOOL;
    bCycleRunning  : BOOL;
END_VAR
