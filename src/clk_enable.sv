module clk_enable #(
  parameter int DELAY_1,
  parameter int DELAY_2
)(
  input logic clk,
  input logic rst_n,
  output logic enable_1,
  output logic enable_2
);
