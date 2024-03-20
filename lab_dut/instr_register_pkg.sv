
/***********************************************************************
 * A SystemVerilog RTL model of an instruction regisgter:
 * User-defined type definitions
 **********************************************************************/

 //declara package
package instr_register_pkg;
  timeunit 1ns/1ns;

  //defineste un tip de data de utilizator
  //tip de date de tip enumerare care poate sa tina variabile
  // tine enumerari 16 la numar
  typedef enum logic [3:0] {
    ZERO,
    PASSA,
    PASSB,
    ADD,
    SUB,
    MULT,
    DIV,
    MOD
  } opcode_t;


  //daca nu specificam ca este signed sau unsigned va fii unsigned by default
  typedef logic signed [31:0] operand_t;
  typedef logic signed [61:0] rezultat_t;

  typedef logic [4:0] address_t;
  
  typedef struct {
    opcode_t  opc;
    operand_t op_a;
    operand_t op_b;
    rezultat_t rezultat;
  } instruction_t;

endpackage: instr_register_pkg