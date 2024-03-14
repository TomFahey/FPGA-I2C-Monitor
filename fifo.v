module SyncFIFO #(parameter DATA_WIDTH=16, DEPTH=256)
                (input wire clk,        // Clock input
                 input wire rst,        // Reset input
                 input wire wr_en,      // Write enable input
                 input wire rd_en,      // Read enable input
                 input wire [DATA_WIDTH-1:0] wr_data, // Input data
                 output reg [DATA_WIDTH-1:0] rd_data, // Output data
                 output wire full,      // Full flag output
                 output wire empty      // Empty flag output
                );

    // Internal parameters
    parameter ADDR_WIDTH = $clog2(DEPTH);
    parameter MEM_SIZE = 2**ADDR_WIDTH;

    // Internal signals
    reg [DATA_WIDTH-1:0] fifo_mem [0:MEM_SIZE-1]; // Dual-port RAM for FIFO memory
    reg [ADDR_WIDTH-1:0] wr_ptr, rd_ptr;          // Write and read pointers
    reg [ADDR_WIDTH-1:0] next_wr_ptr, next_rd_ptr; // Next write and read pointers
    reg [ADDR_WIDTH-1:0] count;                    // Number of elements in the FIFO

    // Full and empty flag logic
    assign full = (count == DEPTH);
    assign empty = (count == 0);

    // Synchronous process for write operation
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            count <= {ADDR_WIDTH{1'b0}};
        end else if (rd_en && !empty) begin
            rd_data <= fifo_mem[rd_ptr];
            next_rd_ptr = (rd_ptr == DEPTH-1) ? 0 : rd_ptr + 1;
            count <= count - 1;
            if (rd_en && !empty) rd_ptr <= next_rd_ptr;
        end else if (wr_en && !full) begin
            fifo_mem[wr_ptr] <= wr_data;
            next_wr_ptr = (wr_ptr == DEPTH-1) ? 0 : wr_ptr + 1;
            count <= count + 1;
            if (wr_en && !full) wr_ptr <= next_wr_ptr;
        end
    end

endmodule
