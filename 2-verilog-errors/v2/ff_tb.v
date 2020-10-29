module ff_tb();
    logic clk;
    logic d;
    logic q;

    initial begin
        $dumpfile("ff_tb.vcd");
        $dumpvars(0, ff_tb);
        
        clk = 0;
        d = 1;
        #5;

        /* rising edge */
        clk = 1; //t = 5
        #1;
        assert(q == 1); //t =6
        #1;
        d=0;          /* Change the register input to 0.      t = 7*/
        #1;
        assert(q==1); /* Should still be 1 until rising edge. t = 8*/
        d=0;          /* Change the register input to 0.      t = 8*/
        #1;
        assert(q==1); /* Should still be 1 until rising edge.  t = 9*/

        /* falling edge */
        clk = 0;
        #5;
        assert(q == 1); /* Should still remember original value of 1 */

        /* rising edge */
        clk = 1;
        #2;
        assert(q==0);  /* Output has now changed to new input */


        $finish;
    end

    ff dut(
        clk,d,q
    );

endmodule