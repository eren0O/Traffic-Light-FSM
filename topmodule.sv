//Hacettepe, ELE432, HW1, Eren O
//FSM STRUCTURE:
//1: typedef enum for states and S0...S3
//2: State register; to keep track of reset, else currentstate<=next state 
//3: next state logic with always_comb and "case(currentstate)"
//4: lastly assign the outputs

//RED, YELLOW, GREEN

module traffic(
input logic clk, rst, TAORB, //TAORB=1 means TRAFFIC AT A while no traffic at B.
output logic [5:0] led); 
//don't use output logic led[5:0] since it assigns it as an example: 
//led[0]=1'b1, meaning it is an array. We need [5:0] led, meaning bus.

logic [2:0] timer;  

typedef enum logic [1:0]{// use [1:0] since there are only 4 different states, 
//meaning it can be shown with 2^2, meaning 2 bits  
S0=2'b00,//A=GREEN, B=RED STATE
S1=2'b01,//A=YELLOW, B=RED STATE
S2=2'b10,//A=RED, B=GREEN STATE
S3=2'b11 //A=RED, B=YELLOW STATE,
         //and then a loopback to S0   
}state_t;
//now define state_t variables
state_t current_state, next_state;

//now define state registers, and timer for S1 and S3. sequential: memory
always_ff@(posedge clk, posedge rst) begin // flip flop loop that updates
//only on rising edge of clock, rst 
    if(rst) begin
        current_state <= S0; // if reset is true, set to default state
        timer<=0; end
    else begin
        current_state<=next_state; //update on clock cycle if reset!==1
        //using "<=" is very important, to not assign instantly and to prevent metastability
        if(current_state !=next_state)begin //this means we are currently switching states 
        timer <= 0;end//set timer to 0, so state=S1 or S3, starts counting from zero
        else if(current_state == S1 || current_state ==S3) begin//works for both s1 or s3
        timer <= timer+1; end//count only for yellow lights
        else begin
        timer <= 0;end//else is when S0 or S2 states.
    end              
end        

//now define the next state logic, combinational: no memory
always_comb begin //unlike always_ff, we use "=", outputs change as soon as inputs change
//always_comb updates on current_state, TAORB, even though we don't define its sensitivity list
//it is "smart enough" to understand what parameters does it depend on
next_state = current_state;
led = 6'b001_100;//Left part represesents Light A, Right part represents Light B
//100: RED, 010: YELLOW, 001: GREEN, define these to assign default state
case(current_state)
    S0: begin
        if(TAORB)begin//if no trafffic at A, needs to stay as it is
        next_state = S0; end
        else begin //code goes into this if traffic at B
        next_state = S1; end
    end    
    S1: begin //here it needs to count 5 seconds
    led = 6'b010_100; //A=Yellow, B=Red    
    if(timer >= 4) begin//check if count is 5
        next_state=S2; end//since timer is done, skip to next state
    else begin
        next_state=S1; end//stay at S1 until timer reaches to 5
    end
    S2: begin 
    led = 6'b100_001;//A=Red, B=Green
    if(TAORB) begin //if traffic at A;
    next_state = S3;end//leave this state and go to next state
    else begin //if no traffic at  A, stay in this state
    next_state = S2;end
    end
    S3: begin
    led = 6'b100_010;//A=Red, B=Yellow
    if(timer>=4) begin //same logic as S1 state
        next_state=S0;end
    else begin
    next_state = S3; end
    end
    default: next_state= S0;//set default state
endcase
end
endmodule
