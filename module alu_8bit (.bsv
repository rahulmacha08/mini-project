module alu_8bit (
    // Data and control inputs
    input  logic [7:0] A,
    input  logic [7:0] B,
    input  logic [2:0] Opcode,
    
    // Outputs
    output logic [7:0] Result,
    output logic       Zero,
    output logic       CarryOut,
    output logic       Overflow
);

    // Use local parameters for readable and maintainable opcode definitions
    localparam ADD = 3'b000;
    localparam SUB = 3'b001;
    localparam AND = 3'b010;
    localparam OR  = 3'b011;
    localparam XOR = 3'b100;
    localparam NOT = 3'b101;
    localparam SLL = 3'b110;
    localparam SRL = 3'b111;

    // An internal 9-bit register is used to easily capture the carry-out bit
    // from 8-bit arithmetic operations.
    logic [8:0] temp_result;

    // This combinational block describes the ALU's behavior.
    // 'always_comb' ensures it re-evaluates whenever an input changes.
    always_comb begin
        // Initialize outputs to default values to prevent inferred latches
        temp_result = 9'b0;
        CarryOut    = 1'b0;
        Overflow    = 1'b0;

        // A case statement selects the operation based on the Opcode
        case (Opcode)
            ADD: begin
                // Perform addition by extending operands to 9 bits
                temp_result = {1'b0, A} + {1'b0, B};
                // Overflow for addition occurs if the sign of both inputs is the
                // same, but the sign of the result is different.
                Overflow = (A[7] == B[7]) && (temp_result[7] != A[7]);
            end

            SUB: begin
                // Perform subtraction
                temp_result = {1'b0, A} - {1'b0, B};
                // Overflow for subtraction occurs if the inputs have different signs,
                // and the result's sign is different from the first operand's sign.
                Overflow = (A[7] != B[7]) && (temp_result[7] != A[7]);
            end

            // Logical operations
            AND: temp_result = A & B;
            OR:  temp_result = A | B;
            XOR: temp_result = A ^ B;
            NOT: temp_result = ~A;
            
            // Shift operations
            SLL: begin // Shift Left Logical
                temp_result = A << 1;
                // The bit shifted out of the MSB becomes the carry
                CarryOut = A[7]; 
            end

            SRL: begin // Shift Right Logical
                temp_result = A >> 1;
                // The bit shifted out of the LSB becomes the carry
                CarryOut = A[0]; 
            end

            // If the opcode is not recognized, propagate 'X' (unknown)
            default: temp_result = 9'bxxxxxxxx;
        endcase

        // Assign the final 8-bit result
        Result = temp_result[7:0];
        
        // The CarryOut for ADD/SUB is the 9th bit of the temporary result.
        // For shifts, it's already assigned within the case statement.
        if (Opcode == ADD || Opcode == SUB) begin
            CarryOut = temp_result[8];
        end

        // The Zero flag is asserted if the final 8-bit result is all zeros.
        // This is a universal flag for all operations.
        Zero = (Result == 8'h00);
    end

endmodule
