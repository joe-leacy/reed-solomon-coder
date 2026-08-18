module encoder_tb;

  localparam int N = 8;
  localparam int K = 4;
  localparam int WIDTH = 8;
  localparam logic [WIDTH-1:0] PRIMITIVE = 8'h1D ;
  localparam logic [WIDTH-1:0] GENERATOR [N-K] = '{
    8'h40,
    8'h78,
    8'h36,
    8'h0F
  };
  localparam int NUM_CODES = 10;

  logic clk, rst_n, valid;
  logic [WIDTH-1:0] data, code;
  logic [WIDTH-1:0] codewords [NUM_CODES][N];

  clocking cb @(posedge clk);
    output valid;
    output rst_n;
    output data;
  endclocking

  encoder #(
    .N (N),
    .K (K),
    .WIDTH (WIDTH),
    .PRIMITIVE (PRIMITIVE),
    .GENERATOR (GENERATOR)
  ) u_encoder (
    .clk (clk),
    .rst_n (rst_n),
    .data_i (data),
    .code_o (code),
    .valid (valid)
  );

  initial begin
    clk = 1'b0;
    forever #5 clk = !clk;
  end

  initial begin
    $dumpfile("encoder_tb.vcd");
    $dumpvars(0, encoder_tb);
    rst_n <= 1'b0;
    data <= '0;
    repeat (2) @ (cb);
    rst_n <= 1'b1;
    valid <= 1'b1;
    for (int i=0; i<NUM_CODES*K; i++) begin
      data <= $urandom();
      @ (cb);
    end
    $finish;
  end

endmodule
