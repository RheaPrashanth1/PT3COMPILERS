%{
%}

%skeleton "lalr1.cc"
%require "3.0.4"
%defines
%define api.token.constructor
%define api.value.type variant
%define parse.error verbose
%locations


%code requires
{
        /* you may need these header files 
         * add more header file if you need more
         */
#include <list>
#include <string>
#include <functional>
using namespace std;
        /* define the sturctures using as types for non-terminals */
        struct dec_struct {
                string code;
                list<string> ids;

        };


         struct var_struct {
                string code;
                list<string> ids;

        };      /* end the structures for non-terminal types */
}


%code
{
#include "parser.tab.hh"

        /* you may need these header files 
         * add more header file if you need more
         */
#include <sstream>
#include <map>
#include <regex>
#include <set>
yy::parser::symbol_type yylex();

        /* define your symbol table, global variables,
         * list of keywords or any function you may need here */

        /* end of your code */
}
%token END 0 "end of file";

        /* specify tokens, type of non-terminals and terminals here */
%token FUNCTION IDENTIFIERS NUMBERS BEGINPARAMS ENDPARAMS BEGINLOCALS ENDLOCALS BEGINBODY ENDBODY INTEGER ARRAY OF IF THEN ENDIF ELSE WHILE DO BEGINLOOP ENDLOOP CONTINUE READ WRITE TRUE FALSE RETURN SEMICOLON COLON COMMA LPAREN RPAREN LSQUARE RSQUARE
%right ASSIGN
%left OR
%left AND
%right NOT
%left LT LTE GT GTE NEQ EQ
%left ADD SUB
%left MULT DIV MOD
%right UMINUS
%left LSQUARE RSQUARE
%left LPAREN RPAREN
%type <string> IDENTIFIERS
%type <int> NUMBERS
%type<string>Statement ElseStatement  Program Function  StatementL
        /* end of token specifications */
%type <dec_struct> Id DeclarationL Declaration
%type <var_struct>RelExp Comp RelAndExp BoolExp Term ExpressionL Var V Expression MultExp


%%

%start prog_start;

        /* define your grammars here use the same grammars
         * you used in Phase 2 and modify their actions to generate codes
         * assume that your grammars start with prog_start
         */

prog_start: Program { cout << $1 << endl;}
           ;

Program:  %empty {$$ = "";}
         | Function Program {$$ = $1 + "\n" + $2;}
          ;

Function: FUNCTION IDENTIFIERS SEMICOLON BEGINPARAMS DeclarationL ENDPARAMS BEGINLOCALS DeclarationL ENDLOCALS BEGINBODY StatementL ENDBODY
                {
                        $$ = "func " + $2 + "\n";
                        $$ += $5.code;
                        int i = 0;
                        for(list<string>::iterator it = $5.ids.begin(); it!= $5.ids.end(); it++)
                        {
                          $$ += *it + ", $" + to_string(i) + "\n";
                        i++;
                        }
                        $$ += $8.code;
                        $$ += $11;
                        $$ += "endfunc";
                }
                ;
DeclarationL:   %empty {$$.code = ""; $$.ids = list<string>();}
                | Declaration SEMICOLON DeclarationL
                {
                        $$.code = $1.code + $3.code;
                        $$.ids = $1.ids;
                        for(list<string>::iterator it = $3.ids.begin(); it!= $3.ids.end(); it++)
                        {
                            $$.ids.push_back(*it);

                        }
                }   
                
;




Declaration: Id COLON INTEGER 
                {
                  $$.code = $1.code;
                  $$.ids = $1.ids;
                } 
             | Id COLON ARRAY LSQUARE NUMBERS RSQUARE OF INTEGER
                {
                   $$.code =  $1.code;
                   $$.ids = $1.ids;
                }
              
;

Id:             IDENTIFIERS
                {
                 $$.code = ". " + $1 + "\n";
                 $$.ids.push_back($1);
                }
                 | IDENTIFIERS COMMA Id {
                 $$.code = ". " + $1 + "\n";
                 $$.ids.push_back($1);
                  for(list<string>::iterator it = $3.ids.begin(); it!= $3.ids.end(); it++)
                        {
                            $$.ids.push_back(*it);

                        }
                }
                ;
StatementL:     %empty
                {$$ = " ";}
                 ;


Var:           IDENTIFIERS
               {
                $$.code = ". " + $1 + "\n";
                $$.ids.push_back($1);
                }        
               | IDENTIFIERS LSQUARE Expression RSQUARE
               {
                $$.code = ". " + $1 + "\n" + $3.code;
                $$.ids.push_back($1);

                }
               ;

V:            Var
              {
                $$.code = $1.code;
              }      
              | Var COMMA V
              {
                $$.code = $1.code + $3.code;
                }
              ;

Expression:      MultExp
                {$$.code = $1.code;}
                | Expression ADD MultExp
                 {$$.code = $1.code + $3.code; }
                | Expression SUB MultExp
                 {$$.code = $1.code + $3.code;}
                ;
MultExp :       Term
                {$$.code = $1.code;}
                | MultExp MOD Term
                 {$$.code = $1.code + $3.code;}
                | MultExp DIV Term
                  {$$.code = $1.code + $3.code;}
                | MultExp MULT Term
                  {$$.code = $1.code + $3.code;}
                ;

Term:            Var
                {$$.code = $1.code}
                 | SUB Var
                 {$$.code = $2.code}
                 | NUMBERS
                 {}
                 | SUB NUMBERS
                 {}
                 | LPAREN Expression RPAREN
                 {$$.code = $2.code;}
                 | SUB LPAREN Expression RPAREN
                 {$$.code = $3.code;}
                 | IDENTIFIERS LPAREN ExpressionL RPAREN
                 {$$.ids.push_back($1.code);


                }
                 ;
ExpressionL:    Expression
                {$$.code = $1.code;}
                |
                Expression COMMA ExpressionL    
                {$$.code = $1.code + $3.code;}


BoolExp:        RelAndExp
                {$$.code = $1.code;}
                | BoolExp OR RelAndExp
                {$$.code = $1.code + $3.code;}
                ;

RelAndExp:        RelExp
                {$$.code = $1.code;}
                | RelAndExp AND RelExp
                {$$.code = $1.code + $3.code;}
                ;

RelExp:         Expression Comp Expression
                {$$.code = $1.code + $3.code;}  
                | NOT Expression Comp Expression
                {$$.code = $2.code + $3.code;}  
                |TRUE
                {}
                |NOT TRUE
                {}
                |FALSE
                {}      
                |NOT FALSE
                {}
                 | LPAREN BoolExp RPAREN
                {$$.code = $2.code;}
                | NOT LPAREN BoolExp RPAREN
                {$$.code = $3.code;}
                ;

Comp:           EQ
                {}              
                |NEQ
                {}      
                |LT
                {}
                |GT
                {}
                |LTE
                {}
                |GTE
                {}
                ;
ElseStatement:   %empty
                {$$.code = "";}
                | ELSE StatementL
                 {$$.code = $2.code;}
 
               ;

Statement:       Var ASSIGN Expression
                {$$.code = $1.code + $3.code;}
                |IF BoolExp THEN StatementL ElseStatement ENDIF
                {$$.code = $2.code + $4.code + $5.code;}
                | WHILE BoolExp BEGINLOOP StatementL ENDLOOP
                {$$.code = $2.code + $4.code;}
                |DO BEGINLOOP StatementL ENDLOOP WHILE BoolExp
                {$$.code = $3.code + $6.code;}
                |READ V
                {$$.code = $2.code;}
                |WRITE V
                {$$.code = $2.code;}
                |CONTINUE
                {}
                |RETURN
                {}
                ;
%%

int main(int argc, char *argv[])
{
        yy::parser p;
        return p.parse();
}

void yy::parser::error(const yy::location& l, const std::string& m)
{
        std::cerr << l << ": " << m << std::endl;
}
