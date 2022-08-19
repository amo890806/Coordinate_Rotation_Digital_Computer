module CORDIC_ROTATE #(
    parameter DATA_WIDTH = 16,
    parameter PHASE_WIDTH = 32,
    parameter STAGE = 16
) (
    input clk,
    input rst,
    input en,
    input signed [DATA_WIDTH-1:0] x0,
    input signed [DATA_WIDTH-1:0] y0,
    input signed [PHASE_WIDTH-1:0] phase,   //{quadrant, value}
    output valid,
    output [DATA_WIDTH:0] cos,
    output [DATA_WIDTH:0] sin
);
/*
    According to CORDIC Algorithm, let x_in = K, y_in = 0, 
    to calculate COS and SIN, x_out = cos(z_in), y_out = sin(z_in)
*/
parameter K = 32'd39797;    //K = 0.607253*2^16
//Look Up Table of arctan
parameter [PHASE_WIDTH*STAGE-1:0] atan = {32'd128, 32'd256, 32'd448, 32'd896, 32'd1856, 32'd3648, 32'd7360, 32'd14656, 32'd29312,
                                         32'd58688, 32'd117312, 32'd234368, 32'd466944, 32'd919872, 32'd1740992, 32'd2949120};

integer i, j;
wire [1:0] quadrant;
assign quadrant = phase[PHASE_WIDTH-1:PHASE_WIDTH-2];
reg signed [DATA_WIDTH:0] x_pre;
reg signed [DATA_WIDTH:0] y_pre;
reg signed [PHASE_WIDTH-1:0] z_pre;
reg signed [DATA_WIDTH:0] x [0:STAGE-1];
reg signed [DATA_WIDTH:0] y [0:STAGE-1];
reg signed [PHASE_WIDTH-1:0] z [0:STAGE-1];
reg signed [DATA_WIDTH:0] x_shift [0:STAGE-1]; 
reg signed [DATA_WIDTH:0] y_shift [0:STAGE-1];
reg [STAGE-1:0] sign;

always @(*) begin
    for(i=0; i<STAGE; i=i+1)begin
        x_shift[i] = x[i] >>> i;
        y_shift[i] = y[i] >>> i;
        sign[i] = z[i][PHASE_WIDTH-1];
    end
end

//Pre-rotation for angles which abs(phase) > pi/2
wire [DATA_WIDTH:0] x0_pos, x0_neg;
wire [DATA_WIDTH:0] y0_pos, y0_neg;
assign x0_pos = (x0 == 0) ? 0 : {1'b0, x0};
assign x0_neg = (x0 == 0) ? 0 : {1'b1, (~x0)+16'b1};
assign y0_pos = (y0 == 0) ? 0 : {1'b0, y0};
assign y0_neg = (y0 == 0) ? 0 : {1'b1, (~y0)+16'b1};
always @(posedge clk or posedge rst) begin
    if(rst)begin
        x_pre <= 0;
        y_pre <= 0;
        z_pre <= 0;
    end
    else begin
        if(en)begin
            case (quadrant)
                0:begin
                    x_pre <= x0_pos;
                    y_pre <= y0_pos;
                    z_pre <= phase;
                end
                1:begin
                    x_pre <= y0_neg;
                    y_pre <= x0_pos;
                    z_pre <= {2'b00, phase[29:0]};
                end
                2:begin
                    x_pre <= y0_pos;
                    y_pre <= x0_neg;
                    z_pre <= {2'b11, phase[29:0]};
                end
                3:begin
                    x_pre <= x0_pos;
                    y_pre <= y0_pos;
                    z_pre <= phase;
                end
            endcase
        end
        else begin
            x_pre <= 0;
            y_pre <= 0;
            z_pre <= 0;
        end
    end
end


//Iteration
always @(posedge clk or posedge rst) begin
    if(rst)begin
        for(i=0; i<STAGE; i=i+1)begin
            x[i] <= 0;
            y[i] <= 0;
            z[i] <= 0;
        end
    end
    else begin
        x[0] <= x_pre;
        y[0] <= y_pre;
        z[0] <= z_pre;
        for(i=0; i<STAGE; i=i+1)begin
            x[i+1] <= sign[i] ? x[i]+y_shift[i] : x[i]-y_shift[i];
            y[i+1] <= sign[i] ? y[i]-x_shift[i] : y[i]+x_shift[i];
            z[i+1] <= sign[i] ? z[i]+atan[32*(i+1)-1 -: 32] : z[i]-atan[32*(i+1)-1 -: 32];
        end
    end
end

assign cos = x[STAGE-1];
assign sin = y[STAGE-1];
assign valid = en_dly[STAGE];

reg [4:0] cnt;
always @(posedge clk or posedge rst) begin
    if(rst)begin
        cnt <= 0;
    end
    else begin
        if(cnt == 0)begin
            if(en)begin
                cnt <= cnt + 1;
            end
        end
        else begin
            cnt <= (cnt == 16) ? 0 : cnt+1;
        end
    end
end

reg [STAGE:0] en_dly;
always @(posedge clk or posedge rst) begin
    if(rst)begin
        en_dly <= 0;
    end
    else begin
        en_dly[0] <= en;
        for(i=0; i<STAGE; i=i+1)begin
            en_dly[i+1] <= en_dly[i];
        end
    end
end
    
endmodule