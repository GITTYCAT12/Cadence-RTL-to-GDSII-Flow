// Counter self-checking testbench
module counter_test;
  reg clk;
  reg rst;
  wire [7:0] count;
  integer expected;

  counter counter1 (
    .clk   (clk),
    .rst   (rst),
    .count (count)
  );

  // 100 MHz clock: 10 ns period.
  always #5 clk = ~clk;

  initial begin
    clk = 1'b0;
    rst = 1'b0;
    expected = 0;

    // Reset is active-low and asynchronous in the RTL.
    #2;
    if (count !== 8'h00) begin
      $display("FAIL: reset did not clear count, count=%0h", count);
      $finish;
    end

    rst = 1'b1;

    // Check four consecutive counter increments.
    repeat (4) begin
      @(posedge clk);
      expected = expected + 1;
      #1;
      if (count !== expected[7:0]) begin
        $display("FAIL: expected count=%0d, got %0d at %0t ns", expected, count, $time);
        $finish;
      end
    end

    // Verify the asynchronous reset independently of a clock edge.
    #2;
    rst = 1'b0;
    #1;
    if (count !== 8'h00) begin
      $display("FAIL: asynchronous reset did not clear count, count=%0h", count);
      $finish;
    end

    $display("PASS: counter reset and increment checks completed successfully.");
    $finish;
  end
endmodule
