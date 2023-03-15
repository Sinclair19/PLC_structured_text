PROGRAM Main
VAR
    first_button_g AT %IX0.0: BOOL;  // start
    first_button_y AT %IX0.1: BOOL;
    first_button_r AT %IX0.2: BOOL; //  stop
    second_button_g AT %IX0.3: BOOL;
    second_button_y AT %IX0.4: BOOL;
    second_button_r AT %IX0.5: BOOL;

    ns_car_r AT %QX0.0: BOOL;
    ns_car_y AT %QX0.1: BOOL;
    ns_car_g AT %QX0.2: BOOL;

    ns_human_r AT %QX0.6: BOOL;
    ns_human_g AT %QX0.7: BOOL;    

    we_car_r AT %QX0.3: BOOL;
    we_car_y AT %QX0.4: BOOL;
    we_car_g AT %QX0.5: BOOL;

    we_human_r AT %QX0.8: BOOL;
    we_human_g AT %QX0.9: BOOL; 

    HMI_ns_car_time AT %MW1: INT;
    HMI_we_car_time AT %MW2: INT;
    HMI_ns_human_time AT %MW3: INT;
    HMI_we_human_time AT %MW4: INT;

    ns_r_temp_time: INT;
    we_r_temp_time: INT;
    ns_g_temp_time: INT;
    we_g_temp_time: INT;
    ns_y_temp_time: INT;
    we_y_temp_time: INT;
    ns_human_temp_time: INT;
    we_human_temp_time: INT;
    start: BOOL;
    stop: BOOL; 

    car_red_time : INT;
    car_yellow_time: INT;
    car_green_time: INT;
    human_red_time: INT;
    human_green_time: INT;

    ns_car_go: BOOL;
    ns_car_stop: BOOL;
    ns_human_go: BOOL;
    ns_red: BOOL;
    ns_green: BOOL;
    ns_yellow: BOOL;

    we_car_go: BOOL;
    we_car_stop: BOOL;
    we_human_go: BOOL;
    we_red: BOOL;
    we_green: BOOL;
    we_yellow: BOOL;

    BLINK_1: BLINK;
    TRIG_1: R_TRIG;

END_VAR

car_red_time := 19;
car_green_time := 14;
car_yellow_time := 4;

human_red_time := car_red_time + car_yellow_time + 1; //double 0 have been added, so 
human_green_time := car_green_time;

IF first_button_g THEN
    IF NOT start THEN
        ns_red := TRUE;
        we_green := TRUE;
        HMI_ns_human_time := car_red_time;
        HMI_we_human_time := human_green_time;
    END_IF
    start := TRUE;
    stop := FALSE;
END_IF

IF first_button_r THEN
    start := FALSE;
    stop := TRUE;
END_IF

BLINK_1(ENABLE := (start = TRUE) , TIMELOW := T#500MS, TIMEHIGH:= T#500MS, OUT => );
TRIG_1(CLK := BLINK_1.OUT, Q => );

// clear
IF stop THEN
    ns_r_temp_time := 0;
    we_r_temp_time := 0;
    ns_g_temp_time := 0;
    we_g_temp_time := 0;
    we_y_temp_time := 0;
	ns_y_temp_time := 0;
    ns_human_temp_time := 0;
    we_human_temp_time := 0;
    we_red := FALSE;
    we_green := FALSE;
    we_yellow := FALSE;
    ns_red := FALSE;
    ns_green := FALSE;
    ns_yellow := FALSE;
    ns_car_go := FALSE;
    we_car_go := FALSE;
    ns_human_go := FALSE;
    we_human_go := FALSE;
    we_car_r := FALSE;
    we_car_y := FALSE;
    we_car_g := FALSE;
    we_human_g := FALSE;
    we_human_r := FALSE;
    ns_car_r := FALSE;
    ns_car_y := FALSE;
    ns_car_g := FALSE;
    ns_human_g := FALSE;
    ns_human_r := FALSE;
    HMI_ns_car_time := 0;
    HMI_ns_human_time := 0;
    HMI_we_car_time := 0;
    HMI_we_human_time := 0;
END_IF

// time

IF ns_red THEN
    ns_car_go := FALSE;
    ns_human_go := FALSE;
    if ns_r_temp_time = car_red_time + 1 THEN // 19 equals to 20 second because of 0 
        ns_r_temp_time := 0;
        HMI_ns_car_time := car_green_time;

        ns_human_temp_time := 0;
        HMI_ns_human_time := human_green_time;
        
        ns_red := FALSE;
        ns_green := TRUE;
    END_IF 
END_IF

IF we_red THEN
    we_car_go := FALSE;
    we_human_go := FALSE;
    IF we_r_temp_time = car_red_time + 1 THEN
        we_r_temp_time := 0;
        HMI_we_car_time := car_green_time;

        we_human_temp_time := 0;
        HMI_we_human_time := human_green_time;
        
        we_red:= FALSE;
        we_green := TRUE;
    END_IF 
END_IF

IF ns_green THEN
    ns_car_go := TRUE;
    ns_human_go := TRUE;
    IF ns_g_temp_time = car_green_time + 1 THEN
        ns_g_temp_time := 0;
        HMI_ns_car_time := car_yellow_time;
        
        ns_human_temp_time := 0;
        HMI_ns_human_time := human_red_time;
        
        ns_yellow := TRUE;
        ns_green := FALSE;
    END_IF 
END_IF

IF we_green THEN
    we_car_go := TRUE;
    we_human_go := TRUE;
    IF we_g_temp_time = car_green_time + 1 THEN
        we_g_temp_time := 0;
        HMI_we_car_time := car_yellow_time;
        
        we_human_temp_time := 0;
        HMI_we_human_time := human_red_time;
        
        we_yellow := TRUE;
        we_green := FALSE;
    END_IF 
END_IF

IF ns_yellow THEN
    ns_car_y := TRUE;
    ns_car_g := FALSE;
    ns_car_r := FALSE;
    ns_human_go := FALSE;
    IF ns_y_temp_time = car_yellow_time + 1 THEN
        ns_y_temp_time := 0;
        HMI_ns_car_time := car_red_time;
        
        ns_car_y := FALSE;
        ns_yellow := FALSE;
        ns_red := TRUE;
    END_IF
    //
END_IF


IF we_yellow THEN
    we_car_y := TRUE;
    we_car_r := FALSE;
    we_car_g := FALSE;
    we_human_go := FALSE;
    IF we_y_temp_time = car_yellow_time + 1 THEN
        we_y_temp_time := 0;
        HMI_we_car_time := car_red_time;
        
        we_car_y := FALSE;
        we_yellow := FALSE;
        we_red := TRUE;
	END_IF
END_IF

IF ns_car_go THEN
    ns_car_r := FALSE;
    ns_car_g := TRUE;
ELSIF (NOT ns_car_go AND start) THEN
    ns_car_r := TRUE;
    ns_car_g := FALSE;
END_IF

IF we_car_go THEN
    we_car_r := FALSE;
    we_car_g := TRUE;
ELSIF (NOT we_car_go AND start) THEN
    we_car_r := TRUE;
    we_car_g := FALSE;
END_IF

IF ns_human_go THEN
    ns_human_g := TRUE;
    ns_human_r := FALSE;
ELSIF (ns_human_go = FALSE AND start = TRUE) THEN
    ns_human_g := FALSE;
    ns_human_r := TRUE;
END_IF;

IF we_human_go THEN
    we_human_g := TRUE;
    we_human_r := FALSE;
ELSIF (we_human_go = FALSE AND start = TRUE) THEN
    we_human_g := FALSE;
    we_human_r := TRUE;
END_IF;

IF TRIG_1.Q THEN
    IF ns_red THEN
        ns_r_temp_time := ns_r_temp_time + 1;
        HMI_ns_car_time := car_red_time - ns_r_temp_time;
    END_IF
    IF we_red THEN
        we_r_temp_time := we_r_temp_time + 1;
        HMI_we_car_time := car_red_time - we_r_temp_time;
    END_IF
    IF ns_green THEN
        ns_g_temp_time := ns_g_temp_time + 1;
        HMI_ns_car_time := car_green_time - ns_g_temp_time;
    END_IF
    IF we_green THEN
        we_g_temp_time := we_g_temp_time + 1;
        HMI_we_car_time := car_green_time - we_g_temp_time;
    END_IF
    IF ns_yellow THEN
        ns_y_temp_time := ns_y_temp_time + 1;
        HMI_ns_car_time := car_yellow_time - ns_y_temp_time;
    END_IF
    IF we_yellow THEN
        we_y_temp_time := we_y_temp_time + 1;
        HMI_we_car_time := car_yellow_time - we_y_temp_time;
    END_IF
    // human
    IF (ns_human_go AND ns_green) THEN
        ns_human_temp_time := ns_human_temp_time + 1;
        HMI_ns_human_time := human_green_time - ns_human_temp_time;
    END_IF
    IF (NOT ns_human_go AND NOT ns_green)THEN
        ns_human_temp_time := ns_human_temp_time + 1;
        HMI_ns_human_time := human_red_time - ns_human_temp_time;
    END_IF
    IF (we_human_go AND we_green) THEN
        we_human_temp_time := we_human_temp_time + 1;
        HMI_we_human_time := human_green_time - we_human_temp_time;
    END_IF
    IF (NOT we_human_go AND NOT we_green) THEN
        we_human_temp_time := we_human_temp_time + 1;
        HMI_we_human_time := human_red_time - we_human_temp_time;
    END_IF 
END_IF