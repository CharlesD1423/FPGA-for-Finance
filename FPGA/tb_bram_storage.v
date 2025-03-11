`timescale 1ns / 1ps

module tb_market_data_bram;

    reg clk;
    reg reset;
    reg [9:0] row_index;  // Supports up to 1024 rows
    reg [2:0] col_index;  // 6 columns per row
    wire [31:0] data_out;
    
    real float_value;  // Stores converted floating-point value

    // Instantiate the BRAM module
    bram_storage uut (
        .clk(clk),
        .reset(reset),
        .row_index(row_index),
        .col_index(col_index),
        .data_out(data_out)
    );

    // Clock generation
    always #5 clk = ~clk;  // 10ns clock cycle

    // Declare loop variables
    integer i;
    integer j;

    function real ieee754_to_real(input [31:0] float_bits);
        integer sign;
        integer exponent;
        real fraction;
        begin
            sign = float_bits[31] ? -1 : 1;
            exponent = float_bits[30:23] - 127;
            fraction = 1.0 + (float_bits[22:0] / (2.0**23));  // Normalize mantissa
            ieee754_to_real = sign * fraction * (2.0**exponent);
        end
    endfunction

    initial begin
        // Initialize signals
        clk = 0;
        reset = 1;
        row_index = 0;
        col_index = 0;
        #10 reset = 0; // Release reset

        for (i = 0; i < 145; i = i + 1) begin
            row_index = i;
            $display("Row %d:", i);

            for (j = 0; j < 6; j = j + 1) begin
                col_index = j;
                #10;  // Wait for clock edge
                
                // Convert 32-bit binary to floating-point using custom function
                float_value = ieee754_to_real(data_out);

                case (j)
                    0: $write("  Timestamp: %d", data_out);  // Keep as integer
                    1: $write("  Open: %f", float_value);
                    2: $write("  High: %f", float_value);
                    3: $write("  Low: %f", float_value);
                    4: $write("  Close: %f", float_value);
                    5: $write("  Volume: %f", float_value);
                endcase
                $write("\n");
            end
            $display("-----------------------------");
        end

        $finish;
    end

endmodule
