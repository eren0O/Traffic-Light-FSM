//Hacettepe, ELE432, HW1, Eren O
`timescale 1ns/1ps

module traffic_tb();
    logic clk;
    logic rst;
    logic TAORB;
    logic [5:0] led;
    //unit under test, connect variables from traffic to traffic_tb
    traffic uut (
        .clk(clk),
        .rst(rst),
        .TAORB(TAORB),
        .led(led)
    );

    //set clock
    always #5 clk = ~clk;

    //didn't use testvectors, but this method works well too
    initial begin
        clk = 0;
        rst = 1;
        TAORB = 1; //traffic at A first
        
        #20 rst = 0;
        
        // test1: test to stay in S0
        //when taorb is 1, light should stay as 001_100 (green for A)
        #50;//currently at 70ns
        
        //test2: S0 to S1 to S2
        //so set traffic at B
        TAORB = 0; //set TAORB=0 at 70ns, so next clock posedge 
        //catches the change at 70ns+5ns
        
        //wait S1 (basically yellow for A)
        wait(led == 6'b010_100);//we can see that the code counts from 75ns to 125ns
        //meaning that 50ns, and since clock period is 10ns; 50/10 is 5 time units. Timer works
        //wait for S2 (Red for A, should take 5 time units)
        wait(led == 6'b100_001);

        //should stay in S2 as long as TAORB isn't 1
        #100;//should leave state S2 at 225 ns
    
        //Traffic at A, TAORB=1
        TAORB = 1;
        
        wait(led == 6'b100_010); //state S3, red=A, yellow=B

        wait(led == 6'b001_100);//should get to state S0
    end
endmodule