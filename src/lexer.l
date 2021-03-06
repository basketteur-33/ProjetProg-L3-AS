/**
 * \file lexer.l
 * \brief Fichier contenant les regles constituant l'analyseur lexical du projet.
 * \author LABBE Emeric <br>
 * LAHAYE Valentin <br>
 * PARPAITE Thibault <br>
 * SARRABAYROUSE Alexis
 * \date 26 Fevrier 2016
 */

%{
#ifndef UT_LEXER
#include <string.h>
#include <parser.h>
#else
#include <tokens.h>
#endif
%}

%option nounput noinput

LABELSET ([[:alnum:]'._])

%x STRING
%x IMPORT

%%

<IMPORT>\.                      { return '.'; }
<IMPORT>[^.][^/]*[/]([^/]+[/])* {
                                  #ifndef UT_LEXER
                                      yylval.s = strdup(yytext);
                                  #endif
                                  return DIRECTORY;
                                }
<IMPORT>[^./][^/]*-[>]          {
                                  BEGIN INITIAL;
                                  yyless(yyleng - 2);
                                  #ifndef UT_LEXER
                                      yylval.s = strdup(yytext);
                                  #endif
                                  return DOCUMENT;
                                }

<STRING>[[:space:]]+ { return SPACES; }
<STRING>\\\\         {
                       #ifndef UT_LEXER
                           yylval.c = '\\';
                       #endif
                       return CHARACTER;
                     }
<STRING>\\\"         {
                       #ifndef UT_LEXER
                           yylval.c = '"';
                       #endif
                       return CHARACTER;
                     }
<STRING>[^"]         {
                       #ifndef UT_LEXER
                           yylval.c = yytext[0];
                       #endif
                       return CHARACTER;
                     }
<STRING>\"           {
                       BEGIN INITIAL;
                       return '"';
                     }


in           { return IN; }
if           { return IF; }
let          { return LET; }
then         { return THEN; }
else         { return ELSE; }
where        { return WHERE; }
-\>          { return ARROW; }
fun          { return FUNC; }
rec          { return RECURSIVE; }
match        { return TMATCH; }
with         { return WITH; }
end          { return END; }
emit         { return TEMIT; }

"||"         { return OU; }
"&&"         { return ET; }
"<"          { return INF; }
">"          { return SUP; }
"=="         { return EGAL; }
"!="         { return NEGAL; }
"<="         { return INFEQ; }
">="         { return SUPEQ; }
"//"         { return DIVIDE; }


(?i:xml){LABELSET}*                 {
                                        #ifndef UT_LEXER
                                             yylval.s = strdup(yytext);
                                        #endif
                                        return SYMBOL;
                                    }

[[:alpha:]]{LABELSET}*|_{LABELSET}+/[{\[\/] {
                                             #ifndef UT_LEXER
                                                  yylval.s = strdup(yytext);
                                             #endif
                                             return LABEL;
                                            }

[[:alpha:]]{LABELSET}*|_{LABELSET}+        {
                                             #ifndef UT_LEXER
                                                  yylval.s = strdup(yytext);
                                             #endif
                                             return SYMBOL;
                                           }


\"                         {  BEGIN STRING; return '"'; }
\]/[[:space:]]+\/                      {  return ILLEGAL; }
\$                         {  BEGIN IMPORT; return '$'; }

[[:digit:]]+ {
               #ifndef UT_LEXER
                   yylval.n = atoi(yytext);
               #endif
               return NUMBER;
             }

[[:space:]]+ {}
<INITIAL,IMPORT>. { return yytext[0]; }

%%
