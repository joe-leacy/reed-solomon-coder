module syndrome_checker #(
  parameter int WIDTH = 10,
  parameter logic [WIDTH-1:0] ALPHA,
  parameter int N,
  parameter int K,
  parameter logic [WIDTH-1:0] PRIMITIVE
)(
  input  logic [WIDTH-1:0] codeword_i [0:N-1],
  output logic [WIDTH-1:0] syndrome_o [0:N-K-1]
);

  localparam int NSYND = N-K;

  logic [WIDTH-1:0] roots [0:NSYND-1];
  logic [WIDTH-1:0] horner_stage [0:NSYND-1][0:N-1];
  logic [WIDTH-1:0] horner_mult [0:NSYND-1][0:N-2];

  assign roots[0] = 'd1;

  genvar r;
  generate
    for (r = 1; r < NSYND; r++) begin : gen_roots
      gf_mult_ripple #(
        .WIDTH     (WIDTH),
        .PRIMITIVE (PRIMITIVE)
      ) u_root_mult (
        .a_i       (roots[r-1]),
        .b_i       (ALPHA),
        .product_o (roots[r])
      );
    end
  endgenerate

  genvar s, j;
  generate
    for (s = 0; s < NSYND; s++) begin : gen_syndromes

      for (j = 0; j < N-1; j++) begin : gen_horner_mult

        gf_mult_ripple #(
          .WIDTH     (WIDTH),
          .PRIMITIVE (PRIMITIVE)
        ) u_horner_mult (
          .a_i       (horner_stage[s][j]),
          .b_i       (roots[s]),
          .product_o (horner_mult[s][j])
        );

      end

    end
  endgenerate


  always_comb begin
    for (int s = 0; s < NSYND; s++) begin
      horner_stage[s][0] = codeword_i[0];
      for (int j = 1; j < N; j++) begin
        horner_stage[s][j] =
            horner_mult[s][j-1] ^ codeword_i[j];
      end
      syndrome_o[s] = horner_stage[s][N-1];
    end
  end
endmodule
