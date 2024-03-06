/***********************************************************************
 * A SystemVerilog testbench for an instruction register.
 * The course labs will convert this to an object-oriented testbench
 * with constrained random test generation, functional coverage, and
 * a scoreboard for self-verification.
 **********************************************************************/

module instr_register_test
  import instr_register_pkg::*;  // user-defined types are defined in instr_register_pkg.sv
  (input  logic          clk,
   output logic          load_en, 
   output logic          reset_n,
   output operand_t      operand_a,
   output operand_t      operand_b,
   output opcode_t       opcode,
   output address_t      write_pointer,
   output address_t      read_pointer,
   input  instruction_t  instruction_word
  );

  timeunit 1ns/1ns;
  parameter WRITE_NR = 20;
  parameter READ_NR = 20;
  int seed = 555;
  instruction_t  iw_reg_test[31:0] ;

  initial begin
    $display("\n\n***********************************************************");
    $display(    "***  THIS IS NOT A SELF-CHECKING TESTBENCH (YET).  YOU  ***");
    $display(    "***  NEED TO VISUALLY VERIFY THAT THE OUTPUT VALUES     ***");
    $display(    "***  MATCH THE INPUT VALUES FOR EACH REGISTER LOCATION  ***");
    $display(    "***********************************************************");

    $display("\nReseting the instruction register...");
    write_pointer  = 5'h00;         // initialize write pointer
    read_pointer   = 5'h1F;         // initialize read pointer
    load_en        = 1'b0;          // initialize load control line
    reset_n       <= 1'b0;          // assert reset_n (active low)
    repeat (2) @(posedge clk) ;     // hold in reset for 2 clock cycles
    reset_n        = 1'b1;          // deassert reset_n (active low)

    $display("\nWriting values to register stack...");
    @(posedge clk) load_en = 1'b1;  // enable writing to register
    repeat (WRITE_NR) begin
      @(posedge clk) randomize_transaction; // ce facem este ca 
      @(negedge clk) print_transaction; //
    end
    @(posedge clk) load_en = 1'b0;  // turn-off writing to register

    // read back and display same three register locations
    $display("\nReading back the same register locations written...");
    for (int i=0; i<=READ_NR; i++) begin
      // later labs will replace this loop with iterating through a
      // scoreboard to determine which addresses were written and
      // the expected values to be read back
      @(posedge clk) read_pointer = i;
      @(negedge clk) print_results;
    end

    @(posedge clk) ;
    $display("\n***********************************************************");
    $display(  "***  THIS IS NOT A SELF-CHECKING TESTBENCH (YET).  YOU  ***");
    $display(  "***  NEED TO VISUALLY VERIFY THAT THE OUTPUT VALUES     ***");
    $display(  "***  MATCH THE INPUT VALUES FOR EACH REGISTER LOCATION  ***");
    $display(  "***********************************************************\n");
    $finish;
  end

  function void randomize_transaction;
    // A later lab will replace this function with SystemVerilog
    // constrained random values
    // asigneaza valori lui a si b si ne da si un write pointer
    // The stactic temp variable is required in order to write to fixed
    // addresses of 0, 1 and 2.  This will be replaceed with randomizeed
    // write_pointer values in a later lab
    //

    // este o variabila ce este impartita intre instante functia randomize returneaza o valoare random pe 32 de biti signed si daca avem un numar intre -2.. si +2 facem %16 si ne da intre -15 si 15
    
    static int temp = 0;
    operand_a     <= $random(seed)%16;                 // between -15 and 15
    operand_b     <= $unsigned($random)%16;            // between 0 and 15 si ce face unsigned este ca converteste numarul din numar negativ in numar pozitiv si rezultatul va fii intre 0 si 15
    opcode        <= opcode_t'($unsigned($random)%8);  // between 0 and 7, cast to opcode_t type facem cast ca prima data facem random
    iw_reg_test[write_pointer] <= '{opcode,operand_a,operand_b, 4'b0};
    write_pointer <= temp++; // se incremeneteaza write pointer si write_pointe
  endfunction: randomize_transaction

  function void print_transaction;
    $display("Writing to register location %0d: ", write_pointer);
    $display("  opcode = %0d (%s)", opcode, opcode.name);
    $display("  operand_a = %0d",   operand_a);
    $display("  operand_b = %0d\n", operand_b);
  endfunction: print_transaction

  function void print_results;
    $display("Read from register location %0d: ", read_pointer);
    $display("  opcode = %0d (%s)", instruction_word.opc, instruction_word.opc.name); /// opcode.name ne zice denumirea 
    $display("  operand_a = %0d",   instruction_word.op_a);
    $display("  operand_b = %0d\n", instruction_word.op_b);
    $display("  result = %0d\n", instruction_word.rezultat);
  endfunction: print_results

  function void check_result;

    
    for (int i=0; i<=READ_NR; i++) begin
      rezultat_t local_result [31:0];
      if (instruction_word.op_a !== operand_a ) begin
         $display("Operand_a este diferit de ce am generat!");
      end

      if (instruction_word.op_b !== operand_b ) begin
         $display("Operand_b este diferit de ce am generat!");
      end

      case(instr_register_test.opc) 
          ZERO: local_result = 32'sd0;
          PASSA: local_result = instr_register_test.op_a;
          PASSB: local_result = instr_register_test.op_b;
          ADD: local_result = instr_register_test.op_a + instr_register_test.op_b;
          SUB: local_result = instr_register_test.op_a - instr_register_test.op_b;
          MULT: local_result = instr_register_test.op_a * instr_register_test.op_b;
          DIV: local_result = instr_register_test.op_a / instr_register_test.op_b;
          MOD: local_result = instr_register_test.op_a % instr_register_test.op_b;
          default: local_result = 'bx;
      endcase

        if (  local_result === instr_register_test.rezultat) begin
          $display("Rezultatele sunt asemanatoare");
        end else begin
          $display("We have a problem!");
        end
      
    
    end
  
  endfunction;

endmodule: instr_register_test
