`timescale 1ns/1ps

module lorenz #(parameter DATA_WIDTH = 32) (s_axis_valid, s_axis_ready, m_axis_valid,
                                            clk, reset_n, m_axis_data_x, m_axis_data_y, m_axis_data_z,m_axis_ready);
                                            
    input clk;
    input reset_n;
    //AXI4-S slave i/f which is accepting the data
    input s_axis_valid;
    parameter [31:0] sigma = {7'd10, 25'd0}, beta = {7'd2, 25'haaaaa}, rho = {7'd28, 25'd0},  z0 = {7'd25, 25'd0}, y0 = {7'h7f, 25'd0}, x0 = {7'h7f, 25'd0},dt = {7'h0, 25'h01000};
    
    
    wire signed [DATA_WIDTH-1:0] x, y, z;
    output s_axis_ready;
    //AXI4-S master i/f which sends out data
    output reg m_axis_valid;
    output reg signed [DATA_WIDTH-1:0] m_axis_data_x, m_axis_data_y, m_axis_data_z;
    input m_axis_ready;
    
    wire signed [DATA_WIDTH-1:0] dtx, dty, dtz;
    wire signed [DATA_WIDTH-1:0] s1_out, s2_out, s3_out, s4_out;
    
    
    assign dtx = x >>> 8;
    assign dty = y >>> 8;
    assign dtz = z >>> 8;
    
    //instantiate signed_mult modules
    // s1_out = sigma*(y-x)*dt
    // s2_out = (x*(rho-z)*dt
    // s3_out - s4_out = (x*y-beta*z)*dt
    signed_mult s1 (.a(dty-dtx), .b(sigma), .out(s1_out));
    signed_mult s2 (.a(dtx), .b(rho - z), .out(s2_out));
    signed_mult xy (.a(dtx), .b(y), .out(s3_out));
    signed_mult bz (.a(dtz), .b(beta), .out(s4_out));
    
    //instantiate integrator module
    
    integrator int1(x, s1_out, x0, clk, reset_n);
    integrator int2(y, (s2_out-dty), y0, clk, reset_n);
    integrator int3(z, (s3_out-s4_out), z0, clk, reset_n);
    
    assign s_axis_ready = m_axis_ready;
    
    always @(posedge clk) begin
        if(s_axis_valid & s_axis_ready) begin
            m_axis_data_x <= x;
            m_axis_data_y <= y;
            m_axis_data_z <= z;
            
        end
    end
    
    always @(posedge clk) begin
        m_axis_valid <= s_axis_valid ;
    end
    endmodule
    



module integrator(out,funct,InitialOut,clk,reset_n);
	output signed [31:0] out; 		//the state variable V
	input signed [31:0] funct;      //the dV/dt function
	input clk, reset_n;
	input signed [31:0] InitialOut;  //the initial state variable V
	
	wire signed	[31:0] out, v1new ;
	reg signed	[31:0] v1 ;
	
	always @ (posedge clk) 
	begin
		if (reset_n==0) //reset	
			v1 <= InitialOut ; // 
		else 
			v1 <= v1new ;	
	end
	assign v1new = v1 + funct ;
	assign out = v1 ;
endmodule


//// signed mult of 7.20 format 2'comp////////////
module signed_mult (out, a, b);
	output 	signed  [31:0]	out;
	input 	signed	[31:0] 	a;
	input 	signed	[31:0] 	b;
	// intermediate full bit length
	wire 	signed	[63:0]	mult_out;
	assign mult_out = a * b;
	// select bits for 7.20 fixed point
	assign out = {mult_out[63], mult_out[55:25]};
endmodule

module tb();
	
	reg clk, reset_n;
	reg s_axis_valid;
//	reg [31:0] sigma, beta, rho, dt, x0, y0, z0;
	reg m_axis_ready;
	
	// reg [31:0] index;
//	wire signed [31:0]  x_tb, y_tb, z_tb;
	wire s_axis_ready;
	wire m_axis_valid;
	wire [31:0] m_axis_data_x, m_axis_data_y, m_axis_data_z;
	

  lorenz DUT (
  s_axis_valid, s_axis_ready, m_axis_valid,clk, reset_n,
  m_axis_data_x, m_axis_data_y, m_axis_data_z,m_axis_ready
);
	
	
	//Initialize clocks and index
	initial begin
    // $dumpfile("dump.vcd");
    // $dumpvars(1);
	clk = 1'b0;
    reset_n = 1'b0;
//    dt = {7'h0, 25'h01000};
//    x0 = {7'h7f, 25'd0};
//    y0 = {7'h7f, 25'd0};
//    z0 = {7'd25, 25'd0};
//    beta = {7'd2, 25'haaaaa};
//    sigma = {7'd10, 25'd0};
//    rho = {7'd28, 25'd0};
    
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