/*
STP 0111 stop
JNE S 0110 if ACC ≠ 0, PC := S
JGE S 0101 if ACC > 0, PC := S
JMP S 0100 PC := S
SUB S 0011 ACC := ACC – mem[S]
ADD S 0010 ACC := ACC + mem[S]
STO S 0001 mem[S] := ACC
LDA S 0000 ACC := mem[S]
OUT S 1000 print(Acc)
*/

module CPU_MU0_core(
    input wire clk,
    input wire rst,
    input logic[15:0] instr,
    input logic[15:0] readdata,
    input logic validRead,
    output logic running,
    output logic[11:0] pc, 
    output wire[15:0] writedata
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

    logic[15:0] acc;

    // This is used in many places, as most instructions go forwards by one step.
    // Defining it once makes it more likely the synthesis tool will only create
    // one concrete instance.
    wire[11:0] pc_increment;
    assign pc_increment = pc+1;

    opcode_t instr_opcode;
    logic[11:0] instr_constant;

    // Break-down the instruction into fields
    // these are just wires for our convenience
    assign instr_opcode = instr[15:12];
    assign instr_constant = instr[11:0];

    assign writedata = acc;

    initial begin
        running = 0;
    end

    always @(posedge clk) begin
        if (rst) begin
            $display("CPU : INFO  : Shared Resetting.");
            pc<= 0;
            acc <= 0;
            running <=1;
        end else if (running & validRead) begin
            $display("CPU : INFO  : Shared Executing opcode=%h, acc=%h, imm=%h, readdata=%x", instr_opcode, acc, instr_constant, readdata);
            case(instr_opcode)
                OPCODE_LDA: begin
                    acc <= readdata;
                    pc <= pc_increment;
                end
                OPCODE_STO: begin
                    pc <= pc_increment;
                end
                OPCODE_ADD: begin
                    acc <= acc + readdata;
                    pc <= pc_increment;
                end
                OPCODE_SUB: begin
                    acc <= acc - readdata;
                    pc <= pc_increment;
                end
                OPCODE_JMP: begin
                    pc <= instr_constant;
                end
                OPCODE_JGE: begin
                    if (acc[15] == 0) begin
                        pc <= instr_constant;
                    end
                    else begin
                        pc <= pc_increment;
                    end
                end
                OPCODE_JNE: begin
                    if (acc != 0) begin
                        pc <= instr_constant;
                    end
                    else begin
                        pc <= pc_increment;
                    end
                end
                OPCODE_OUT: begin
                    $display("CPU : OUT   : %d", $signed(acc));
                    pc <= pc_increment;
                end
                OPCODE_STP: begin
                    // Stop the simulation
                    $display("CPU : INFO  : Stopped.");
                    running <= 0;
                end
            endcase
        end
    end
endmodule