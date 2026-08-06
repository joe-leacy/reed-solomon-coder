module lfsr_tb;
  localparam int LFSR_LEN = 4;
  localparam int WIDTH = 8;
  localparam int MSG_LEN = 5;
  localparam int CODE_LEN = MSG_LEN + LFSR_LEN;
  localparam logic [WIDTH-1:0] GENERATOR [LFSR_LEN] = '{
    8'h40, //coeff of x^0
    8'h78,
    8'h36,
    8'h0F
  };
  localparam logic [WIDTH-1:0] PRIMITIVE = 8'h1D;
  localparam logic [WIDTH-1:0] ALPHA = 8'h02;

  logic clk, rst_n;
  logic [WIDTH-1:0] message [MSG_LEN];
  logic [WIDTH-1:0] data;
  logic [WIDTH-1:0] remainder [LFSR_LEN];
  logic [WIDTH-1:0] codeword [CODE_LEN];
  logic encoded;
  logic [WIDTH-1:0] syndrome [LFSR_LEN];

  always_comb begin
    for (int i=0; i<MSG_LEN; i++)
      codeword[i] = message[i];
    for (int j=0; j<LFSR_LEN; j++)
      codeword[j+MSG_LEN] = remainder[LFSR_LEN-j-1];
  end

  lfsr #(
    .LENGTH(LFSR_LEN),
    .WIDTH (WIDTH),
    .GENERATOR (GENERATOR),
    .PRIMITIVE (PRIMITIVE)
  ) u_lfsr (
    .clk (clk),
    .rst_n (rst_n),
    .data_i (data),
    .parity_o (remainder),
    .encoded  (encoded)
  );

  syndrome_checker #(
    .WIDTH (WIDTH),
    .ALPHA (ALPHA),
    .N (CODE_LEN),
    .K (MSG_LEN),
    .PRIMITIVE (PRIMITIVE)
  ) u_syndrome_checker (
    .codeword_i (codeword),
    .syndrome_o (syndrome)
  );

  initial begin
    message[0] = 8'h01;
    message[1] = 8'h02;
    message[2] = 8'h03;
    message[3] = 8'h04;
    message[4] = 8'h05;
  end

  initial begin
    clk = 1'b0;
    forever #5 clk = !clk;
  end

  initial begin
    $dumpfile("lfsr_tb.vcd");
    $dumpvars(0, lfsr_tb);
    rst_n = 1'b0;
    data = '0;
    encoded = 1'b0;
    repeat (2) @ (posedge clk);
    rst_n = 1'b1;
    for (int i=0; i<MSG_LEN; i++) begin
      @ (negedge clk);
      data = message[i];
    end
    encoded = 1'b1;
    @ (negedge clk)
    $finish;
  end

endmodule

