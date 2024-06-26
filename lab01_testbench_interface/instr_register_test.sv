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
  int file_descriptor;
  parameter WRITE_NR = 20;
  parameter READ_NR = 20;
  instruction_t  iw_reg_test[31:0] ;
  instruction_t  instruction_word_instance;
  rezultat_t res = 0;
  parameter  WRITE_ORDER = 0; 
  parameter  READ_ORDER = 0 ;
  parameter TEST_NAME = "";
  parameter SEED_VALUE = 0;
  static int temp = 0;
  int failed_tests = 0;
  int seed = SEED_VALUE;
 // write order - 1 decremental 
 // write order - 0 incremental 
 // write order - 2 este random
  initial begin
    // $display("\n\n***********************************************************");
    // $display(    "***  THIS IS  A SELF-CHECKING TESTBENCH .  YOU  ***");
    // $display(    "***  NEED TO VISUALLY VERIFY THAT THE OUTPUT VALUES     ***");
    // $display(    "***  MATCH THE INPUT VALUES FOR EACH REGISTER LOCATION  ***");
    // $display(    "***********************************************************");

    // $display("\nReseting the instruction register...");
    write_pointer  = 5'h00;         // initialize write pointer
    read_pointer   = 5'h1F;         // initialize read pointer
    load_en        = 1'b0;          // initialize load control line
    reset_n       <= 1'b0;          // assert reset_n (active low)
    repeat (2) @(posedge clk) ;     // hold in reset for 2 clock cycles
    reset_n        = 1'b1;          // deassert reset_n (active low)

    for (int i = 0; i < 32; i++) begin
        
        iw_reg_test[i].opc      = ZERO;
        iw_reg_test[i].op_a     = 32'b0;
        iw_reg_test[i].op_b     = 32'b0;
        iw_reg_test[i].rezultat = 62'b0;
    end

     if (WRITE_ORDER == 0) begin
          temp = 0 ;
      end else if (WRITE_ORDER == 1) begin
        temp = 31;
      end 

     $display("\nWriting values to register stack...");
   
    
      // enable writing to register
    repeat (WRITE_NR) begin
      @(posedge clk) randomize_transaction; // ce facem este ca 
      load_en = 1'b1;
      @(negedge clk) print_transaction; //
    end
    @(posedge clk) load_en = 1'b0;  // turn-off writing to register

    $display("\nReading back the same register locations written...");
    for (int i=1; i<=READ_NR; i++) begin
      // later labs will replace this loop with iterating through a
      // scoreboard to determine which addresses were written and
      // the expected values to be read back
      if (READ_ORDER == 0) begin
        read_pointer = i;
      end else if (read_pointer == 1) begin
        read_pointer = READ_NR - i;
      end else begin
        read_pointer = $unsigned($random)%32;
      end
      $display("READ_POINTER = %0d", read_pointer);
      $display("op_a = %0d", instruction_word.op_a);
      $display("op_b = %0d", instruction_word.op_b);
      $display("opc = %0d", instruction_word.opc);
      $display("  Time: %t", $time);
      @(negedge clk) print_results;
      @(posedge clk) check_result;
    end


    $display("\nReading back the same register locations written...");
    for (int i=1; i<=READ_NR; i++) begin
      // later labs will replace this loop with iterating through a
      // scoreboard to determine which addresses were written and
      // the expected values to be read back
      if (READ_ORDER == 0) begin
        read_pointer = i;
      end else if (read_pointer == 1) begin
        read_pointer = READ_NR - i;
      end else begin
        read_pointer = $unsigned($random)%32;
      end

       $display("\n \n \n &&&&&&&&&&&&&&&&& \n \n \n");
       $display(" READ_POINTER = %0d", read_pointer);
       $display(" op_a = %0d", instruction_word.op_a);
       $display(" op_b = %0d", instruction_word.op_b);
       $display(" op_b = %0d", instruction_word.opc);
       $display(" result = %0d", instruction_word.rezultat);
       $display("\n \n \n &&&&&&&&&&&&&&&&& \n \n \n");
    end

 
    final_report;
     
    $display("\n***********************************************************");
    $display(  "***                       STATISTISCS                  ***");
    $display(  "***           READ_ORDER = %0d ,  WRITE_ORDER = %0d     ***",READ_ORDER, WRITE_ORDER);
    $display(  "***           TESTS FAILED = %0d  TOTAL_TESTS =  %0d    ***", failed_tests, (READ_NR));
    $display(  "***********************************************************\n");
    failed_tests = 0;


    // read back and display same three register locations
    @(posedge clk) ;
    $finish;

    end

  

  function void final_report;

  file_descriptor = $fopen("../reports/regression_transcript/regression_status.txt", "a");
     if (file_descriptor != 0) begin
      
       if (failed_tests != 0) begin
        $fwrite(file_descriptor, "\n***********************************************************\n");
        $fwrite(file_descriptor, "***                       STATISTICS                      ***\n");
        $fwrite(file_descriptor, "***                     TEST NAME: %s                     ***\n", TEST_NAME);
        $fwrite(file_descriptor, "***               READ_ORDER = %0d ,  WRITE_ORDER = %0d    ***\n",READ_ORDER, WRITE_ORDER);
        $fwrite(file_descriptor, "***               TESTS FAILED = %0d  TOTAL_TESTS =  %0d   ***\n",failed_tests, (READ_NR));
        $fwrite(file_descriptor, "*                 STATUS: FAILED                            *\n\n");
        $fwrite(file_descriptor, "*************************************************************\n\n");

       end else begin
        $fwrite(file_descriptor, "\n***********************************************************\n");
        $fwrite(file_descriptor, "***                       STATISTICS                       ***\n");
        $fwrite(file_descriptor, "***                     TEST NAME: %s                      ***\n", TEST_NAME);
        $fwrite(file_descriptor, "***               READ_ORDER = %0d ,  WRITE_ORDER = %0d    ***\n",READ_ORDER, WRITE_ORDER);
        $fwrite(file_descriptor, "***               TESTS FAILED = %0d  TOTAL_TESTS =  %0d   ***\n",failed_tests, (READ_NR));
        $fwrite(file_descriptor, "**                  STATUS :  PASSED                       *\n\n");
        $fwrite(file_descriptor, "*************************************************************\n\n");

       end
        $fclose(file_descriptor);
      end
  endfunction: final_report 

  
  function void randomize_transaction;
    // A later lab will replace this function with SystemVerilog
    // constrained random values
    // asigneaza valori lui a si b si ne da si un write pointer
    // The stactic temp variable is required in order to write to fixed
    // addresses of 0, 1 and 2.  This will be replaceed with randomizeed
    // write_pointer values in a later lab
    //

    // este o variabila ce este impartita intre instante functia randomize returneaza o valoare random pe 32 de biti signed si daca avem un numar intre -2.. si +2 facem %16 si ne da intre -15 si 15
  

    operand_a     = $random(seed)%16;                 // between -15 and 15
    operand_b     = $unsigned($random(seed))%16;            // between 0 and 15 si ce face unsigned este ca converteste numarul din numar negativ in numar pozitiv si rezultatul va fii intre 0 si 15
    opcode        = opcode_t'($unsigned($random(seed))%9);  // between 0 and 7, cast to opcode_t type facem cast ca prima data facem random
    

    if (WRITE_ORDER == 0) begin
          write_pointer = temp;
          temp = temp+1;
      end else if (WRITE_ORDER == 1) begin
        write_pointer = temp;
        temp = temp-1;
      end else begin
        write_pointer = $unsigned($random(seed))%32;
      end

  
    iw_reg_test[write_pointer] = '{opcode,operand_a,operand_b, 4'b0};
    
    
    
  endfunction: randomize_transaction

  function void print_transaction;
    $display("Writing to register location %0d: ", write_pointer);
    $display("  opcode = %0d (%s)", opcode, opcode.name);
    $display("  operand_a = %0d",   operand_a);
    $display("  operand_b = %0d\n", operand_b);
    $display("  Time: %t",$time);
  endfunction: print_transaction

  function void print_results;
    $display("Read from register location %0d: ", read_pointer);
    $display("  opcode = %0d (%s)", instruction_word.opc, instruction_word.opc.name); /// opcode.name ne zice denumirea 
    $display("  operand_a = %0d",   instruction_word.op_a);
    $display("  operand_b = %0d\n", instruction_word.op_b);
    $display("  result = %0d\n", instruction_word.rezultat);
    $display("  DIN DUT : opa = %0d , opb = %0d , opc = %0d (%s) \n", instruction_word.op_a, instruction_word.op_b, instruction_word.opc, instruction_word.opc.name);
    $display("  Time: %t", $time);
  endfunction: print_results

 function void check_result;

     $display("FROM CHECK_RESULT: read_pointer = %0d ", read_pointer);
    
      instruction_word_instance = iw_reg_test[read_pointer];


      if(instruction_word_instance.op_a === 'hxx || instruction_word_instance.op_a === 'hxx || instruction_word_instance.opc === 'hxx ) begin
       
          return;
      end 
      
      if (instruction_word_instance.op_a !== instruction_word.op_a ) begin
         $display("Operand_a este diferit de ce am generat!");
         $display("iwts operand_a = %0d , operand_a = %0d",instruction_word_instance.op_a , instruction_word.op_a );
         $display("Time: %t", $time);
         $display("Read pointer: %0d", read_pointer);
      end

      if (instruction_word_instance.op_b !== instruction_word.op_b ) begin
         $display("Operand_b este diferit de ce am generat!");
         $display("iwts operand_b = %0d , operand_b = %0d",instruction_word_instance.op_b , instruction_word.op_b );
         $display("Time: %t", $time);
         $display("Read pointer: %0d", read_pointer);
      end

      

      case(instruction_word_instance.opc)
        ZERO: res = 0;
        PASSA: res = instruction_word_instance.op_a;
        PASSB: res = instruction_word_instance.op_b;
        ADD: res = instruction_word_instance.op_a + instruction_word_instance.op_b;
        SUB: res = instruction_word_instance.op_a - instruction_word_instance.op_b;
        MULT: res = instruction_word_instance.op_a * instruction_word_instance.op_b;
        DIV: if(instruction_word_instance.op_b === 0) res = 0; else res = instruction_word_instance.op_a / instruction_word_instance.op_b;
        MOD:  if(instruction_word_instance.op_b === 0) res = 0; else res = instruction_word_instance.op_a % instruction_word_instance.op_b;
        POW: if(instruction_word_instance.op_b === 0) res = 1; else res = instruction_word_instance.op_a ** instruction_word_instance.op_b;
        default: res = 'bx;
      endcase
      
        if ( res !== instruction_word.rezultat) begin

          failed_tests = failed_tests + 1;
          $display("\n \n \n");
          $display("**********************");
          $display("read_ppointer = %0d ", read_pointer);
          $display("Rezultatele nu se aseamana");
          $display("rezultatul calculat de dut: %0d", instruction_word.rezultat);
          $display("rezultatul stocat de noi : %0d ", res);
          $display("opcode = %0d (%s)", instruction_word_instance.opc, instruction_word_instance.opc.name);
          $display("operand_a = %0d ,  operand_b = %0d ", instruction_word_instance.op_a, instruction_word_instance.op_b);
          $display(" DIN DUT operand_a : (%0d) , operand_b : (%0d) , opcode: (%0d)", instruction_word.op_a, instruction_word.op_b , instruction_word.opc);
          $display("Time: %t", $time);
          $display("**********************");
          $display("\n \n \n");
        end
    
  endfunction;

endmodule: instr_register_test
