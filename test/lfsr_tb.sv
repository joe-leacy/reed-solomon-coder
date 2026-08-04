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
  logic [WIDTH-1:0] parity;

  assign codeword = {message, remainder};

  always_comb begin
    parity = '0;
    for (int i=0; i<CODE_LEN; i++) begin
      parity ^= codeword[i];
    end
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
    .remainder_o (remainder)
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
    repeat (2) @ (posedge clk);
    rst_n = 1'b1;
    for (int i=0; i<MSG_LEN; i++) begin
      @ (negedge clk);
      data = message[i];
    end
    @ (negedge clk)
    $finish;
  end

endmodule

