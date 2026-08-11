module encoder #(
  parameter int N = 544,
  parameter int K = 514,
  parameter int WIDTH = 10,
  parameter logic [WIDTH-1:0] PRIMITIVE,
  parameter logic [WIDTH-1:0] GENERATOR [N-K]
)(
  input logic clk,
  input logic rst_n,
  input logic [WIDTH-1:0] data_i,
  output logic [WIDTH-1:0] code_o
);

//Reed-Solomon encoder for sequential symbols using an LFSR to perform the
//encoding and a ping-pong buffer to handle a continuous data stream


  logic [WIDTH-1:0] buf_a, buf_b [N];
  logic [$clog2(N)-1:0] count;
  logic encoded, parity_finished;
  logic [WIDTH-1:0] parity;
  logic tx_a, parity_select_a, parity_select_b, next_parity;
  logic [WIDTH-1:0] next_a, next_b;


  //--------------- LFSR --------------------------
  lfsr #(
    .LENGTH (N-K),
    .WIDTH (WIDTH),
    .GENERATOR (GENERATOR),
    .PRIMITIVE (PRIMITIVE)
  ) u_lfsr (
    .clk (clk),
    .rst_n (rst_n),
    .encoded (encoded),
    .next_parity (next_parity),
    .data_i (data_i),
    .parity_sym_o (parity)
  );

  //-----------------------------------------------

  //--------------- Encoding Counter --------------
  always_ff @ (posedge clk, negedge rst_n) begin
    if (!rst_n || count == N-1) count <= '0;
    else count <= count + 1;
  end

  assign encoded = (count == K-1);
  assign parity_finished = (count == N-1);

  //----------------------------------------------

  //--------------- Ping-Pong FSM ----------------
  typedef enum logic {FILL_A, PARITY_A, FILL_B, PARITY_B} buf_state_t;
  buf_state_t curr_state, next_state;

  always_ff @ (posedge clk, negedge rst_n) begin
    if (!rst_n) curr_state <= TX_A;
    else curr_state <= next_state;
  end

  //next state logic
  always_comb begin
    next_state = curr_state;
    case (curr_buf_state)
      FILL_A: begin
        if (encoded) next_state = PARITY_A;
      end
      PARITY_A: begin
        if (parity_finished) next_state = FILL_B;
      end
      FILL_B: begin
        if (encoded) next_state = PARITY_B;
      end
      PARITY_B: begin
        if (parity_finished) next_state = FILL_A;
      end
      default: next_state = FILL_A;
    endcase
  end

  //output logic
  assign tx_a = ((curr_state == FILL_B) || (curr_state == PARITY_B));
  assign parity_select_a = (curr_state == PARITY_A);
  assign parity_select_b = (curr_state == PARITY_B);
  assign next_parity = parity_select_a || parity_select_b;

  //---------------------------------------------

  //------------- Buffer Datapath ---------------
  always_ff @ (posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      for (int i=0; i<N; i++) begin
        buf_a[i] <= '0;
        buf_b[i] <= '0;
      end
    end
    else begin
      buf_a[0] <= next_a;
      buf_b[0] <= next_b;
      for (int i=1; i<N; i++) begin
        buf_a[i] <= buf_a[i-1];
        buf_b[i] <= buf_b[i-1];
      end
    end
  end

  assign next_a = parity_select_a ? parity : data_i;
  assign next_b = parity_select_b ? parity : data_i;

  assign code_o = tx_a ? buf_a[N-1] : buf_b[N-1];

  //--------------------------------------------

endmodule
