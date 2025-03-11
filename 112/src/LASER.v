module LASER (
input CLK,
input RST,
input [3:0] X,
input [3:0] Y,
output reg [3:0] C1X,
output reg [3:0] C1Y,
output reg [3:0] C2X,
output reg [3:0] C2Y,
output  DONE);

    

/*************************

    The question assumes a fixed area of 16x16 with 40 targets.
    Only two laser shots are allowed on this area,
    and the lasers have a circular shape with a radius of 4.
    
    Please find the positions of the centers of these two circles such that
    they cover the maximum number of targets.

*************************/ 
    

    reg [2:0] curr_state,next_state;
    
    localparam READDATA = 3'b000,
                BUSY = 3'b001,
                FINISH = 3'b010;

    always @(posedge CLK or posedge RST) begin
        if(RST)
            curr_state <= 3'b000;
        else
            curr_state <= next_state;
    end

    wire read_done;
    wire busy_done;
    reg [3:0] reg_X [39:0]; 
    reg [3:0] reg_Y [39:0]; 
    reg [5:0] cnt;
    reg [3:0] tmp_x,tmp_y;
        reg [3:0] find_cnt;
    assign DONE = (curr_state == FINISH);
    assign read_done = (curr_state == READDATA) & (cnt == 6'd40);
    assign busy_done = find_cnt == 4'd3;
    always @(*) begin
        case(curr_state)
            READDATA:begin
                if(read_done)                                              
                    next_state = BUSY;
                else
                    next_state = READDATA;  
            end
            BUSY:begin
                if(busy_done)
                    next_state = FINISH;
                else
                    next_state = BUSY;
            end
            default:begin
                next_state = READDATA;
                
            end
            

        endcase
    end
    // cnt assign
    always @(posedge CLK or posedge RST) begin
        if(RST)
            cnt <= 6'b0;
        else if((curr_state == READDATA) & (next_state == BUSY))
            cnt <= 6'b0;
        else if(curr_state == READDATA)
            cnt <= cnt + 1'b1; 
        else if(curr_state == BUSY)
            cnt <=(cnt == 6'd40)?6'b0 :( cnt + 1'b1);
        else 
            cnt <= 6'b0;
    end
    //read data
    always @(posedge CLK) begin
        if(curr_state == READDATA) begin
            reg_X[cnt] <= X;
            reg_Y[cnt] <= Y;
        end
        

    end
    //busy_state: (0,0) -> (15,15)
    
    always @(posedge CLK or posedge RST) begin
        if(RST) begin
            tmp_x <= 4'b0;
            tmp_y <= 4'b0;
        end 
        else if(curr_state == BUSY) begin
            if((tmp_x == 4'd15) & (cnt == 6'd40)) begin
                tmp_x <= 4'd0;
                tmp_y <= tmp_y + 1'b1;
            end
            
            else if(cnt == 6'd40)
                tmp_x <= tmp_x + 1'b1;
            else begin
                tmp_x <= tmp_x;
                tmp_y <= tmp_y;
            end            
        end
        else begin
            tmp_x <= 4'b0;
            tmp_y <= 4'b0;
        end
    end

    // reg 做cur_circle 有問題

    reg cur_circle;

    reg [4:0] dist_x1, dist_x2, dist_y1, dist_y2;
    reg [4:0] tmp_max_x,tmp_max_y;
    reg [5:0] max_point, tmp_max;
    //reg []
    //assign cur_circle = 1'b1;

    always @(posedge CLK or posedge RST) begin
        if(RST) begin
            cur_circle <= 1'b1;
        end

        else if((curr_state == BUSY) & (cnt == 6'd40) & (tmp_y == 6'd15) & (tmp_x == 6'd15)) begin
            cur_circle <= !cur_circle;
        end

        else begin
            cur_circle <= cur_circle;
        end
    end
    always @(posedge CLK or posedge RST) begin
        if(RST) begin
            find_cnt <= 4'b0;
        end
        else if(find_cnt == 4'd3)
            find_cnt <= 4'b0 ;
        else if((curr_state == BUSY) & (cnt == 6'd40) & (tmp_y == 6'd15) & (tmp_x == 6'd15)) begin
            
            find_cnt <= find_cnt + 4'b1;
        end
        else begin
            find_cnt <= find_cnt ;
        end
    
    end




    always @(posedge CLK or posedge RST) begin
        if(RST)
            max_point <= 6'd0;
        else if(tmp_max > max_point)
            max_point <= tmp_max;
        else if(busy_done)
            max_point <= 6'd0;
        else
            max_point <= max_point;
    end

     

    always @(posedge CLK or posedge RST) begin
        if(RST) begin
            C1X <= 4'b0;
            C2X <= 4'b0;
            C1Y <= 4'b0;
            C2Y <= 4'b0;
        end
        else if(tmp_max >= max_point) begin
            if(cur_circle) begin
                C2X <= tmp_x;
                C2Y <= tmp_y;
            end
            else begin
                C1X <= tmp_x;
                C1Y <= tmp_y;
            end
        end
        else if(DONE )begin
            C1X <= 4'b0;
            C2X <= 4'b0;
            C1Y <= 4'b0;
            C2Y <= 4'b0;


        end


        else begin
            C1X <= C1X;
            C2X <= C2X;
            C1Y <= C1Y;
            C2Y <= C2Y;
        
        end



    end



    always @(posedge CLK or posedge RST) begin
        if(RST)
            tmp_max <= 6'b0;
        else if(cnt == 6'd40)
            tmp_max <= 6'b0;
        else if(curr_state == BUSY)
            tmp_max <= tmp_max + 
            ((dist_x1 + dist_y1 <= 6'd4) || (dist_x1 <= 3 & dist_y1 <= 2) || (dist_x1 <= 2 & dist_y1 <= 3)
            || (dist_x2 + dist_y2 <= 6'd4) || (dist_x2 <= 3 & dist_y2 <= 2) || (dist_x2 <= 2 & dist_y2 <= 3));
        else
            tmp_max <= 6'b0;

    end




    always @(*) begin
        if(cnt ==6'd40) begin
            dist_x1 = 5'd10;
            dist_y1 = 5'd10;
            dist_x2 = 5'd10;
            dist_y2 = 5'd10;
        end

        else if(!cur_circle) begin
            dist_x1 = (tmp_x > reg_X[cnt])? tmp_x - reg_X[cnt] : reg_X[cnt] - tmp_x;
            dist_y1 = (tmp_y > reg_Y[cnt])? tmp_y - reg_Y[cnt] : reg_Y[cnt] - tmp_y;
            dist_x2 = (C2X > reg_X[cnt])? C2X - reg_X[cnt] : reg_X[cnt] - C2X;
            dist_y2 = (C2Y > reg_Y[cnt])? C2Y - reg_Y[cnt] : reg_Y[cnt] - C2Y;
        end else begin
            dist_x1 = (tmp_x > reg_X[cnt])? tmp_x - reg_X[cnt] : reg_X[cnt] - tmp_x;
            dist_y1 = (tmp_y > reg_Y[cnt])? tmp_y - reg_Y[cnt] : reg_Y[cnt] - tmp_y;
            dist_x2 = (C1X > reg_X[cnt])? C1X - reg_X[cnt] : reg_X[cnt] - C1X;
            dist_y2 = (C1Y > reg_Y[cnt])? C1Y - reg_Y[cnt] : reg_Y[cnt] - C1Y;
        end
    end
    


endmodule


