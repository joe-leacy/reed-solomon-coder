module lfsr_comb #(
  parameter int WIDTH = 10,
  parameter int N = 544,
  parameter int K = 514,
  parameter logic [WIDTH-1:0] GENERATOR [N-K],
  parameter logic [WIDTH-1:0] PRIMITIVE
) (
  input logic [WIDTH-1:0] data_i [K],
  output logic [WIDTH-1:0] code_o [N]
);

  logic [WIDTH-1:0] parity [K][N-K];
  logic [WIDTH-1:0] parity_partial [1:K-1][1:N-K-1];

  genvar i,j;

  //First stage parity symbols
  generate
    for (i=0; i<N-K; i++) begin: gen_first_parity
      gf_mult_ripple #(
        .WIDTH (WIDTH),
        .PRIMITIVE (PRIMITIVE)
      ) u_gfm (
        .a_i (data_i[0]),
        .b_i (GENERATOR[i]),
        .product_o (parity[0][i])
      );
    end
  endgenerate

  //Recursive computation of parity symbol at first index
  generate
    for (i=1; i<K; i++) begin: gen_parity_0
      gf_mult_ripple #(
        .WIDTH (WIDTH),
        .PRIMITIVE (PRIMITIVE)
      ) u_gfm (
        .a_i (parity[i-1][N-K-1] ^ data_i[i]),
        .b_i (GENERATOR[0]),
        .product_o (parity[i][0])
      );
    end
  endgenerate

  //Recursive computation of remaining parity symbols
  generate
    for (i=1; i<K; i++)
      for (j=1; j<N-K; j++) begin: gen_parity_remaining
        gf_mult_ripple #(
          .WIDTH (WIDTH),
          .PRIMITIVE (PRIMITIVE)
        ) u_gfm (
          .a_i (parity[i-1][N-K-1] ^ data_i[i]),
          .b_i (GENERATOR[j]),
          .product_o (parity_partial[i][j])
        );
        assign parity[i][j] = parity_partial[i][j] ^ parity[i-1][j-1];
      end
  endgenerate

  //Forming systematic codeword
  always_comb begin
    for (int i=0; i<K; i++)
      code_o[i] = data_i[i];
    for (int j=0; j<N-K; j++)
      code_o[j+K] = parity[K-1][N-K-j-1];
  end

endmodule
