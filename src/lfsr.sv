module lfsr #(
  parameter int WIDTH = 10,
  parameter int N = 544,
  parameter int K = 514,
  parameter int UNROLL = 2,
  parameter logic [WIDTH-1:0] GENERATOR [N-K],
  parameter logic [WIDTH-1:0] PRIMITIVE
) (
  input logic clk,
  input logic rst_n,
  input logic [WIDTH-1:0] data [UNROLL],
  output logic [WIDTH-1:0] parity [N-K]
);

  logic [WIDTH-1:0] update [UNROLL][N-K];
  logic [WIDTH-1:0] update_partial [UNROLL][N-K];

  genvar i,j;

  //First stage of update for all indices
  gf_mult_ripple #(
    .WIDTH (WIDTH),
    .PRIMITIVE (PRIMITIVE)
  ) u_gfm_00 (
    .a_i (parity[N-K-1] ^ data[0]),
    .b_i (GENERATOR[0]),
    .product_o (update[0][0])
  );

  generate
    for (i=1; i<N-K; i++) begin: gen_first_update
      gf_mult_ripple #(
        .WIDTH (WIDTH),
        .PRIMITIVE (PRIMITIVE)
      ) u_gfm (
        .a_i (parity[N-K-1] ^ data[0]),
        .b_i (GENERATOR[i]),
        .product_o (update_partial[0][i])
      );
      assign update[0][i] = update_partial[0][i] ^ parity[i-1];
    end
  endgenerate

  //Compute update at index 0
  generate
    for(i=1; i<UNROLL; i++) begin: gen_update_0
      gf_mult_ripple #(
        .WIDTH (WIDTH),
        .PRIMITIVE (PRIMITIVE)
      ) u_gfm (
        .a_i (update[i-1][N-K-1] ^ data[i]),
        .b_i (GENERATOR[0]),
        .product_o (update[i][0])
      );
    end
  endgenerate

  //Compute update for remaining indices
  generate
    for (i=1; i<UNROLL; i++)
      for (j=1; j<N-K; j++) begin: gen_update_remaining
        gf_mult_ripple #(
          .WIDTH (WIDTH),
          .PRIMITIVE (PRIMITIVE)
        ) u_gfm (
          .a_i (update[i-1][N-K-1] ^ data[i]),
          .b_i (GENERATOR[j]),
          .product_o (update_partial[i][j])
        );
        assign update[i][j] = update_partial[i][j] ^ update[i-1][j-1];
      end
  endgenerate


  always_ff @ (posedge clk) begin
    if (!rst_n)
      for (int i=0; i<N-K; i++)
        parity[i] <= '0;
    else
      for (int i=0; i<N-K; i++)
        parity[i] <= update[UNROLL-1][i];
  end

endmodule
