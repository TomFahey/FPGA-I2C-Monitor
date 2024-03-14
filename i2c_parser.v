module i2c_parser (
    input        i_clk,			    // 50MHz input clock
    input        i_rst,             // Reset
    input        i_SDA,			    // I2C Data Physical GPIO Pin
    input        i_SCL,			    // I2C Clock Physical GPIO Pin
    output [15:0] o_I2C_Read_Data,    // I2C Read Data
    output       o_I2C_Read_EN     // I2C Read Enable
    );

    //localparam I2C_IDLE          = 4'd0;
    //localparam I2C_START         = 4'd1;
    //localparam I2C_BYTE          = 4'd2;
    //localparam I2C_ACK           = 4'd3;
    //localparam I2C_ACK_CLOSE     = 4'd4;
    //localparam I2C_WAIT          = 4'd5;
    //localparam I2C_START_OR_BYTE = 4'd6;
    //localparam I2C_STOP_OR_BYTE  = 4'd7;
    
    localparam I2C_IDLE            = 4'd0;
    localparam I2C_START           = 4'd1;
    localparam I2C_DATA            = 4'd2;
    localparam I2C_DATA_R          = 4'd3;
    localparam I2C_ACK             = 4'd4;
    localparam I2C_POST_ACK        = 4'd5;
    localparam I2C_TRI             = 4'd6;
    localparam I2C_STOP            = 4'd7;

    localparam ASCII_STX = 8'h02;
    localparam ASCII_ETX = 8'h03;
    localparam ASCII_ACK = 8'h06;
    localparam ASCII_NAK = 8'h15;
    localparam ASCII_LF  = 8'h0A;
    localparam ASCII_SPACE = 8'h20;
    localparam ASCII_ZERO = 8'h30;
    localparam ASCII_ONE  = 8'h31;
    localparam ASCII_TWO  = 8'h32;
    localparam ASCII_THREE = 8'h33;
    localparam ASCII_FOUR = 8'h34;
    localparam ASCII_FIVE = 8'h35;
    localparam ASCII_SIX  = 8'h36;
    localparam ASCII_SEVEN = 8'h37;
    localparam ASCII_EIGHT = 8'h38;
    localparam ASCII_NINE = 8'h39;
    localparam ASCII_A = 8'h41;
    localparam ASCII_B = 8'h42;
    localparam ASCII_C = 8'h43;
    localparam ASCII_D = 8'h44;
    localparam ASCII_E = 8'h45;
    localparam ASCII_F = 8'h46;
    localparam ASCII_x = 8'h78;


    // create working registers
    reg [3:0] r_I2C_status;     // I2C State Machine Status
    reg [3:0] r_bit_index;      // I2C DATA/ADDR byte counter
    reg [15:0] r_I2C_Read_Data;  // I2C DATA/ADDR byte value
    reg [7:0] r_I2C_Read_Buffer;  // I2C DATA/ADDR byte value
    reg       r_I2C_Read_EN;   // I2C Read Ready
    //reg       r_I2C_Read_EN_d;
    //reg       r_I2C_Read_EN_q;
    
    reg SDA_D, SDA_Q;
    reg SCL_D, SCL_Q;
    
    wire SDA_POSEDGE = SDA_D & !SDA_Q;
    wire SDA_NEGEDGE = !SDA_D & SDA_Q;
    wire SCL_POSEDGE = SCL_D & !SCL_Q;
    wire SCL_NEGEDGE = !SCL_D & SCL_Q;

    assign o_I2C_Read_Data = r_I2C_Read_Data;
    assign o_I2C_Read_EN = r_I2C_Read_EN;

    initial begin

      SDA_D <= 1'b1;
      SDA_Q <= 1'b1;
      SCL_D <= 1'b1;
      SCL_Q <= 1'b1;

      r_I2C_status <= I2C_IDLE; // start in idle state
      r_bit_index <= 4'h0; // start at zero
      r_I2C_Read_Data <= 8'h00; // start empty
      r_I2C_Read_EN <= 1'b0; // start low

    end

    always @(posedge i_clk, posedge i_rst) begin
      if (i_rst == 1'b1) begin
        SDA_D <= 1'b1;
        SDA_Q <= 1'b1;
        SCL_D <= 1'b1;
        SCL_Q <= 1'b1;
      end else begin
        SDA_D <= i_SDA;
        SDA_Q <= SDA_D;
        SCL_D <= i_SCL;
        SCL_Q <= SCL_D;
      end
    end

    always @(posedge i_clk, posedge i_rst)
      begin
        if (i_rst == 1'b1) begin
          r_I2C_status = I2C_IDLE;
          r_I2C_Read_Data = 8'd0;
          r_bit_index = 4'd0;
        end else begin
          r_I2C_Read_EN <= 1'b0;
          case (r_I2C_status)
            I2C_IDLE: begin
              if (SDA_NEGEDGE == 1'b1) begin
                r_I2C_status <= I2C_START;
              end else begin
                r_I2C_status <= I2C_IDLE;
              end
            end
            I2C_START: begin
              if (SCL_NEGEDGE == 1'b1) begin
                r_I2C_Read_Data <= {ASCII_STX, ASCII_SPACE};
                r_bit_index <= 4'd0;
                r_I2C_Read_EN <= 1'b1;
                r_I2C_status = I2C_DATA; 
              end else begin
                r_I2C_status = I2C_START;
              end
            end
            I2C_DATA: begin
              if (SCL_POSEDGE == 1'b1) begin
                r_I2C_Read_Buffer <= (r_bit_index > 0) ? (r_I2C_Read_Buffer | (i_SDA << r_bit_index))
                                                       : (i_SDA << r_bit_index);
                r_bit_index <= r_bit_index + 4'd1;
                case (r_bit_index)
                  4'd0: begin
                    r_I2C_status <= I2C_DATA;
                  end
                  4'd1: begin
                    r_I2C_status <= I2C_DATA;
                  end
                  4'd2: begin
                    r_I2C_status <= I2C_DATA;
                  end
                  4'd3: begin
                    r_I2C_status <= I2C_DATA;
                  end
                  4'd4: begin
                    r_I2C_status <= I2C_DATA;
                  end
                  4'd5: begin
                    r_I2C_status <= I2C_DATA;
                  end
                  4'd6: begin
                    r_I2C_Read_Data <= {ASCII_ZERO, ASCII_x};
                    r_I2C_Read_EN <= 1'b1;
                    r_I2C_status <= I2C_DATA;
                  end
                  4'd7: begin
                    r_I2C_status <= I2C_DATA;
                  end
                  4'd8: begin
                    r_I2C_Read_Data <= ((r_I2C_Read_Buffer >> 4) > 8'h09) ? ((r_I2C_Read_Buffer >> 4) + 8'h37) 
                                                                          : ((r_I2C_Read_Buffer >> 4) + 8'h30);
                    r_I2C_Read_Data <= {
                      ((r_I2C_Read_Buffer >> 4) > 8'h09) ? ((r_I2C_Read_Buffer >> 4) + 8'h37)
                                                         : ((r_I2C_Read_Buffer >> 4) + 8'h30),
                      ((r_I2C_Read_Buffer & 8'h0F) > 8'h09) ? ((r_I2C_Read_Buffer & 8'h0F) + 8'h37)
                                                         : ((r_I2C_Read_Buffer & 8'h0F) + 8'h30)
                    };
                    r_I2C_Read_EN <= 1'b1;
                    r_bit_index <= 4'd0;
                    r_I2C_Read_Buffer <= 8'd0;
                    r_I2C_status <= I2C_ACK;
                  end
                endcase
              end else begin
                r_I2C_status <= I2C_DATA;
              end
            end
            I2C_ACK: begin
              if (i_SDA == 1'b0) begin
                r_I2C_Read_Data <= {ASCII_SPACE, ASCII_ACK};
              end else begin
                r_I2C_Read_Data <= {ASCII_SPACE, ASCII_NAK};
              end
              r_I2C_Read_EN <= 1'b1;
              r_I2C_status <= I2C_POST_ACK;
            end
            I2C_POST_ACK: begin
              if (SCL_POSEDGE == 1'b1) begin
                r_I2C_status <= I2C_TRI;
                r_I2C_Read_Data <= {ASCII_SPACE, ASCII_SPACE};
                r_I2C_Read_EN <= 1'b1;
              end else begin
                r_I2C_status <= I2C_POST_ACK;
              end
            end
            I2C_TRI: begin
              if (SDA_NEGEDGE == 1'b1) begin
                r_I2C_status <= I2C_START;
              end else if (SCL_NEGEDGE == 1'b1) begin
                r_I2C_Read_Buffer <= (i_SDA << 0);
                r_bit_index <= 4'd1;
                r_I2C_status <= I2C_DATA;
              end else if (SDA_POSEDGE == 1'b1) begin
                r_I2C_status <= I2C_STOP;
                r_I2C_Read_Data <= {ASCII_ETX, ASCII_LF};
                r_I2C_Read_EN <= 1'b1;
              end else begin
                r_I2C_status <= I2C_TRI;
              end
            end
            I2C_STOP: begin
              //r_I2C_Read_Data <= ASCII_LF;
              //r_I2C_Read_EN <= 1'b1;
              r_I2C_status <= I2C_IDLE;
            end
            default: begin
              r_I2C_status <= I2C_IDLE;
            end
          endcase
        end
      end
    
    //always @(posedge i_clk) begin
    //  r_I2C_Read_EN_d <= r_I2C_Read_EN;
    //  r_I2C_Read_EN_q <= r_I2C_Read_EN_d;
    //  if (r_I2C_Read_EN_d == 1'b1 && r_I2C_Read_EN_q == 1'b0) begin
    //    o_I2C_Read_EN <= 1'b1;
    //  end else begin
    //    o_I2C_Read_EN <= 1'b0;
    //  end
    //end

    //always @(i_SCL, i_SDA, i_rst) begin
    //    if (i_rst == 1'b1) begin
    //        r_I2C_status <= I2C_IDLE;
    //        r_I2C_Read_Data <= 8'd0;
    //        r_bit_index <= 4'd0;
    //    end
    //    r_I2C_Read_EN = 1'b0;
    //    case (r_I2C_status)
    //      I2C_IDLE : begin
    //        if (i_SCL==1'b1 & i_SDA==1'b0) begin
    //            r_I2C_status <= I2C_START;
    //        end
    //      end
    //      I2C_START : begin
    //        if (i_SCL==1'b0 & i_SDA==1'b0) begin
    //            r_I2C_Read_Data <= 8'd83;
    //            r_I2C_Read_EN <= 1'b1;
    //            r_I2C_status <= I2C_BYTE;
    //        end
    //      end
    //      I2C_BYTE : begin
    //        if (i_SCL==1'b1) begin
    //            r_I2C_Read_Data <= (r_bit_index > 0) ? (r_I2C_Read_Data | (i_SDA << r_bit_index))
    //                                                : (i_SDA << r_bit_index);
    //            r_bit_index <= r_bit_index + 4'd1;
    //            if (r_bit_index == 4'd8) begin
    //                r_I2C_Read_EN <= 1'b1;
    //                r_I2C_status <= I2C_ACK;
    //                r_bit_index <= 4'd0;
    //            end
    //        end
    //      end
    //      I2C_ACK : begin
    //        if (i_SCL==1'b1) begin
    //            if (i_SDA==1'b0) begin
    //                r_I2C_Read_Data <= 8'd65;
    //            end
    //            else begin
    //                r_I2C_Read_Data <= 8'd78;
    //            end
    //            r_I2C_Read_EN <= 1'b1;
    //            r_I2C_status <= I2C_ACK_CLOSE;
    //        end
    //      end
    //      I2C_ACK_CLOSE : begin
    //        if (i_SCL==1'b0) begin
    //            r_I2C_Read_EN <= 1'b0;
    //            r_I2C_status <= I2C_WAIT;
    //        end
    //      end
    //      I2C_WAIT : begin
    //        if (i_SCL==1'b1) begin
    //            r_I2C_status <= I2C_STOP_OR_BYTE;
    //        end
    //        else begin
    //            r_I2C_status <= I2C_START_OR_BYTE;
    //        end
    //      end
    //      I2C_START_OR_BYTE : begin
    //        if (i_SCL==1'b1 & r_bit_index!==4'd1) begin     // A bit of a cheese, but it works:
    //            r_I2C_Read_Data <= i_SDA;						 // r_bit_index==0 immediately after exiting 
    //            r_bit_index <= 4'd1;								 // I2C_WAIT. Therefore, if r_bit_index==1,
    //        end													 // we are entering the I2C_START_OR_BYTE block
    //        else if (i_SCL==1'b0 & r_bit_index==4'd1) begin // for the second time (after SCL has gone 0->1)
    //            r_I2C_Read_Data <= i_SDA << r_bit_index;			 // If the next transition is SCL 1->0, then this
    //            r_I2C_status <= I2C_BYTE;							 // is another byte R/W. Otherwise, SDA has
    //        end else begin // Repeated Start					 // transitioned whilst SCL was high, so this 
    //            r_I2C_Read_Data <= 8'd83;								 // indicates a repeated start.
    //            r_bit_index <= 4'd0;
    //            r_I2C_Read_EN <= 1'b1;
    //            r_I2C_status <= I2C_BYTE;
    //        end
    //      end
    //      I2C_STOP_OR_BYTE : begin
    //        if (i_SDA==1'b1) begin // STOP
    //            r_I2C_Read_Data <= 8'd80;
    //            r_I2C_Read_EN <= 1'b1;
    //            r_I2C_status <= I2C_IDLE;
    //        end else begin // BYTE
    //            r_I2C_Read_Data <= i_SDA << r_bit_index;
    //            r_bit_index <= 4'd1;
    //            r_I2C_status <= I2C_BYTE;
    //        end
    //      end
    //      default : begin
    //        r_I2C_status <= I2C_IDLE;
    //      end
    //    endcase
    //end

endmodule