module gf_mult_parallel #(
  parameter int WIDTH,
  parameter logic [WIDTH-1:0] PRIMITIVE
) (
  input logic [WIDTH-1:0] a_i, b_i,
  output logic [WIDTH-1:0] product_o
);

  //Produce mapping of X^k -> X^k mod primitive
  typedef logic [WIDTH-1:0] mapping_t [2*WIDTH-1];

  function automatic mapping_t make_mapping();
    mapping_t result;
    result[0] = 'd1;

    for (int i=1; i<(2*WIDTH-1); i++) begin
      if (result[i-1][WIDTH-1] == 1'b1)
        result[i] = (result[i-1] << 1) ^ PRIMITIVE;
      else
        result[i] = result[i-1] << 1;
    end

    return result;
  endfunction

  localparam mapping_t MAPPING = make_mapping();

  logic coeffs [2*WIDTH-1];

  //compute coeffs of expanded polynomial
  always_comb begin
    //x^0 ... x^(WIDTH-1)
    for (int i=0; i<WIDTH; i++) begin
      coeffs[i] = '0;
      for (int j=0; j<i+1; j++)
        coeffs[i] ^= a_i[j] & b_i[i-j];
    end

    //x^(WIDTH) ... x^(2*WIDTH-2)
    for (int i=WIDTH; i<(2*WIDTH-1); i++) begin
      coeffs[i] = '0;
      for (int j=(i-WIDTH+1); j<WIDTH; j++)
        coeffs[i] ^= a_i[j] & b_i[i-j];
    end

  end

  //compute product
  always_comb begin
    product_o = '0;
    for (int i=0; i<(2*WIDTH-1); i++)
      if (coeffs[i])
        product_o ^= MAPPING[i];
  end

endmodule





