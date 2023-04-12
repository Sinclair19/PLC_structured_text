PROGRAM Main
VAR
    left_strict AT %IX0.0: BOOL;
    first_place AT %IX0.1: BOOL;
    second_place AT %IX0.2: BOOL;
    third_place AT %IX0.3: BOOL; 
    right_strict AT %IX0.4: BOOL;
    up_strict AT %IX0.5: BOOL;
    down_strict AT %IX0.6: BOOL;

    left AT %QX0.0: BOOL;
    right AT %QX0.1: BOOL;
    up AT %QX0.2: BOOL;
    down AT %QX0.3: BOOL;

    status AT %MW0: INT; //0 stop ; 1 auto;  2 manual; 3 reset
    run_count AT %MW1: INT;
    run_count_set AT%MW2: INT;
    run_count_strict: INT;
    time_show AT %MW3: INT;

    HMI_left_strict AT %MX20.0: BOOL;
    HMI_mid_1 AT %MX21.0: BOOL; // MW1:X8
    HMI_first_place AT %MX20.1: BOOL;
    HMI_mid_2 AT %MX21.1: BOOL;
    HMI_second_place AT %MX20.2: BOOL;
    HMI_mid_3 AT %MX21.2: BOOL;
    HMI_third_place AT %MX20.3: BOOL; 
    HMI_mid_4 AT %MX21.3: BOOL;
    HMI_right_strict AT %MX20.4: BOOL;
    
    HMI_up_strict AT %MX20.5: BOOL;
    HMI_down_strict AT %MX20.6: BOOL;

    HMI_RUN_status AT %MX22.1: BOOL;
    HMI_STOP_status AT %MX22.2: BOOL;
    HMI_RESET_status AT %MX22.3: BOOL;

    HMI_left AT%MX24.0: BOOL;
    HMI_right AT%MX24.1: BOOL;
    HMI_up AT%MX24.2: BOOL;
    HMI_down AT%MX24.3: BOOL;

    mid_1: BOOL;
    mid_2: BOOL;
    mid_3: BOOL;
    mid_4: BOOL;

    pass_left_strict: BOOL;
    pass_first_place: BOOL;
    pass_second_place: BOOL;
    pass_third_place: BOOL; 
    pass_right_strict: BOOL;
    pass_up_strict: BOOL;
    pass_down_strict: BOOL;
    h_direction : BOOL; // 0 left; 1 right;
    v_direction : BOOL; // 0 up; 1 down;

    first_place_time : INT;
    first_place_stand_time : INT;
    second_place_time : INT;
    second_place_stand_time : INT;
    third_place_time : INT;
    third_place_stand_time: INT;

    temp_time : INT;

    progress: BOOL;
    down_to_strict : BOOL;
    up_to_strict : BOOL;
    already_down : BOOL;
    auto_mode_reset : BOOL;

    BLINK_1: BLINK;
    TRIG_1: R_TRIG;

END_VAR

BLINK_1(ENABLE := (status = 1 OR status = 2) , TIMELOW := T#500MS, TIMEHIGH:= T#500MS, OUT => );
TRIG_1(CLK := BLINK_1.OUT, Q => );

first_place_time := 10;
first_place_stand_time := 3;
second_place_time := 8;
second_place_stand_time := 3;
third_place_time := 5;
third_place_stand_time := 3;



// place control
IF left_strict THEN
    pass_left_strict := TRUE;
    pass_first_place := FALSE;
    pass_second_place := FALSE;
    pass_third_place := FALSE;
    pass_right_strict := FALSE;
    pass_up_strict := FALSE;
    pass_down_strict := FALSE;
END_IF
IF pass_left_strict THEN
    mid_1 := TRUE;
END_IF

IF status = 0 THEN
    HMI_RUN_status := FALSE;
    HMI_STOP_status := TRUE;
    HMI_RESET_status := FALSE;
END_IF

IF status = 1 OR status = 2 THEN
    HMI_RUN_status := TRUE;
    HMI_STOP_status := FALSE;
    HMI_RESET_status := FALSE;
END_IF

IF run_count_set = 1 THEN
    run_count_strict := 1;
ELSE
    run_count_strict := -1;
END_IF

IF status = 3 THEN
    run_count := 0;
    time_show := 0;
    IF left_strict = FALSE THEN
        left := TRUE;
        h_direction := FALSE;
    ELSE
        left := FALSE;
    END_IF
    IF up_strict = FALSE THEN
        up := TRUE;
        h_direction := FALSE;
    ELSE
        up := FALSE;
    END_IF
    IF left_strict AND up_strict THEN
        status := 0;
    END_IF
END_IF

IF status = 2 THEN
    IF NOT up_strict THEN
        IF HMI_up THEN
            up := TRUE;
            v_direction := FALSE;
        ELSE
            up := FALSE;
        END_IF
    END_IF
    IF NOT down_strict THEN
        IF HMI_down THEN
            down := TRUE;
            v_direction := TRUE;
        ELSE
            down := FALSE;
        END_IF
    END_IF
    IF NOT left_strict THEN
        IF HMI_left THEN
            left := TRUE;
            h_direction := FALSE;
        ELSE
            left := FALSE;
        END_IF
    END_IF
    IF NOT right_strict THEN
        IF HMI_right THEN
            right := TRUE;
            h_direction := TRUE;
        ELSE
            right := FALSE;
        END_IF
    END_IF
END_IF


IF status = 1 THEN
    IF run_count = run_count_strict THEN
        status := 3;
    ELSE
        IF left_strict THEN
            auto_mode_reset := FALSE;
            progress := TRUE;
        END_IF

        IF progress THEN
            right := TRUE;
            h_direction := TRUE;
        END_IF

        IF first_place THEN
            progress := FALSE;

            IF down_strict THEN
                time_show := first_place_time - temp_time;
                IF time_show = 0 THEN
                    temp_time := 0;
                    already_down := TRUE;
                END_IF
            ELSE
                down := TRUE;
                v_direction := TRUE;
            END_IF   

            IF already_down THEN
                IF up_strict THEN
                    time_show := first_place_stand_time - temp_time;
                    IF time_show = 0 THEN
                        progress := TRUE;
                        already_down := FALSE;
                        temp_time := 0;
                    END_IF
                ELSE
                    up := TRUE;
                    v_direction := FALSE;
                END_IF
            END_IF
        END_IF   

        IF second_place THEN
            progress := FALSE;

            IF down_strict THEN
                time_show := second_place_time - temp_time;
                IF time_show = 0 THEN
                    temp_time := 0;
                    already_down := TRUE;
                END_IF
            ELSE
                down := TRUE;
                v_direction := TRUE;
            END_IF   

            IF already_down THEN
                IF up_strict THEN
                    time_show := second_place_stand_time - temp_time;
                    IF time_show = 0 THEN
                        progress := TRUE;
                        already_down := FALSE;
                        temp_time := 0;
                    END_IF
                ELSE
                    up := TRUE;
                    v_direction := FALSE;
                END_IF
            END_IF
        END_IF

        IF third_place THEN
            progress := FALSE;

            IF down_strict THEN
                time_show := third_place_time - temp_time;
                IF time_show = 0 THEN
                    temp_time := 0;
                    already_down := TRUE;
                END_IF
            ELSE
                down := TRUE;
                v_direction := TRUE;
            END_IF   

            IF already_down THEN
                IF up_strict THEN
                    time_show := third_place_stand_time - temp_time;
                    IF time_show = 0 THEN
                        progress := TRUE;
                        already_down := FALSE;
                        temp_time := 0;
                    END_IF
                ELSE
                    up := TRUE;
                    v_direction := FALSE;
                END_IF
            END_IF
        END_IF
    
        IF right_strict THEN
            progress := FALSE;
            auto_mode_reset := TRUE;
            run_count := run_count + 1;
        END_IF

        IF auto_mode_reset THEN
            right := TRUE;
            h_direction := FALSE;
        END_IF
    
    END_IF
END_IF            


IF TRIG_1.Q THEN
    IF first_place OR second_place OR third_place THEN
        temp_time := temp_time + 1;
    END_IF
END_IF


    

