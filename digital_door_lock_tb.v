`timescale 1ns/1ps

module digital_door_lock_tb;

    reg clk;
    reg reset;

    reg [3:0] key_code;
    reg       key_valid;

    wire door_unlock;
    wire alarm;
    wire wrong_attempt;

    wire [2:0] attempt_count;
    wire [3:0] digit_count;

    /*
     * Instantiate Digital Door Lock
     */
    digital_door_lock #(
        .PASSWORD(32'h12345678)
    ) uut (
        .clk(clk),
        .reset(reset),

        .key_code(key_code),
        .key_valid(key_valid),

        .door_unlock(door_unlock),
        .alarm(alarm),
        .wrong_attempt(wrong_attempt),

        .attempt_count(attempt_count),
        .digit_count(digit_count)
    );

    /*
     * 10 ns clock
     */
    always #5 clk = ~clk;


    /*
     * Enter one keypad digit
     */
    task enter_digit;
        input [3:0] digit;

        begin

            @(negedge clk);

            key_code  = digit;
            key_valid = 1'b1;

            @(negedge clk);

            key_valid = 1'b0;

        end

    endtask


    /*
     * Enter correct password:
     * 1 2 3 4 5 6 7 8
     */
    task enter_correct_password;

        begin

            enter_digit(4'd1);
            enter_digit(4'd2);
            enter_digit(4'd3);
            enter_digit(4'd4);
            enter_digit(4'd5);
            enter_digit(4'd6);
            enter_digit(4'd7);
            enter_digit(4'd8);

        end

    endtask


    /*
     * Enter incorrect password:
     * 1 1 1 1 1 1 1 1
     */
    task enter_wrong_password;

        begin

            enter_digit(4'd1);
            enter_digit(4'd1);
            enter_digit(4'd1);
            enter_digit(4'd1);
            enter_digit(4'd1);
            enter_digit(4'd1);
            enter_digit(4'd1);
            enter_digit(4'd1);

        end

    endtask


    /*
     * Display output
     */
    initial begin

        $monitor(
            "TIME=%0t | Key=%0d | Valid=%b | Digits=%0d | Attempts=%0d | Unlock=%b | Wrong=%b | Alarm=%b",
            $time,
            key_code,
            key_valid,
            digit_count,
            attempt_count,
            door_unlock,
            wrong_attempt,
            alarm
        );

    end


    /*
     * Generate waveform
     */
    initial begin

        $dumpfile("digital_door_lock.vcd");
        $dumpvars(0, digital_door_lock_tb);

    end


    /*
     * Main test sequence
     */
    initial begin

        clk       = 1'b0;
        reset     = 1'b1;
        key_code  = 4'd0;
        key_valid = 1'b0;

        $display("==============================================");
        $display("       DIGITAL DOOR LOCK SIMULATION           ");
        $display("==============================================");

        /*
         * Reset
         */
        #12;

        reset = 1'b0;

        #10;

        $display("\nTEST 1: System reset");
        $display("Door should be LOCKED and alarm OFF.");

        #20;


        /*
         * Test correct password
         */
        $display("\nTEST 2: Entering correct password");
        $display("Password = 1 2 3 4 5 6 7 8");

        enter_correct_password;

        #10;

        if (door_unlock)
            $display("PASS: Door UNLOCKED.");
        else
            $display("FAIL: Door did not unlock.");

        #20;


        /*
         * Reset before wrong-password tests
         */
        reset = 1'b1;

        #10;

        reset = 1'b0;

        $display("\nTEST 3: First wrong password");

        enter_wrong_password;

        #10;

        $display(
            "Wrong attempts = %0d, Alarm = %b",
            attempt_count,
            alarm
        );

        #20;


        /*
         * Second wrong attempt
         */
        $display("\nTEST 4: Second wrong password");

        enter_wrong_password;

        #10;

        $display(
            "Wrong attempts = %0d, Alarm = %b",
            attempt_count,
            alarm
        );

        #20;


        /*
         * Third wrong attempt
         */
        $display("\nTEST 5: Third wrong password");

        enter_wrong_password;

        #10;

        $display(
            "Wrong attempts = %0d, Alarm = %b",
            attempt_count,
            alarm
        );

        #20;


        /*
         * Fourth wrong attempt
         */
        $display("\nTEST 6: Fourth wrong password");

        enter_wrong_password;

        #10;

        $display(
            "Wrong attempts = %0d, Alarm = %b",
            attempt_count,
            alarm
        );

        #20;


        /*
         * Fifth wrong attempt
         */
        $display("\nTEST 7: Fifth wrong password");

        enter_wrong_password;

        #10;

        if (alarm)
            $display("PASS: Alarm ACTIVATED after 5 wrong attempts.");
        else
            $display("FAIL: Alarm did not activate.");

        #20;


        /*
         * Try correct password after alarm
         */
        $display("\nTEST 8: Correct password after alarm");

        enter_correct_password;

        #10;

        if (alarm && !door_unlock)
            $display("PASS: Alarm remains active and door stays locked.");
        else
            $display("FAIL: Alarm/door state incorrect.");

        #20;


        /*
         * End simulation
         */
        $display("\n==============================================");
        $display("          SIMULATION COMPLETED                ");
        $display("==============================================");

        $finish;

    end

endmodule