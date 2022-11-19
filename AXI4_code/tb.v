`timescale 1ns/1ps
module tb();
	
	reg clk, reset_n;
	reg s_axis_valid;
	reg [31:0] sigma, beta, rho, dt, x0, y0, z0;
	reg m_axis_ready;
	
	// reg [31:0] index;
	wire signed [31:0]  x_tb, y_tb, z_tb;
	wire s_axis_ready;
	wire m_axis_valid;
	wire [31:0] m_axis_data_x, m_axis_data_y, m_axis_data_z;
	

  lorenz DUT (
  s_axis_valid, s_axis_ready, m_axis_valid,clk, reset_n, sigma, beta, rho, dt, x0, y0, z0, x_tb, y_tb, z_tb,
  m_axis_data_x, m_axis_data_y, m_axis_data_z,m_axis_ready
);
	
	
	//Initialize clocks and index
	initial begin
    // $dumpfile("dump.vcd");
    // $dumpvars(1);
	clk = 1'b0;
    reset_n = 1'b0;
    dt = {7'h0, 25'h01000};
    x0 = {7'h7f, 25'd0};
    y0 = {7'h7f, 25'd0};
    z0 = {7'd25, 25'd0};
    beta = {7'd2, 25'haaaaa};
    sigma = {7'd10, 25'd0};
    rho = {7'd28, 25'd0};
    
    s_axis_valid = 0;
    m_axis_ready = 0;
	end
	
	//Toggle the clocks
	always begin
		forever clk = #10 ~clk;
	end
	
	//Intialize and drive signals
	initial begin
		#20 reset_n  = 1'b1;
		#20 s_axis_valid = 1;
		#30 m_axis_ready = 1;
	end
	
endmodule