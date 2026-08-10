`timescale 1ns/1ps

module digital_door_lock #(
    // Default password = 1 2 3 4 5 6 7 8
    parameter [31:0] PASSWORD = 32'h12345678
)(
    input  wire        clk,
    input  wire        reset,

    // 4-bit keypad input
    input  wire [3:0]  key_code,

    // Indicates that a valid key has been pressed
    input  wire        key_valid,

    // Outputs
    output reg         door_unlock,
    output reg         alarm,
    output reg         wrong_attempt,

    // Number of wrong attempts
    output reg [2:0]   attempt_count,

    // Number of digits currently entered
    output reg [3:0]   digit_count
);

    // Stores the eight entered digits
    reg [31:0] entered_code;

    // Temporary value used for comparison
    reg [31:0] next_code;

    always @(posedge clk or posedge reset) begin

        if (reset) begin

            entered_code  <= 32'd0;
            next_code     <= 32'd0;

            door_unlock   <= 1'b0;
            alarm         <= 1'b0;
            wrong_attempt <= 1'b0;

            attempt_count <= 3'd0;
            digit_count   <= 4'd0;

        end

        else begin

            // Wrong-attempt signal is a one-clock pulse
            wrong_attempt <= 1'b0;

            /*
             * Ignore keypad input after the alarm
             * has been activated.
             */
            if (!alarm && !door_unlock) begin

                if (key_valid) begin

                    /*
                     * Shift the previous seven digits
                     * and append the new digit.
                     */
                    next_code = {entered_code[27:0], key_code};

                    entered_code <= next_code;

                    /*
                     * Eight digits have been entered.
                     */
                    if (digit_count == 4'd7) begin

                        digit_count <= 4'd0;

                        /*
                         * Compare entered password
                         * with the stored password.
                         */
                        if (next_code == PASSWORD) begin

                            // Correct password
                            door_unlock   <= 1'b1;
                            attempt_count <= 3'd0;

                        end

                        else begin

                            // Wrong password
                            wrong_attempt <= 1'b1;

                            /*
                             * Activate alarm after
                             * the fifth wrong attempt.
                             */
                            if (attempt_count == 3'd4) begin

                                attempt_count <= 3'd5;
                                alarm         <= 1'b1;

                            end

                            else begin

                                attempt_count <= attempt_count + 3'd1;

                            end

                        end

                        // Clear entered digits after 8-digit attempt
                        entered_code <= 32'd0;

                    end

                    else begin

                        digit_count <= digit_count + 4'd1;

                    end

                end

            end

        end

    end

endmodule