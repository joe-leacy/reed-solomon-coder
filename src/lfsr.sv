module lfsr #(
  parameter LENGTH = 30,
  parameter WIDTH = 10,
  parameter [WIDTH-1:0] COEFFS [LENGTH]
) (
  input logic clk,
  input logic rst_n,
  input logic [WIDTH-1:0] data_i,
  output logic [WIDTH-1:0] lfsr_o [LENGTH]
);

  //Internal Signals/Registers
  logic [WIDTH-1:0] feedback;
  logic [WIDTH-1:0] updates [LENGTH];

  // Update signals
  assign feedback = data_i ^ lfsr_o[LENGTH-1];

  //TODO: instantiate GF multiplication engine


  //LFSR update to recursively compute remainder polynomial
  always_ff @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      for (int i = 0; i < LENGTH; i++)
        lfsr_o[i] <= '0;
    end
    else begin
      lfsr_o[0] <= updates[0];
      for (int i = 1; i < LENGTH; i++)
        lfsr_o[i] <= lfsr_o[i-1] ^ updates[i];
    end
  end

endmodule
