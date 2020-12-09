`define ROWA 8
`define COLA 8
`define COLB 8
`define DEPTH 2



module MatrixMultiply(inputA, inputB, clk, rstn, din, op, outputC);
	input [0:4*`DEPTH*`ROWA*`COLA-1] inputA;
	input [0:4*`DEPTH*`COLB*`COLA-1] inputB;
	input clk;
	input rstn;
	input din;
	input op;
	output [0:8*`DEPTH*`ROWA*`COLB-1] outputC;

    reg [3:0] matA [0:`DEPTH*`ROWA*`COLA-1];
    reg [3:0] matB [0:`DEPTH*`COLB*`COLA-1];    
	reg [0:8*`DEPTH*`ROWA*`COLB-1] outputC;
	reg [7:0] matC [0:`DEPTH*`ROWA*`COLB-1];

	reg [7:0] stored[0:`ROWA-1][0:`COLB-1][0:`COLA-1];
	reg [7:0] added[0:`ROWA-1][0:`COLB-1];

	function [7:0] times;
		input [3:0] A;
		input [3:0] B;
		reg [7:0] store [0:3];
		reg [7:0] add [0:1];
		begin
			store[0] = B[0] ? {4'b0, A} : 8'b0;
			store[1] = B[1] ? {3'b0, A, 1'b0} : 8'b0;
			store[2] = B[2] ? {2'b0, A, 2'b0} : 8'b0;
			store[3] = B[3] ? {1'b0, A, 3'b0} : 8'b0;

			add[0] = store[0] + store[1];
			add[1] = store[2] + store[3];

			times = add[0] + add[1];
		end
	endfunction
    
    
    integer row = 0;
	integer col = 0;
	integer cola = 0;
	integer depth = 0;
	integer j = 0;
	
	always @(din or negedge rstn) begin
	    if (!rstn) begin
	        for (row = 0; row < `ROWA; row = row + 1) begin
				for (col = 0; col < `COLB; col = col + 1) begin
					for (depth = 0; depth < `DEPTH; depth = depth + 1) begin
						for (cola = 0; cola < `COLA; cola = cola + 1) begin
						    matA[depth*`ROWA*`COLA+row*`COLA+cola] <= 4'b0;
						    matB[depth*`COLA*`COLB+cola*`COLB+col] <= 4'b0;
						end
					end
				end
			end
	    end
	    else begin
	        for (row = 0; row < `ROWA; row = row + 1) begin
				for (col = 0; col < `COLB; col = col + 1) begin
					for (depth = 0; depth < `DEPTH; depth = depth + 1) begin
						for (cola = 0; cola < `COLA; cola = cola + 1) begin
						    for (j = 0; j < 4; j = j + 1) begin
                                matA[depth*`ROWA*`COLA+row*`COLA+cola][3-j] <= inputA[4*(depth*`ROWA*`COLA+row*`COLA+cola)+j];
                                matB[depth*`ROWA*`COLA+row*`COLA+cola][3-j] <= inputB[4*(depth*`COLB*`COLA+cola*`COLB+col)+j];
                            end
                        end
                    end
                end
            end
        end
	end
	
	always @(posedge clk or negedge rstn) begin	
		if (!rstn) begin
			// reset
			for (row = 0; row < `ROWA; row = row + 1) begin
				for (col = 0; col < `COLB; col = col + 1) begin
					for (depth = 0; depth < `DEPTH; depth = depth + 1) begin
						outputC[depth*`ROWA*`COLB+row*`COLB+col] <= 8'b0;
					end
					for (cola = 0; cola < `COLA; cola = cola + 1) begin
					    stored[row][cola][col] <= 8'b0;
					end
					added[row][col] <= 8'b0;
				end
			end
		end
		else begin
			for (depth = 0; depth < `DEPTH; depth = depth + 1) begin
				for (row = 0; row < `ROWA; row = row + 1) begin
					for (col = 0; col < `COLB; col = col + 1) begin
						for (cola = 0; cola < `COLA; cola = cola + 1) begin
							stored[row][col][cola] <= times(matA[row*`COLA+cola], matB[cola*`COLB+col]);
							for (j = 0; j < 8; j = j + 1) begin
							    matC[depth*`ROWA*`COLB+row*`COLB+col] =  matC[depth*`ROWA*`COLB+row*`COLB+col] + stored[row][col][cola];
							end
						end
					end
				end
			end
		end
	end
	
	always @(op or negedge rstn) begin
	    if (!rstn) begin
	        for (row = 0; row < `ROWA; row = row + 1) begin
				for (col = 0; col < `COLB; col = col + 1) begin
					for (depth = 0; depth < `DEPTH; depth = depth + 1) begin
						    matC[depth*`ROWA*`COLB+row*`COLB+cola] <= 8'b0;
					end
				end
			end
	    end
	    else begin
	        for (row = 0; row < `ROWA; row = row + 1) begin
				for (col = 0; col < `COLB; col = col + 1) begin
					for (depth = 0; depth < `DEPTH; depth = depth + 1) begin
					    for (j=0;j<8;j=j+1) begin
					        outputC[8*(depth*`ROWA*`COLB+row*`COLB+col)+j] <= matC[depth*`ROWA*`COLB+row*`COLB+col][7-j];
					    end
					end
			    end
			end
	    end
	end
endmodule

