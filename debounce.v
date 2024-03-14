module debounce #(
    parameter CTR_LEN = 4
) (
    input clk,
    input rst,
    input in,
    output reg out
);
  // Make counter register much larger
  // than debounce constant, to minimize
  // possibility of invalid toggle.
  reg [CTR_LEN + 2 :0] ctr_d, ctr_q;
  reg in_d, in_q;
  wire in_changed;
  wire ctr_done;
 
  assign in_changed = (in_q != in_d);
  assign ctr_done = (ctr_d == {(CTR_LEN - 1){1'b1}});
 
  always @(posedge clk) begin
    if (rst == 1'b1) begin
      ctr_d <= {(CTR_LEN -1){1'b0}};
      in_d <= 1'b1;
      in_q <= 1'b1;
      out <= 1'b1;
    end
    else begin
      in_d <= in;
      in_q <= in_d;
      //ctr_q <= ctr_d;
      ctr_d <= in_changed ? {(CTR_LEN -1){1'b0}} : ctr_d + 1'b1;
      if (ctr_done == 1'b1 & !in_changed) begin
        out <= in;
      end
    end
  end
 
endmodule