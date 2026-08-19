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
  logic [WIDTH-1:0] update_partial [1:K-1][1:N-K-1];

  genvar i,j;

  //First stage of update for all indices
  generate
    for (i=0; i<N-K; i++) begin: gen_first_parity
      gf_mult_ripple #(
        .WIDTH (WIDTH),
        .PRIMITIVE (PRIMITIVE)
      ) u_gfm (
        .a_i (data_i[0] ^ parity[N-K]),
        .b_i (GENERATOR[i]),
        .product_o (update[0][i])
      );
    end
  endgenerate

  //Compute update at index 0
  generate
    for(i=1; i<UNROLL; i++) begin: gen_parity_0
      gf_mult_ripple #(
        .WIDTH (WIDTH),
        .PRIMITIVE (PRIMITIVE)
      ) u_gfm (
        .a_i (update[i-1][N-K-1] ^ data[i]),
        .b_i (GENERATOR),
        .product_o (update[i][0])
      );
    end
  endgenerate

  //Compute update for remaining indices
  generate
    for (i=1; i<UNROLL; i++)
      for (j=1; j<N-K; j++) begin: gen_parity_remaining
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
