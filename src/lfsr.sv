module lfsr #(
  parameter int LENGTH = 30,
  parameter int WIDTH = 10,
  parameter logic [WIDTH-1:0] GENERATOR [LENGTH],
  parameter logic [WIDTH-1:0] PRIMITIVE
) (
  input logic clk,
  input logic rst_n,
  input logic [WIDTH-1:0] data_i,
  output logic [WIDTH-1:0] remainder_o [LENGTH]
);

  //Feedback signals
  logic [WIDTH-1:0] feedback;
  logic [WIDTH-1:0] updates [LENGTH];

  assign feedback = data_i ^ remainder_o[LENGTH-1];

  //Compute LFSR update
  genvar i;
  generate
    for (i=0; i<LENGTH; i++) begin: gen_gf_mults
      gf_mult_ripple #(
        .WIDTH (WIDTH),
        .PRIMITIVE (PRIMITIVE)
      ) u_gfm (
        .a_i (feedback),
        .b_i (GENERATOR[i]),
        .product_o (updates[i])
      );
    end
  endgenerate

  //LFSR update to recursively compute remainder polynomial
  always_ff @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      for (int i = 0; i < LENGTH; i++)
        remainder_o[i] <= '0;
    end
    else begin
      remainder_o[0] <= updates[0];
      for (int i = 1; i < LENGTH; i++)
        remainder_o[i] <= remainder_o[i-1] ^ updates[i];
    end
  end

endmodule
