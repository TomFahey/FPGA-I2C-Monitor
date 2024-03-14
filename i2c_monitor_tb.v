`timescale 1ns / 100ps

module i2c_monitor_tb ();
 
  reg clk, rst, SDA_GPIO, SCL_GPIO;
  integer i, j;
  integer bounce1, bounce2, bounce3;
  localparam PIN_SDA = 0;
  localparam PIN_SCL = 1;
 
  i2c_monitor DUT (
    .clk(clk),
    .rst(rst),
    .SDA_GPIO(SDA_GPIO),
    .SCL_GPIO(SCL_GPIO)
  );
 
  initial begin
    clk = 1'b0;
    rst = 1'b1;
    SDA_GPIO = 1'b1;
    SCL_GPIO = 1'b1;
    forever #10 clk = ~clk; // generate a clock
  end
 
  initial begin

    repeat(100) @(posedge clk);
    rst = 1'b0;

    // i2C Message #1: S 0x2B R A 0x69 A P / 0x53 0xAB 0x41 0x69 0x41 0x80
    send_start();    // i2c START
    send_byte(171); // Address byte (WRITE)
    send_ack();     // i2c ACK
    send_byte(105); // Register address byte
    send_ack();     // i2c ACK
    send_stop();    // i2c STOP
    repeat(500) @(posedge clk);

    // i2C Messsage #2: S 0x08 W A Sr 0x08 R 0x06 A 0x00 A N P / 0x53 0x08 0x41 0x53 0x88 0x41 0x06 0x41 0x00 0x4E 0x80
    send_start();    // i2c START
    send_byte(8);   // Address byte (WRITE)
    send_ack();     // i2c ACK
    send_restart(); // i2c RESTART
    send_byte(136); // Address byte (READ)
    send_ack();     // i2c ACK
    send_byte(6);   // Register address lower byte
    send_ack();     // i2c ACK
    send_byte(0);   // Register address upper byte
    send_ack();     // i2c ACK (should be NACK really)
    send_stop();    // i2c STOP
    repeat(500) @(posedge clk);

    $finish;
  end

  task toggle_pin(input integer bounces, input integer pin_select);
    begin
      for (j=0; j<=bounces; j=j+1) begin
        if (pin_select == PIN_SDA) begin
          SDA_GPIO <= ~SDA_GPIO;
        end
        else begin
          SCL_GPIO <= ~SCL_GPIO;
        end
        repeat(50) @(posedge clk);
        if (pin_select == PIN_SDA) begin
          SDA_GPIO <= ~SDA_GPIO;
        end
        else begin
          SCL_GPIO <= ~SCL_GPIO;
        end
        repeat(50) @(posedge clk);
      end
      if (pin_select == PIN_SDA) begin
        SDA_GPIO <= ~SDA_GPIO;
      end
      else begin
        SCL_GPIO <= ~SCL_GPIO;
      end
    end
  endtask

  task send_start();
    begin
      repeat(100) @(posedge clk);
      toggle_pin(1, PIN_SDA);
      repeat(150) @(posedge clk);
      toggle_pin(1, PIN_SCL);
    end
  endtask

  task send_byte(input integer value);
    begin
      for (i=0; i<8; i=i+1) begin
        repeat(200) @(posedge clk);
        bounce1 = $urandom_range(1, 3);
        if (SCL_GPIO == 1'b1) begin
          toggle_pin(bounce1, PIN_SCL);
        end
        else begin
          repeat(bounce1*100) @(posedge clk);
        end
        repeat((5-bounce1)*100) @(posedge clk);
        bounce2 = $urandom_range(1, 3);
        if (value & 1) begin
          if (SDA_GPIO == 1'b0) begin
            toggle_pin(bounce2, PIN_SDA);
          end
          else begin
            repeat(bounce2*100) @(posedge clk);
          end
          repeat((5-bounce2)*100) @(posedge clk);
        end
        else begin
          if (SDA_GPIO == 1'b1) begin
            toggle_pin(bounce2, PIN_SDA);
          end
          else begin
            repeat(bounce2*100) @(posedge clk);
          end
          repeat((5-bounce2)*100) @(posedge clk);
        end
        bounce3 = $urandom_range(1, 3);
        toggle_pin(bounce3, PIN_SCL);
        repeat((12-bounce3)*100) @(posedge clk);
        value = value >> 1;
      end
    end
  endtask

  task send_ack();
    begin
      bounce1 = $urandom_range(1, 3);
      if (SCL_GPIO == 1'b1) begin
        toggle_pin(bounce1, PIN_SCL);
      end
      else begin
        repeat(bounce1*100) @(posedge clk);
      end
      repeat((6-bounce1)*100) @(posedge clk);
      bounce2 = $urandom_range(1, 3);
      if (SDA_GPIO == 1'b1) begin
        toggle_pin(bounce2, PIN_SDA);
      end
      else begin
        repeat(bounce2*100) @(posedge clk);
      end
      repeat((6-bounce2)*100) @(posedge clk);
      bounce3 = $urandom_range(1, 3);
      toggle_pin(bounce3, PIN_SCL);
      repeat((12-bounce3)*100) @(posedge clk);
    end
  endtask

  task send_restart();
    begin
      bounce1 = $urandom_range(1, 3);
      if (SCL_GPIO == 1'b1) begin
        toggle_pin(bounce1, PIN_SCL);
      end
      else begin
        repeat(bounce1*100) @(posedge clk);
      end
      repeat((4-bounce1)*100) @(posedge clk);
      bounce2 = $urandom_range(1, 2);
      if (SDA_GPIO == 1'b1) begin
        toggle_pin(bounce2, PIN_SDA);
      end
      else begin
        repeat(bounce2*100) @(posedge clk);
      end
      repeat((3-bounce2)*100) @(posedge clk);
      toggle_pin(2, PIN_SDA);
      repeat(300) @(posedge clk);
      bounce3 = $urandom_range(1, 3);
      toggle_pin(bounce3, PIN_SCL);
      repeat((4-bounce3)*100) @(posedge clk);
      toggle_pin(2, PIN_SDA);
      repeat(200) @(posedge clk);
      toggle_pin(2, PIN_SCL);
    end
  endtask 

  task send_stop();
    begin
      bounce1 = $urandom_range(1, 3);
      if (SCL_GPIO == 1'b1) begin
        toggle_pin(bounce1, PIN_SCL);
      end
      else begin
        repeat(bounce1*100) @(posedge clk);
      end
      repeat((5-bounce1)*100) @(posedge clk);
      bounce2 = $urandom_range(1, 3);
      if (SDA_GPIO == 1'b1) begin
        toggle_pin(bounce2, PIN_SDA);
      end
      else begin
        repeat(bounce2*100) @(posedge clk);
      end
      repeat((7-bounce2)*100) @(posedge clk);
      toggle_pin(1, PIN_SCL);
      repeat(150) @(posedge clk);
      toggle_pin(2, PIN_SDA);
    end
  endtask


  
endmodule