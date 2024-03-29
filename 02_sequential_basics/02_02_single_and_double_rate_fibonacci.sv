//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module fibonacci
(
  input               clk,
  input               rst,
  output logic [15:0] num
);

  logic [15:0] num2;

  always_ff @ (posedge clk)
    if (rst)
      { num, num2 } <= { 16'd1, 16'd1 };
    else
      { num, num2 } <= { num2, num + num2 };

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module fibonacci_2
(
  input               clk,
  input               rst,
  output logic [15:0] num,
  output logic [15:0] num2
);

  // Task:
  // Implement a module that generates two fibonacci numbers per cycle

  reg logic [15:0] num1_r;
  reg logic [15:0] num2_r;

  always_ff @ (posedge clk)
  begin
    if (rst)
      begin
        num1_r <= 16'd1; //Can also do { num1_r, num2_r } <= { 16'd1, 26'd1 };
        num2_r <= 16'd1;
      end else begin
        num1_r <= num1_r + num2_r;
        num2_r <= num1_r + num2_r + num2_r;
      end
  end

  assign num  = num1_r;
  assign num2 = num2_r;

endmodule

//----------------------------------------------------------------------------
// Testbench
//----------------------------------------------------------------------------

module testbench;

  logic clk;

  initial
  begin

    $dumpfile("dump.vcd");
    $dumpvars(0, testbench);

    clk = 0;

    forever
      # 500 clk = ~ clk;
  end

  logic rst;

  initial
  begin
    rst <= 'x;
    repeat (2) @ (posedge clk);
    rst <= '1;
    repeat (2) @ (posedge clk);
    rst <= '0;
  end

  logic [15:0] f1_num, f2_num, f2_num2;

  fibonacci   f1 (.num (f1_num), .*);
  fibonacci_2 f2 (.num (f2_num), .num2 (f2_num2), .*);

  localparam n = 10;

  logic [15:0] fifo1 [$], fifo2 [$];

  initial
  begin
    @ (negedge rst);

    while (fifo1.size () < n || fifo2.size () < n)
    begin
      @ (posedge clk);

      $display ("%d (%d %d)", f1_num, f2_num, f2_num2);

      fifo1.push_back (f1_num);
      fifo2.push_back (f2_num);
      fifo2.push_back (f2_num2);
    end

    while (fifo1.size () > 0 && fifo2.size () > 0)
    begin
      logic [15:0] n1, n2;

      n1 = fifo1.pop_front ();
      n2 = fifo2.pop_front ();

      if (n1 !== n2)
      begin
        $display ("%s FAIL %d !== %d", `__FILE__, n1, n2);
        $finish;
      end
    end

    $display ("%s PASS", `__FILE__);
    $finish;
  end

endmodule
