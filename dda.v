//in the top-level module ///////////////////

module lorenz #(parameter N = 27) (
	input clk, reset,
	input signed [N-1:0] sigma, beta, rho, dt, x0, y0,z0,
	output signed [N-1:0] x, y, z
);

wire signed [N-1:0] dtx, dty, dtz;
wire signed [N-1:0] s1_out, s2_out, s3_out, s4_out;


assign dtx = x >>> 8;
assign dty = y >>> 8;
assign dtz = z >>> 8;

//instantiate signed_mult modules
  // s1_out = sigma*(y-x)*dt
  // s2_out = (x*(rho-z)*dt
  // s3_out - s4_out = (x*y-beta*z)*dt
signed_mult s1 (.a(dty-dtx), .b(sigma), .out(s1_out));
signed_mult s2 (.a(dtx), .b(rho - z), .out(s2_out));
signed_mult xy (.a(x), .b(dty), .out(s3_out));
signed_mult bz (.a(dtz), .b(beta), .out(s4_out));

//instantiate integrator module

integrator int1(x, s1_out, x0, clk, reset);
integrator int2(y, (s2_out-dty), y0, clk, reset);
integrator int3(z, (s3_out-s4_out), z0, clk, reset);

endmodule




module integrator(out,funct,InitialOut,clk,reset);
	output signed [26:0] out; 		//the state variable V
	input signed [26:0] funct;      //the dV/dt function
	input clk, reset;
	input signed [26:0] InitialOut;  //the initial state variable V
	
	wire signed	[26:0] out, v1new ;
	reg signed	[26:0] v1 ;
	
	always @ (posedge clk) 
	begin
		if (reset==0) //reset	
			v1 <= InitialOut ; // 
		else 
			v1 <= v1new ;	
	end
	assign v1new = v1 + funct ;
	assign out = v1 ;
endmodule


//// signed mult of 7.20 format 2'comp////////////
module signed_mult (out, a, b);
	output 	signed  [26:0]	out;
	input 	signed	[26:0] 	a;
	input 	signed	[26:0] 	b;
	// intermediate full bit length
	wire 	signed	[53:0]	mult_out;
	assign mult_out = a * b;
	// select bits for 7.20 fixed point
	assign out = {mult_out[53], mult_out[45:20]};
endmodule



