// create module
module i2c_monitor (
    input           i_clk,				// 50MHz input clock
    input           i_rst_n,
    input           i_SDA_GPIO,			// I2C Data Physical GPIO Pin
    input           i_SCL_GPIO,			// I2C Clock Physical GPIO Pin
    output	        o_UART_Tx_GPIO,     // UART Data Physical GPIO Pin,
    output	        o_UART_Tx_LED,
    output	        o_RST_LED,
    output  [3:0]   o_I2C_STATUS_LED,
    output    	    o_UART_Tx_DONE 
    );
    
    
    localparam I2C_IDLE      = 4'd0;
    localparam I2C_START     = 4'd1;
    localparam I2C_BYTE      = 4'd2;
    localparam I2C_ACK       = 4'd3;
    localparam I2C_ACK_CLOSE = 4'd4;
    localparam I2C_WAIT      = 4'd5;
    localparam I2C_START_OR_BYTE = 4'd6;
    localparam I2C_STOP_OR_BYTE  = 4'd7;

    // create working registers
    reg sync_d, sync_q;
    //reg SDA_SIGNAL_Q, SCL_SIGNAL_Q;


    // create working wires

    wire rst = !i_rst_n;

    // I2C wires
    wire        w_SDA_SIGNAL;       // I2C Logical Data Line
    wire        w_SCL_SIGNAL;       // I2C Logical Clock Line
    wire [15:0]  w_I2C_Read_Data;    // I2C DATA/ADDR byte value
    wire        w_I2C_Read_EN;      // I2C Read Ready

    // FIFO wires
    wire        w_FIFO_Write_EN;    // FIFO Write Enable
    wire        w_FIFO_Read_EN;     // FIFO Read Enable
    wire        w_FIFO_Full;        // FIFO Full Flag
    wire        w_FIFO_Empty;       // FIFO Empty Flag
    wire [15:0]  w_FIFO_Write_Data;  // FIFO Write Data
    wire [15:0]  w_FIFO_Read_Data;   // FIFO Read Data

    // UART Tx wires
    wire [15:0] w_UART_Tx_Data;  // UART Data
    wire       w_UART_Tx_EN;    // UART Write Enable
    wire       w_UART_Tx_Busy;  // UART Busy Flag
    wire       w_UART_Tx_Done;  // UART Done Flag
    
    reg        r_FIFO_Write_EN;
    reg        r_UART_Tx_EN;

    // Wire connections
    assign w_FIFO_Write_Data = w_I2C_Read_Data;; // Connect I2C output to FIFO input
    assign w_FIFO_Write_EN = w_I2C_Read_EN;      // Enable write when I2C read ready

    assign w_UART_Tx_Data = w_FIFO_Read_Data;    // Connect FIFO output to UART input
    assign w_UART_Tx_EN = r_UART_Tx_EN;          // and UART is not busy

    assign o_UART_Tx_LED = o_UART_Tx_GPIO;       // LED indicatator of UART Tx Activity
    assign o_RST_LED = rst;                      // LED indicator of Reset
    
    // FIFO writes out whenever it's not empty
    assign w_FIFO_Read_EN  = !w_FIFO_Empty & !w_UART_Tx_Busy & !w_UART_Tx_EN; 

    // Instatiate modules
    debounce SDA_debouce (
        .clk(i_clk),
        .rst(rst),
        .in(i_SDA_GPIO),
        .out(w_SDA_SIGNAL)
    );

    debounce SCL_debouce (
        .clk(i_clk),
        .rst(rst),
        .in(i_SCL_GPIO),
        .out(w_SCL_SIGNAL)
    );

    SyncFIFO fifoBuffer (
        .clk(i_clk),
        .rst(rst),
        .wr_en(w_FIFO_Write_EN),
        .rd_en(w_FIFO_Read_EN),
        .wr_data(w_FIFO_Write_Data),
        .rd_data(w_FIFO_Read_Data),
        .full(w_FIFO_Full),
        .empty(w_FIFO_Empty)
    );

    uart_tx UART_Tx (
        .i_clk(i_clk),
        .i_Tx_Byte(w_FIFO_Read_Data),
        .i_Tx_Enable(w_UART_Tx_EN),
        .o_Tx_Busy(w_UART_Tx_Busy),
        .o_Tx_Serial(o_UART_Tx_GPIO),
        .o_Tx_Done(o_UART_Tx_DONE)
    );

    i2c_parser I2C_Parser (
        .i_clk(i_clk),
        .i_rst(rst),
        .i_SCL(w_SCL_SIGNAL),
        .i_SDA(w_SDA_SIGNAL),
        .o_I2C_Read_Data(w_I2C_Read_Data),
        .o_I2C_Read_EN(w_I2C_Read_EN)
    );


    // Update enable signals
    always @(posedge i_clk) begin
        r_FIFO_Write_EN <= w_I2C_Read_EN;
        r_UART_Tx_EN <= w_FIFO_Read_EN;
    end

endmodule