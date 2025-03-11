// current data structure:
// 6 float32 (4 bytes) values per row 
// total row size = 24 bytes
// stored format:
// timestamp (unix time)
// open price
// high price
// low price 
// close price
// volume
// each value in LITTLE ENDIAN IEEE 754 floating point format




module bram_storage(
    input clk,
    input reset,
    input [9:0] row_index,  // Select which row to read (supports 1024 rows)
    input [2:0] col_index,  // Select column (0-5: Timestamp, Open, High, Low, Close, Volume)
    output reg [31:0] data_out  // 32-bit float output
);

    reg [31:0] bram [0:1023][0:5];

    // Load memory file
    initial begin
        $readmemh("market_data.mem", bram);
    end

    // Read operation
    always @(posedge clk) begin
        if (reset)
            data_out <= 32'b0;
        else
            data_out <= bram[row_index][col_index]; // Fetch selected data
    end
endmodule
