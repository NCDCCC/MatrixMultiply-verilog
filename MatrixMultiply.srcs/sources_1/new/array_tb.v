`timescale 1ns / 1ps
`define ROWA 8
`define COLA 8
`define COLB 8
`define DEPTH 2


module MatrixMultiply_tb();
	reg clk;
	reg rstn;
	reg din;
	reg op;
	reg [0:4*`DEPTH*`ROWA*`COLA-1] inputA;
	reg [0:4*`DEPTH*`COLA*`COLB-1] inputB;
	wire [0:12*`DEPTH*`ROWA*`COLB-1] outputC;
	reg [3:0] A[0:`DEPTH*`ROWA*`COLA-1];
	reg [3:0] B[0:`DEPTH*`COLA*`COLB-1];
	//reg [7:0] C[0:`DEPTH*`ROWA*`COLB-1];

	MatrixMultiply MatrixMultiply(
		.clk(clk),
		.rstn(rstn),
		.din(din),
		.op(op),
		.inputA(inputA),
		.inputB(inputB),
		.outputC(outputC)
	);

	integer i = 0;
	integer j = 0;
	initial begin
		clk = 1'b0;
		rstn = 1'b1;
		din = 1'b1;
		op = 1'b1;
		#50;
		$readmemb("C:/DSP/inputA.txt", A);
		$readmemb("C:/DSP/inputB.txt", B);
		for (i=0;i<`DEPTH*`ROWA*`COLA;i=i+1) begin
			for (j=0;j<4;j=j+1) begin
				inputA[i*4+j] = A[i][j];
			end
		end
		for (i=0;i<`DEPTH*`COLA*`COLB;i=i+1) begin
			for (j=0;j<4;j=j+1) begin
				inputB[i*4+j] = B[i][j];
			end
		end

	end
	always #5 clk = ~clk;
endmodule