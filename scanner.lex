%{

#include "tokens.hpp"
#include "output.hpp"

%}

%option yylineno
%option noyywrap
digit       ([0-9])
wzdigit     ([1-9])
letter      ([a-zA-Z])
alnum       ([a-zA-Z0-9])
whitespace  ([ \t\r\n])

/* excluding " and \ including \t */
printable   ([\x20-\x21\x23-\x5B\x5D-\x7E\t]) 
escaped     (\\[\\"nrt0]|\\x(2[0-9a-fA-F]|[3-6][0-9a-fA-F]|7[0-9a-eA-E]|09|0A|0a|0D|0d))

%x          STR

%%

"void"      { return VOID; }
"int"       { return INT; }
"byte"      { return BYTE; }
"bool"      { return BOOL; }
"and"       { return AND; }
"or"        { return OR; }
"not"       { return NOT; }
"true"      { return TRUE; }
"false"     { return FALSE; }
"return"    { return RETURN; }
"if"        { return IF; }
"else"      { return ELSE; }
"while"     { return WHILE; }
"break"     { return BREAK; }
"continue"  { return CONTINUE; }
";"         { return SC; }
","         { return COMMA; }
"("         { return LPAREN; }
")"         { return RPAREN; }
"{"         { return LBRACE; }
"}"         { return RBRACE; }
"="         { return ASSIGN; }
"=="|"!="|"<"|">"|"<="|">=" { return RELOP; }
"+"|"-"|"*"|"/"             { return BINOP; }
"//"[^\r\n]*                { return COMMENT; }
{letter}{alnum}*            { return ID; }
0|{wzdigit}{digit}*         { return NUM; }
(0|{wzdigit}{digit}*)b      { return NUM_B; }

\"                                  { BEGIN(STR); }
<STR>(({printable}|{escaped})*\")   { BEGIN(INITIAL); return STRING;  }
<STR>\n                             { output::errorUnclosedString(); }

<STR>\\\"                           { output::errorUnclosedString(); /* won't be checked */ }

<STR>\\(.)                          { output::errorUndefinedEscape(yytext + 1); }
<STR>\\x(.)\"                       { 
                                        char temp[3];
                                        strncpy(temp, yytext + 1, 2); // Copy the two characters after \x
                                        temp[2] = '\0'; // Null-terminate the string
                                        output::errorUndefinedEscape(temp); 
                                    }
<STR>\\x(.)(.)                      { output::errorUndefinedEscape(yytext + 1); }   
<STR><<EOF>>                        { output::errorUnclosedString(); }
<STR>.                              { /* Ignore other characters in string mode */ }

({whitespace})+     { /* Ignore whitespace */ }
.                   { output::errorUnknownChar(yytext[0]); }

%%
