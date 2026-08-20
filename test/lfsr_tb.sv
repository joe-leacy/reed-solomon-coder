module lfsr_tb;
  localparam int N = 8;
  localparam int K = 4;
  localparam int UNROLL = 2;
  localparam int WIDTH = 8;
  localparam logic [WIDTH-1:0] GENERATOR [N-K] = '{
    8'h40, //coeff of x^0
    8'h78,
    8'h36,
    8'h0F
  };
  localparam logic [WIDTH-1:0] PRIMITIVE = 8'h1D;
  localparam logic [WIDTH-1:0] ALPHA = 8'h02;

  logic clk, rst_n;
  logic [WIDTH-1:0] data [K];
  logic [WIDTH-1:0] data_unroll [UNROLL];
  logic [WIDTH-1:0] parity_unroll [N-K];
  logic [WIDTH-1:0] code [N];
  logic [WIDTH-1:0] syndrome [N-K];


  clocking cb @ (posedge clk);
    output rst_n;
    output data_unroll;
  endclocking

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

  lfsr #(
    .WIDTH (WIDTH),
    .N (N),
    .K (K),
    .UNROLL (UNROLL),
    .GENERATOR (GENERATOR),
    .PRIMITIVE (PRIMITIVE)
  ) u_lfsr_unroll (
      .clk (clk),
      .rst_n (rst_n),
      .data (data_unroll),
      .parity (parity_unroll)
  );

  initial begin
    clk = 1'b0;
    forever #5 clk = !clk;
  end

  initial begin
    $dumpfile("lfsr_tb.vcd");
    $dumpvars(0, lfsr_tb);
    data = {'d1, 'd2, 'd3, 'd4};
    cb.rst_n <= 1'b0;
    repeat (5) @ (cb);
    cb.rst_n <= 1'b1;
    cb.data_unroll <= {data[0], data[1]};
    @ (cb);
    cb.data_unroll <= {data[2], data[3]};
    repeat (3) @ (cb);
    $finish;
  end

endmodule



