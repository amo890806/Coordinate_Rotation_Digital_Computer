`timescale 1ns/10ps
`define CYCLE 10

module CORDIC_COS_SIN_tb ();
    
    parameter t_rst = `CYCLE*2;

    parameter DATA_WIDTH = 16;
    parameter PHASE_WIDTH = 32;
    parameter STAGE = 16;

    integer i;

    reg clk;
    reg rst;
    reg en;
    reg [DATA_WIDTH-1:0] x0;
    reg [DATA_WIDTH-1:0] y0;
    reg signed [PHASE_WIDTH-1:0] phase;
    wire valid;
    wire [DATA_WIDTH:0] cos;
    wire [DATA_WIDTH:0] sin;

    CORDIC_COS_SIN #(
        .DATA_WIDTH(DATA_WIDTH),
        .PHASE_WIDTH(PHASE_WIDTH),
        .STAGE(STAGE)
    ) cordic_cos_sin (
        .clk(clk),
        .rst(rst),
        .en(en),
        .x0(x0),
        .y0(y0),
        .phase(phase),  
        .valid(valid),
        .cos(cos),
        .sin(sin)
    );

    always #(`CYCLE/2) clk = ~clk;

    initial begin
        clk = 0; rst = 1; en = 0; phase = 0; x0 = 0; y0 = 0;
        #t_rst  rst = 0;
        #`CYCLE en = 1; x0 = 16'd39797; y0 = 0; phase = {2'd0, 30'd2949120};    //45*2^16
        #`CYCLE phase = {2'd1, 30'd2949120};
        #`CYCLE phase = {2'd2, -30'd2949120};   //-45*2^16  
        #`CYCLE phase = {2'd3, -30'd2949120};
        #`CYCLE en = 0; phase = 0;
        #5000 $finish;
    end

    initial begin
        $dumpfile("CORDIC_COS_SIN.vcd");
        $dumpvars;
        $dumpvars(0, cordic_cos_sin);
        for(i=0; i<STAGE; i=i+1)begin
            $dumpvars(1, cordic_cos_sin.x[i]);
            $dumpvars(1, cordic_cos_sin.y[i]);
            $dumpvars(1, cordic_cos_sin.z[i]);
            $dumpvars(1, cordic_cos_sin.x_shift[i]);
            $dumpvars(1, cordic_cos_sin.y_shift[i]);
        end
    end

endmodule