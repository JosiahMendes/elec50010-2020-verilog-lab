module CPU_MU0_delay0(
    input logic clk,
    input logic rst,
    output logic running,
    output logic[11:0] address,
    output logic write,
    output logic read,
    output logic[15:0] writedata,
    input logic[15:0] readdata
    );
    timeunit 1ns / 10ps;
    /* Using an enum to define constants */
    typedef enum logic[3:0] {
        OPCODE_LDA = 4'd0,
        OPCODE_STO = 4'd1,
        OPCODE_ADD = 4'd2,
        OPCODE_SUB = 4'd3,
        OPCODE_JMP = 4'd4,
        OPCODE_JGE = 4'd5,
        OPCODE_JNE = 4'd6,
        OPCODE_STP = 4'd7,
        OPCODE_OUT = 4'd8
    } opcode_t;

    /* Another enum to define CPU states. */
    typedef enum logic[1:0] {
        FETCH_INSTR = 2'b00,
        EXEC_INSTR = 2'b01,
        HALTED = 2'b10
    } state_t;

    logic[2:0] state;
    logic[11:0] pc;

    logic[15:0] instr;
    opcode_t instr_opcode;
    logic[11:0] instr_constant;
    assign instr_opcode = instr[15:12];
    assign instr_constant = instr[11:0];

    logic validRead;
    assign address = (state==FETCH_INSTR) ? pc : instr_constant;
    assign validRead = (state==EXEC_INSTR) ? 1 : 0;  // Only perform stuff in exec
    assign read = (state==FETCH_INSTR) ? 1 : (instr_opcode==OPCODE_LDA || instr_opcode==OPCODE_ADD  || instr_opcode==OPCODE_SUB );
    assign write = (state==EXEC_INSTR & instr_opcode==OPCODE_STO) ? 1 : 0; 

    CPU_MU0_core core(.clk(clk), .rst(rst), .instr(instr), .readdata(readdata), .validRead(validRead), .pc(pc), .writedata(writedata), .running(running));

    initial begin
        state = HALTED;
    end

    always @(posedge clk) begin
        if (rst) begin
            $display("CPU : INFO  : Resetting.");
            state <= FETCH_INSTR;
        end
        else if (state==FETCH_INSTR) begin
            $display("CPU : INFO  : Fetching, address=%h.", address);
            instr <= readdata;
            state <= EXEC_INSTR;
        end
        else if (state==EXEC_INSTR) begin
            $display("CPU : INFO  : Executing, address=%h.", address);
            state <= (instr_opcode==OPCODE_STP) ? HALTED : FETCH_INSTR;
        end
        else if (state==HALTED) begin
            // do nothing
        end
        else begin
            $display("CPU : ERROR : Processor in unexpected state %b", state);
            $finish;
        end
    end
endmodule