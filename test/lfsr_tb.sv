module lfsr_tb;
  localparam int N = 8;
  localparam int K = 4;
  localparam int WIDTH = 8;
  localparam logic [WIDTH-1:0] GENERATOR [N-K] = '{
    8'h40, //coeff of x^0
    8'h78,
    8'h36,
    8'h0F
  };
  localparam logic [WIDTH-1:0] PRIMITIVE = 8'h1D;
  localparam logic [WIDTH-1:0] ALPHA = 8'h02;

  logic [WIDTH-1:0] data [K];
  logic [WIDTH-1:0] code [N];
  logic [WIDTH-1:0] syndrome [N-K];

  lfsr_comb #(
    .WIDTH (WIDTH),
    .N (N),
    .K (K),
    .GENERATOR (GENERATOR),
    .PRIMITIVE (PRIMITIVE)
  ) u_lfsr (
    .data_i (data),
    .code_o (code)
  );

  syndrome_checker #(
    .WIDTH (WIDTH),
    .ALPHA (ALPHA),
    .N (N),
    .K (K),
    .PRIMITIVE (PRIMITIVE)
  ) u_syndrome_checker (
    .codeword_i (code),
    .syndrome_o (syndrome)
  );

  initial begin
    $dumpfile("lfsr_tb.vcd");
    $dumpvars(0, lfsr_tb);
    data = '{default: '0};
    #10;
    data = {'d1, 'd2, 'd3, 'd4};
    #10;
    $finish;
  end

endmodule



