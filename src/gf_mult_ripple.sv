module gf_mult_ripple#(
  parameter int WIDTH = 10,
  parameter logic [WIDTH-1:0] PRIMITIVE
)(
  input logic [WIDTH-1:0] a_i, b_i,
  output logic [WIDTH-1:0] product_o
);

  //Internal signals
  logic [WIDTH-1:0] partial_prods [WIDTH];


  assign partial_prods[0] = a_i;

  genvar i;

  generate
  for (i = 1; i < WIDTH; i++) begin: gen_partial_prods
    assign partial_prods[i] = (partial_prods[i-1] << 1) ^ (partial_prods[i-1][WIDTH-1] ? PRIMITIVE : '0);
  end
  endgenerate

  always_comb begin
    product_o = '0;
    for (int i = 0; i < WIDTH; i++) begin
      if (b_i[i])
        product_o ^= partial_prods[i];
    end
  end

endmodule





