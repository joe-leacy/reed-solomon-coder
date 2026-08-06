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

  )
