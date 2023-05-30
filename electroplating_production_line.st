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

    left_temp: BOOL;
    right_temp: BOOL;
    up_temp: BOOL;
    down_temp: BOOL;
    status_temp : INT;
    time_show_temp : INT;

    status AT %MW0: INT; //0 stop ; 1 auto;  2 manual; 3 reset; 4 pause;
    pause AT %MX30.0: BOOL;
    paused: BOOL;
    run_count AT %MW1: INT;
    run_count_set AT%MX4.0: BOOL;
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
    HMI_up_down_mid AT %MX20.6: BOOL;
    HMI_down_strict AT %MX20.7: BOOL;

    HMI_RUN_status AT %MX22.1: BOOL;
    HMI_STOP_status AT %MX22.2: BOOL;
    HMI_RESET_status AT %MX22.3: BOOL;

    HMI_left AT%MX24.0: BOOL;
    HMI_right AT%MX24.1: BOOL;
    HMI_up AT%MX24.2: BOOL;
    HMI_down AT%MX24.3: BOOL;

    HMI_turn_left AT%MX24.4: BOOL;
    HMI_turn_right AT%MX24.5: BOOL;
    HMI_turn_up AT%MX24.6: BOOL;
    HMI_turn_down AT%MX24.7: BOOL;

    HMI_TIME_SET AT%MX26.0: BOOL;
    HMI_TIME_DEFAULT AT%MX26.1: BOOL;
    SET_TIME: BOOL;

    HMI_first_place_time AT%MW30: INT;
    HMI_first_place_stand_time AT%MW31: INT;
    HMI_second_place_time AT%MW32: INT;
    HMI_second_place_stand_time AT%MW33: INT;
    HMI_third_place_time AT%MW34: INT;
    HMI_third_place_stand_time AT%MW35: INT;

    HMI_run_count_strict AT%MW36: INT;

    pass_left_strict: BOOL;
    pass_first_place: BOOL;
    pass_second_place: BOOL;
    pass_third_place: BOOL; 
    pass_right_strict: BOOL;
    pass_up_strict: BOOL;
    pass_down_strict: BOOL;
    h_direction : INT; // 1 left; 2 right;
    v_direction : INT; // 1 up; 2 down;

    first_place_time: INT;
    first_place_stand_time: INT;
    second_place_time: INT;
    second_place_stand_time: INT;
    third_place_time: INT;
    third_place_stand_time: INT;

    current_basic_time: INT;
    start_timing: BOOL;
    temp_time: INT;
	soft_delay_right: BOOL;
	soft_delay_left: BOOL;

    right_progress: BOOL;
	down_progress: BOOL;
    down_to_strict : BOOL;
    up_to_strict : BOOL;
    already_down : BOOL;
	already_first_place: BOOL;
	already_second_place: BOOL;
	already_third_place: BOOL;
    already_right_place: BOOL;
    auto_mode_reset : BOOL;

    BLINK_1: BLINK;
    TRIG_1: R_TRIG;

END_VAR

BLINK_1(ENABLE := (status = 1 OR status = 2) , TIMELOW := T#500MS, TIMEHIGH:= T#500MS, OUT => );
TRIG_1(CLK := BLINK_1.OUT, Q => );


IF HMI_TIME_SET THEN
	SET_TIME := TRUE;
END_IF

IF HMI_TIME_DEFAULT THEN
	SET_TIME := FALSE;
END_IF

IF SET_TIME THEN
    first_place_time := HMI_first_place_time;
    first_place_stand_time := HMI_first_place_stand_time;
    second_place_time := HMI_second_place_time;
    second_place_stand_time := HMI_second_place_stand_time;
    third_place_time := HMI_third_place_time;
    third_place_stand_time := HMI_third_place_stand_time;
ELSIF NOT SET_TIME THEN 
    first_place_time := 9;
    first_place_stand_time := 2;
    second_place_time := 7;
    second_place_stand_time := 2;
    third_place_time := 4;
    third_place_stand_time := 2;
    HMI_first_place_time := first_place_time;
    HMI_first_place_stand_time := first_place_stand_time;
    HMI_second_place_time := second_place_stand_time;
    HMI_second_place_stand_time := second_place_stand_time;
    HMI_third_place_time := third_place_time;
    HMI_third_place_stand_time := third_place_stand_time;
END_IF

IF pause AND NOT paused THEN
    // store value
    left_temp := left;
    right_temp := right;
    up_temp := up;
    down_temp := down;
    status_temp := status;
    // set to sotp
    
    left := FALSE;
    right := FALSE;
    up := FALSE;
    down := FALSE;
	status := 4;
    // time related
    time_show_temp := time_show;
    paused := TRUE;
ELSIF ((NOT pause) AND paused ) AND status = 1 THEN
    // restore value
    left := left_temp;
    right := right_temp;
    up := up_temp;
    down := down_temp;
    status := status_temp;
    paused := FALSE;
END_IF

// place control
HMI_left_strict := left_strict;
HMI_first_place := first_place;
HMI_second_place := second_place;
HMI_third_place := third_place;
HMI_right_strict := right_strict;

HMI_up_strict := up_strict;
HMI_down_strict := down_strict;

IF status <> 0 THEN
    IF left_strict THEN
        HMI_left_strict := TRUE;
		HMI_mid_1 := FALSE;

        pass_left_strict := TRUE;
        pass_first_place := FALSE;
    END_IF
    IF first_place THEN
        HMI_first_place := TRUE;
		HMI_mid_1 := FALSE;
		HMI_mid_2 := FALSE;

        pass_left_strict := FALSE;
        pass_first_place := TRUE;
        pass_second_place := FALSE;
    END_IF
    IF second_place THEN
        HMI_second_place := TRUE;
		HMI_mid_2 := FALSE;
		HMI_mid_3 := FALSE;

        pass_first_place := FALSE;
        pass_second_place := TRUE;
        pass_third_place := FALSE;
    END_IF
    IF third_place THEN
        HMI_third_place := TRUE;
		HMI_mid_3 := FALSE;
		HMI_mid_4 := FALSE;

        pass_second_place := FALSE;
        pass_third_place := TRUE;
        pass_right_strict := FALSE;
    END_IF
    IF right_strict THEN
        HMI_right_strict := TRUE;
		HMI_mid_4 := FALSE;

        pass_third_place := FALSE;
        pass_right_strict := TRUE;
    END_IF

    IF pass_left_strict THEN
        IF h_direction = 2 AND (NOT left_strict) THEN
            HMI_left_strict := FALSE;
            HMI_mid_1 := TRUE;
			pass_left_strict := FALSE;
        END_IF
    END_IF
    IF pass_first_place THEN
        IF h_direction = 1 AND (NOT first_place) THEN
            HMI_first_place := FALSE;
            HMI_mid_1 := TRUE;
			HMI_mid_2 := FALSE;
			pass_first_place := FALSE;
        END_IF
        IF h_direction = 2 AND (NOT first_place) THEN
            HMI_first_place := FALSE;
			HMI_mid_1 := FALSE;
            HMI_mid_2 := TRUE;
			HMI_mid_3 := FALSE;
			pass_first_place := FALSE;
        END_IF
    END_IF
    IF pass_second_place THEN
        IF h_direction = 1 AND (NOT second_place) THEN
            HMI_second_place := FALSE;
			HMI_mid_1 := FALSE;
            HMI_mid_2 := TRUE;
			HMI_mid_3 := FALSE;
			pass_second_place := FALSE;
        END_IF
        IF h_direction = 2 AND (NOT second_place) THEN
            HMI_second_place := FALSE;
			HMI_mid_2 := FALSE;
            HMI_mid_3 := TRUE;
			HMI_mid_4 := FALSE;
			pass_second_place := FALSE;
        END_IF
    END_IF
    IF pass_third_place THEN
        IF h_direction = 1 AND (NOT third_place) THEN
            HMI_third_place := FALSE;
            HMI_mid_2 := FALSE;
            HMI_mid_3 := TRUE;
			HMI_mid_4 := FALSE;
			pass_third_place := FALSE;
        END_IF
        IF h_direction = 2 AND (NOT third_place) THEN
            HMI_third_place := FALSE;
            HMI_mid_3 := FALSE;
			HMI_mid_4 := TRUE;
			pass_third_place := FALSE;
        END_IF
    END_IF
    IF pass_right_strict THEN
        IF h_direction = 1 AND (NOT right_strict) THEN
            HMI_right_strict := FALSE;
            HMI_mid_3 := FALSE;
			HMI_mid_4 := TRUE;
			pass_right_strict := FALSE;
        END_IF
    END_IF
    
    IF (NOT up_strict) AND (NOT down_strict) THEN
        HMI_up_down_mid := TRUE;
        HMI_up_strict := FALSE;
        HMI_down_strict := FALSE;
	ELSIF up_strict OR down_strict THEN
		HMI_up_down_mid := FALSE;
    END_IF

    IF h_direction = 1 AND (left OR right) THEN
        HMI_turn_left := TRUE;
        HMI_turn_right := FALSE;
    ELSIF h_direction = 2 AND (left OR right) THEN
        HMI_turn_left := FALSE;
        HMI_turn_right := TRUE;
	ELSE
		HMI_turn_left := FALSE;
        HMI_turn_right := FALSE;
    END_IF

    IF v_direction = 1 AND (up OR down) THEN
        HMI_turn_up := TRUE;
        HMI_turn_down := FALSE;
    ELSIF v_direction = 2 AND (up OR down) THEN
        HMI_turn_up := FALSE;
        HMI_turn_down := TRUE;
	ELSE
		HMI_turn_up := FALSE;
        HMI_turn_down := FALSE;
    END_IF
END_IF

IF status = 0 THEN
    HMI_RUN_status := FALSE;
    HMI_STOP_status := TRUE;
    HMI_RESET_status := FALSE;
	already_down := FALSE;
	start_timing := FALSE;
    h_direction := 0;
    v_direction := 0;
	temp_time := 0;
    run_count := 0;
    time_show := 0;
    left := FALSE;
    right := FALSE;
    up := FALSE;
    down := FALSE;
	already_first_place := FALSE;
	already_second_place := FALSE;
	already_third_place := FALSE;
END_IF

// when status = 1 or 2 mark start
IF status = 1 OR status = 2 THEN
    HMI_RUN_status := TRUE;
    HMI_STOP_status := FALSE;
    HMI_RESET_status := FALSE;
END_IF

IF status = 3 THEN
    HMI_RUN_status := FALSE;
    HMI_STOP_status := FALSE;
    HMI_RESET_status := TRUE;
END_IF

IF status = 3 THEN
    //run_count := 0;
    time_show := 0;
    IF left_strict = FALSE THEN
        left := TRUE;
        h_direction := 1;
    ELSE
        left := FALSE;
    END_IF
    IF up_strict = FALSE THEN
        up := TRUE;
        v_direction := 1;
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
            v_direction := 1;
        ELSE
			up := FALSE;
		END_IF
	ELSE
        up := FALSE;
    END_IF
    IF NOT down_strict THEN
        IF HMI_down THEN
            down := TRUE;
            v_direction := 2;
		ELSE
			down := FALSE;
        END_IF
	ELSE
        down := FALSE;
    END_IF
    IF NOT left_strict THEN
        IF HMI_left THEN
            left := TRUE;
            h_direction := 1;
		ELSE
			left := FALSE;
        END_IF
	ELSE
        left := FALSE;
    END_IF
    IF NOT right_strict THEN
        IF HMI_right THEN
            right := TRUE;
            h_direction := 2;
		ELSE
			right := FALSE;
        END_IF
	ELSE
        right := FALSE;
    END_IF
END_IF



IF run_count_set AND HMI_run_count_strict = 1 THEN
    run_count_strict := 1;
ELSIF run_count_set AND HMI_run_count_strict <> 1 THEN
    run_count_strict := HMI_run_count_strict;
ELSIF NOT run_count_set THEN
    run_count_strict := -1;
END_IF

// Introduce soft delay in auto mode in order to prevent electrical motor stock
// more detailed explaination are in commit message

IF status = 1 THEN
    IF run_count = run_count_strict THEN
        status := 3;
    ELSE
		IF left_strict THEN
			soft_delay_right := FALSE;
            left := FALSE;
            right_progress := TRUE;
			
			IF soft_delay_left THEN // a soft delay
				auto_mode_reset := FALSE;	
				soft_delay_left := FALSE;
			END_IF
			
            already_first_place := FALSE;
			already_second_place := FALSE;
			already_third_place := FALSE;
            already_right_place := FALSE;
        END_IF
		
		IF right_progress THEN
            right := TRUE;
            h_direction := 2;
        ELSIF NOT right_progress THEN
            right := FALSE;
        END_IF
		
		IF left_strict AND auto_mode_reset THEN
			soft_delay_left := TRUE; // a soft delay
		END_IF
        
		IF auto_mode_reset THEN
			soft_delay_right := TRUE; // a soft delay
		END_IF
		
		IF first_place AND NOT already_first_place THEN
            right_progress := FALSE;
			IF NOT down_strict AND NOT already_down THEN
				down_progress := TRUE;
			END_IF

			IF down_progress THEN
				
            	IF down_strict THEN
					down := FALSE;
					current_basic_time := first_place_time;
					start_timing := TRUE;
                	IF temp_time = current_basic_time AND start_timing THEN
                    	start_timing := FALSE;
						down_progress := FALSE;
                    	already_down := TRUE;
                	END_IF
                ELSE
                    down := TRUE;
				    v_direction := 2;
            	END_IF
			END_IF   

            IF already_down THEN
                IF up_strict THEN
					up := FALSE;
                    current_basic_time := first_place_stand_time;
					start_timing := TRUE;
                    IF temp_time = current_basic_time AND start_timing THEN
                        start_timing := FALSE;
                        already_down := FALSE;
                        right_progress := TRUE;
						already_first_place := TRUE;
                    END_IF
                ELSE
                    up := TRUE;
                    v_direction := 1;
                END_IF
            END_IF
        END_IF

        IF second_place AND NOT already_second_place THEN
            right_progress := FALSE;
			IF NOT down_strict AND NOT already_down THEN
				down_progress := TRUE;
			END_IF

			IF down_progress THEN
				
            	IF down_strict THEN
					down := FALSE;
					current_basic_time := second_place_time;
					start_timing := TRUE;
                	IF temp_time = current_basic_time AND start_timing THEN
                    	start_timing := FALSE;
						down_progress := FALSE;
                    	already_down := TRUE;
                	END_IF
                ELSE
                    down := TRUE;
				    v_direction := 2;
            	END_IF
			END_IF   

            IF already_down THEN
                IF up_strict THEN
					up := FALSE;
                    current_basic_time := second_place_stand_time;
					start_timing := TRUE;
                    IF temp_time = current_basic_time AND start_timing THEN
                        start_timing := FALSE;
                        already_down := FALSE;
                        right_progress := TRUE;
						already_second_place := TRUE;
                    END_IF
                ELSE
                    up := TRUE;
                    v_direction := 1;
                END_IF
            END_IF
        END_IF

        IF third_place AND NOT already_third_place THEN
            right_progress := FALSE;
			IF NOT down_strict AND NOT already_down THEN
				down_progress := TRUE;
			END_IF

			IF down_progress THEN
				
            	IF down_strict THEN
					down := FALSE;
					current_basic_time := third_place_time;
					start_timing := TRUE;
                	IF temp_time = current_basic_time AND start_timing THEN
                    	start_timing := FALSE;
						down_progress := FALSE;
                    	already_down := TRUE;
                	END_IF
                ELSE
                    down := TRUE;
				    v_direction := 2;
            	END_IF
			END_IF   

            IF already_down THEN
                IF up_strict THEN
					up := FALSE;
                    current_basic_time := third_place_stand_time;
					start_timing := TRUE;
                    IF temp_time = current_basic_time AND start_timing THEN
                        start_timing := FALSE;
                        already_down := FALSE;
                        right_progress := TRUE;
						already_third_place := TRUE;
                    END_IF
                ELSE
                    up := TRUE;
                    v_direction := 1;
                END_IF
            END_IF
        END_IF

        IF right_strict AND NOT already_right_place THEN
            run_count := run_count + 1;
            right_progress := FALSE;
            auto_mode_reset := TRUE;
            already_right_place := TRUE;
        END_IF

        IF auto_mode_reset AND soft_delay_right THEN
            IF NOT left_strict THEN
                left := TRUE;
                h_direction := 1;
            ELSE
                left := FALSE;
            END_IF
            IF NOT up_strict THEN
                up := TRUE;
                v_direction := 1;
            ELSE
                up := FALSE;
            END_IF
        END_IF
    END_IF
END_IF       

IF TRIG_1.Q THEN
    IF start_timing AND (NOT pause) THEN
        temp_time := temp_time + 1;
        time_show := current_basic_time - temp_time;
    ELSIF (NOT start_timing) AND (NOT pause) THEN
        time_show := 0;
        temp_time := 0;
    END_IF
END_IF