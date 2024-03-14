module serial #(parameter BAUD_RATE=115_200, CLOCK_RATE = 27_000_000)
               (
                   input       i_clk,
                   input [7:0] i_Tx_Byte,
                   input       i_Tx_Enable,
                   output      o_Tx_Busy,
                   output reg  o_Tx_Serial,
                   output reg  o_Tx_Done
               );

    localparam CLOCK_DIVIDER = CLOCK_RATE / BAUD_RATE;
    
    localparam s_UART_IDLE   = 3'b000;
    localparam s_UART_START  = 3'b001;
    localparam s_UART_DATA   = 3'b010;
    localparam s_UART_STOP   = 3'b011;
    localparam s_UART_FINISH = 3'b100;
    
    reg [2:0] r_Serial_SM     = s_UART_IDLE;
    reg [31:0] r_Clock_Counter = 32'd0;
    reg [2:0] r_Bit_Index     = 4'd0;
    reg [7:0] r_Tx_Data       = 8'd0;
    reg       r_Tx_Done       = 1'd0;
    reg       r_Tx_Busy       = 1'd0;

    assign o_Tx_Busy = r_Tx_Busy;
    assign O_Tx_Done = r_Tx_Done;

    
    always @(posedge i_clk)
    begin 
        case(r_Serial_SM)
    
          s_UART_IDLE : begin
            r_Clock_Counter <= 32'd0;
            r_Bit_Index     <= 1'd0; 
            o_Tx_Serial     <= 1'b1;
            o_Tx_Done       <= 1'b0;
    
            if (i_Tx_Enable == 1'b1)
              begin
                r_Tx_Busy   <= 1'b1;
                r_Tx_Data   <= i_Tx_Byte;
                r_Serial_SM <= s_UART_START;
              end
            else 
              begin
                r_Serial_SM <= s_UART_IDLE;
              end
          end
    
          s_UART_START : begin
            o_Tx_Serial <= 1'b0;
    
            if (r_Clock_Counter < (CLOCK_DIVIDER - 1))
              begin
                  r_Clock_Counter <= r_Clock_Counter + 1;
              end
            else
              begin
                r_Clock_Counter <= 32'd0;
                r_Serial_SM     <= s_UART_DATA;
              end
            end
    
          s_UART_DATA : begin
            o_Tx_Serial <= r_Tx_Data[r_Bit_Index];
    
            if (r_Clock_Counter < (CLOCK_DIVIDER -1))
            begin
                r_Clock_Counter <= r_Clock_Counter + 1;
            end else begin
                r_Clock_Counter <= 32'd0;
                r_Bit_Index <= r_Bit_Index + 1;
                if (r_Bit_Index == 7)
                  begin
                    r_Serial_SM <= s_UART_STOP;
                    r_Bit_Index <= 4'd0;
                  end
              end
            end
    
          s_UART_STOP : begin
            o_Tx_Serial <= 1'b1;
    
            if (r_Clock_Counter < (CLOCK_DIVIDER - 1))
            begin
                r_Clock_Counter <= r_Clock_Counter + 1;
            end else begin
                r_Tx_Done <= 1'b1;
                r_Clock_Counter <= 32'd0;
                r_Serial_SM <= s_UART_FINISH;
                r_Tx_Busy <= 1'b0;
              end
    
            end

          s_UART_FINISH : begin
              r_Tx_Done <= 1'b1;
              r_Serial_SM <= s_UART_IDLE;
            end

           default : 
              r_Serial_SM <= s_UART_IDLE;

        endcase
    end


endmodule