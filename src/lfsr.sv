module lfsr #(
  parameter int LENGTH = 30,
  parameter int WIDTH = 10,
  parameter logic [WIDTH-1:0] GENERATOR [LENGTH],
  parameter logic [WIDTH-1:0] PRIMITIVE
) (
  input logic clk,
  input logic rst_n,
  input logic encoded,
  input logic next_parity,
  input logic [WIDTH-1:0] data_i,
  output logic [WIDTH-1:0] parity_sym_o
);

  //Feedback signals
  logic [WIDTH-1:0] feedback;
  logic [WIDTH-1:0] updates [LENGTH];
  logic [WIDTH-1:0] remainder [LENGTH];
  logic [WIDTH-1:0] parity [LENGTH];

  assign feedback = data_i ^ remainder[LENGTH-1];

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

  //update remainder
  always_ff @ (posedge clk, negedge rst_n) begin
    if (!rst_n || encoded) begin
      for (int i=0; i<LENGTH; i++)
        remainder[i] <= '0;
    end
    else begin
      remainder[0] <= updates[0];
      for (int i=1; i<LENGTH; i++)
        remainder[i] <= remainder[i-1] ^ updates[i];
    end
  end

  //update parity output
  always_ff @ (posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      for (int i=0; i<LENGTH; i++)
        parity[i] <= '0;
    end
    else if (encoded) begin
      parity[0] <= updates[0];
      for (int i=1; i<LENGTH; i++)
        parity[i] <= remainder[i-1] ^ updates[i];
    end
    else if (next_parity) begin
      for (int i=1; i<LENGTH; i++)
        parity[i] <= parity[i-1];
    end
  end

  assign parity_sym_o = parity[LENGTH-1];

endmodule
