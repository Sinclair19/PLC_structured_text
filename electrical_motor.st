PROGRAM Main
VAR
	AI_FRQ	AT %IW2: INT;
	AO_FRQ	AT %QW2: INT;
	DI_RUN	AT %IX0.0: BOOL;
	DI_ERR	AT %IX0.1: BOOL;
	DI_AUTO	AT %IX0.2: BOOL;
	DO_RUN	AT %QX0.0: BOOL;
	DO_FWD	AT %QX0.4: BOOL;
	DO_BKW	AT %QX0.5: BOOL;
	EN_AI_HZ	AT %QX1.1: BOOL;
	Control_Mode	AT %MW0: INT;
	HMI_SHOW_Hz	AT %MW1: INT;
	HMI_SHOW_Err	AT %MW2: INT;
	HMI_SHOW_RUN	AT %MW3: INT;
	HMI_SHOW_NONE	AT %MW4: INT;
	HMI_SET_FWD	AT %MW6: INT;
	HMI_SET_BCK	AT %MW7: INT;
	HMI_SET_Fr_GiveAQ AT %MW10: INT;
	RUN_TIME AT %MD11: REAL;
	HMI_SET_FR	AT %MD12: REAL;
	CurveSet_Hz	: REAL;
	CurveSet_Count : DINT;
	BLINK01 : BLINK;
	BLINK02 : BLINK;
	BLINK03 : BLINK;
	R_TRIG01 : R_TRIG;
	R_TRIG02 : R_TRIG;
	R_TRIG03 : R_TRIG;

	Run_count: DINT;
	Run_fre: REAL;
END_VAR


HMI_SHOW_Hz	:= AI_FRQ;
IF HMI_SET_FR >= 0.0 AND HMI_SET_FR <= 50.0 THEN
	HMI_SET_Fr_GiveAQ := REAL_TO_INT(HMI_SET_FR * 100.0);
END_IF
CASE control_mode OF
	1: AO_FRQ := HMI_SET_Fr_GiveAQ;
	2: AO_FRQ := REAL_TO_INT(Run_fre);
	3: AO_FRQ := REAL_TO_INT(CurveSet_Hz);
	4: AO_FRQ := REAL_TO_INT(Run_fre);
	0: AO_FRQ := 0;
END_CASE

EN_AI_HZ := (control_mode = 1) OR (control_mode = 3) OR (control_mode = 2) OR (control_mode = 4);

HMI_SHOW_Err := BOOL_TO_INT(DI_ERR);
HMI_SHOW_RUN := BOOL_TO_INT(DI_RUN);
HMI_SHOW_NONE := BOOL_TO_INT(DI_AUTO);
DO_RUN := INT_TO_BOOL(HMI_SET_FWD) OR INT_TO_BOOL(HMI_SET_BCK);
DO_FWD := INT_TO_BOOL(HMI_SET_FWD);
DO_BKW := INT_TO_BOOL(HMI_SET_BCK);

BLINK01(ENABLE := (control_mode = 3) , TIMELOW := T#50MS, TIMEHIGH:= T#50MS, OUT => );
BLINK02(ENABLE := (control_mode = 2) , TIMELOW := T#50MS, TIMEHIGH:= T#50MS, OUT => );
BLINK03(ENABLE := (control_mode = 4) , TIMELOW := T#50MS, TIMEHIGH:= T#50MS, OUT => );

R_TRIG01(CLK := BLINK01.OUT, Q => );
R_TRIG02(CLK := BLINK02.OUT, Q => );
R_TRIG03(CLK := BLINK03.OUT, Q => );

IF (control_mode = 0) THEN
	Run_fre := 0.0;
	RUN_TIME := 0.0;
	Run_count := 0;
	CurveSet_Count := 0;
END_IF

IF (control_mode = 2) THEN
	Run_fre := 4500.0;
	HMI_SET_FWD := BOOL_TO_INT(Run_count <= 600);
	HMI_SET_BCK := BOOL_TO_INT((Run_count > 600) AND (Run_count <= 1200));
	IF Run_count > 1200 THEN
		Run_fre := 0.0;
		Run_count := 0;
		RUN_TIME := 0.0;
		control_mode := 0;
	END_IF
END_IF

IF R_TRIG02.Q AND Run_Count <= 1200 THEN
	Run_count := Run_count + 1;
	RUN_TIME := RUN_TIME + 1;
END_IF

IF (control_mode = 3) THEN
	HMI_SET_FWD := BOOL_TO_INT((CurveSet_Count <= 1800) AND (CurveSet_Count >0));	
END_IF

IF R_TRIG01.Q AND CurveSet_Count <= 1800 THEN
	IF (CurveSet_Count = 0) THEN
		CurveSet_Hz := 0.0;
	END_IF
	CurveSet_Count := CurveSet_Count + 1;
	RUN_TIME := RUN_TIME + 1;
	
	IF CurveSet_Count > 0 AND CurveSet_Count <= 450 THEN
		CurveSet_Hz := CurveSet_Hz + (2500.0/450.0);
	END_IF
	IF CurveSet_Count > 450 AND CurveSet_Count <= 600 THEN
		CurveSet_Hz := CurveSet_Hz - (2500.0/150.0);
	END_IF
	IF CurveSet_Count > 600 AND CurveSet_Count <= 900 THEN
		CurveSet_Hz := CurveSet_Hz + (2500.0/300.0);
	END_IF
	IF CurveSet_Count > 900 AND CurveSet_Count <= 1200 THEN
		CurveSet_Hz := CurveSet_Hz - (2500.0/300.0);
	END_IF
	IF CurveSet_Count > 1200 AND CurveSet_Count <= 1500 THEN
		CurveSet_Hz := CurveSet_Hz + (2500.0/300.0);
	END_IF
	IF CurveSet_Count > 1500 AND CurveSet_Count <= 1800 THEN
		CurveSet_Hz := CurveSet_Hz - (2500.0/300.0);
	END_IF
	IF CurveSet_Count > 1800 THEN
		CurveSet_Count := 0;
		CurveSet_Hz := 0.0;
		RUN_TIME := 0.0;
		control_mode := 0;
	END_IF
END_IF

IF R_TRIG03.Q THEN
	Run_count := Run_count + 1;
	RUN_TIME := RUN_TIME + 1;
END_IF

IF (control_mode = 4) THEN
	HMI_SET_FWD := 1;
	IF Run_count MOD 100 = 0 THEN
		IF Run_fre <= 4500 THEN
			//Run_fre := Run_fre + 16.6;
			Run_fre := Run_count;
		END_IF
	END_IF
END_IF
