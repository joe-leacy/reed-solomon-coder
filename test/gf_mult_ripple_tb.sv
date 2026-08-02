module gf_mult_ripple_tb;
  
  parameter int WIDTH = 4;
  parameter [WIDTH-1:0] PRIMITIVE = 4'b0011;

  logic [WIDTH-1:0] a, b, prod;

  gf_mult_ripple #(
    .WIDTH(WIDTH),
    .PRIMITIVE(PRIMITIVE)
  ) u_gfm (
    .a_i(a),
    .b_i(b),
    .product_o(prod)
  );

  initial begin
    $dumpfile("gf_mult_ripple_tb.vcd");
    $dumpvars(0, gf_mult_ripple_tb);
    a = '0;
    b = '0;
    #5;
    a = 4'b1011;
    b = 4'b0101;
    #5;
    a = 4'b1111;
    b = 4'b1111;
    #5;
    $finish;
  end

endmodule
