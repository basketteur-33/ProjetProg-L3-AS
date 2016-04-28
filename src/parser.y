/**
 * \file parser.y
 * \brief Fichier contenant les regles constituant l'analyseur syntaxique du projet.
 * \author LABBE Emeric <br>
 * LAHAYE Valentin <br>
 * PARPAITE Thibault <br>
 * SARRABAYROUSE Alexis
 * \date 26 Fevrier 2016
 */

%code top {
#include <stdio.h>
#include <lexer.h>
}

%code requires {
#include <ast.h>
#include <word.h>
}

%code {
void yyerror (struct ast **, char const *);
}

%parse-param {struct ast **root}

%token LABEL
%token LABEL_XML
%token SPACES
%token CHARACTER
%token LET
%token IN
%token WHERE
%token RECURSIVE
%token FUNCTION
%token ARROW
%token IF
%token THEN
%token ELSE
%token DIVIDE INFEQ INF SUPEQ SUP EGAL OU ET

%union {
    char c;
    char *s;
    word_t w;
    struct attributes *a;
    struct ast *ast;
}

%type <c> CHARACTER
%type <s> LABEL LABEL_XML symbol
%type <w> word
%type <a> attributes attribute-list attribute
%type <ast> root let-global let set block label body content word-list empt-list expression
%type <ast> expression-partielle expression-booleenne-e expression-booleenne-t expression-ari-e expression-ari-t expression-ari-f
%type <ast> lambda-function affect application

%start start

%%

start : root   { *root = $1; }
      ;


root : root set   { $$ = mk_forest(true, $1, $2); }
     | let-global { $$ = $1; }
     ;


set : block      { $$ = $1; }
    | label      { $$ = $1; }
    ;


block : '{' body '}' { $$ = $2; }
      ;


body : set body              { $$ = mk_forest(false, $1, $2); }
     | content spaces body     { $$ = mk_forest(false, $1, $3); }
     | application ',' body  { $$ = mk_forest(false, $1, $3); }
     | application           { $$ = mk_forest(false, $1, NULL); }
     | %empty                { $$ = NULL; }
     ;


symbol : LABEL               { $$ = $1; }
       | LABEL_XML           { $$ = $1; }
       ;


expression : expression-booleenne-e
           | let                                { $$ = $1; }
           | lambda-function
           ;


expression-partielle : '(' expression ')'       { $$ = $2; }
                     | set                      { $$ = $1; }
                     | content                  { $$ = $1; }
                     ;


expression-booleenne-e : expression-booleenne-e OU expression-booleenne-t   { $$ = mk_app(mk_app(mk_binop(OR), $1), $3);  } 
                       | expression-booleenne-e ET expression-booleenne-t   { $$ = mk_app(mk_app(mk_binop(AND), $1), $3); } 
                       | expression-booleenne-t                             { $$ = $1; }
                       ;


expression-booleenne-t : expression-booleenne-t INFEQ expression-ari-e      { $$ = mk_app(mk_app(mk_binop(LEQ), $1), $3); } 
                       | expression-booleenne-t INF expression-ari-e        { $$ = mk_app(mk_app(mk_binop(LE), $1), $3);  } 
                       | expression-booleenne-t SUPEQ expression-ari-e      { $$ = mk_app(mk_app(mk_binop(GEQ), $1), $3); } 
                       | expression-booleenne-t SUP expression-ari-e        { $$ = mk_app(mk_app(mk_binop(GE), $1), $3);  } 
                       | expression-booleenne-t EGAL expression-ari-e       { $$ = mk_app(mk_app(mk_binop(EQ), $1), $3);  } 
                       | expression-ari-e                                   { $$ = $1; }
                       ;


expression-ari-e : expression-ari-e '+' expression-ari-t                    { $$ = mk_app(mk_app(mk_binop(PLUS), $1), $3);  }
                 | expression-ari-e '-' expression-ari-t                    { $$ = mk_app(mk_app(mk_binop(MINUS), $1), $3); }
                 | expression-ari-t                                         { $$ = $1; }
                 ;


expression-ari-t : expression-ari-t '*' expression-ari-f                    { $$ = mk_app(mk_app(mk_binop(MULT), $1), $3); }
                 | expression-ari-t DIVIDE expression-ari-f                 { $$ = mk_app(mk_app(mk_binop(DIV), $1), $3);  }
                 | expression-ari-f                                         { $$ = $1; }
                 ;


expression-ari-f : expression-partielle spaces
                 | application spaces
                 ;


let-global : LET symbol spaces affect ';' let-global { $$ = mk_app(mk_fun($2, $6), $4); }
           | %empty                                  { $$ = *root; }
           ;


let : LET symbol spaces affect IN expression                   { $$ = mk_app(mk_fun($2, $6), $4); }
    | '(' expression WHERE symbol spaces affect ')'            { $$ = mk_app(mk_fun($4, $2), $6); }
    | LET RECURSIVE symbol spaces affect IN expression         { $$ = mk_app(mk_fun($3, $7), mk_declrec($3, $5)); }
    | '(' expression WHERE RECURSIVE symbol spaces affect ')'  { $$ = mk_app(mk_fun($5, $2), mk_declrec($5, $7)); }
    ;


affect : symbol spaces affect    { $$ = mk_fun($1, $3); }
       | '=' expression          { $$ = $2; }
       | ARROW expression        { $$ = $2; }
       ;


lambda-function : FUNCTION affect { $$ = $2; }
                ;

     
application : application SPACES expression-partielle { $$ = mk_app($1, $3); }
            | symbol                                  { $$ = mk_var($1); }
            ;


label : LABEL attributes spaces block { $$ = mk_tree($1, false, false, false, $2, $4);    }
      | LABEL block                   { $$ = mk_tree($1, false, false, false, NULL, $2);  }
      | LABEL attributes '/'          { $$ = mk_tree($1, false, true, false, $2, NULL);   }
      | LABEL '/'                     { $$ = mk_tree($1, false, true, false, NULL, NULL); }
      ;



attributes : '[' attribute-list ']' { $$ = $2; }
           | '[' empt-list ']'      { $$ = (struct attributes *)$2; }
           ;


attribute-list : attribute SPACES attribute-list { $$ = $1; $1->next = $3; }
               | attribute                       { $$ = $1; }
               ;


attribute : LABEL spaces '=' content { $$ = mk_attributes(mk_word($1), $4, NULL); }
          ;


content : '"' spaces word-list '"' { $$ = $3; }
      | '"' empt-list '"'        { $$ = $2; }
      ;


word-list : word SPACES word-list { $$ = mk_forest(false, mk_word(word_to_string($1)), $3); word_destroy($1); }
          | word SPACES           { $$ = mk_word(word_to_string($1)); word_destroy($1); }
          | word                  { $$ = mk_word(word_to_string($1)); word_destroy($1); }
          ;


word : word CHARACTER { $$ = word_cat($1, $2); }
     | CHARACTER      { $$ = word_cat(word_create(), $1); }
     ;


empt-list : SPACES { $$ = NULL; }
          | %empty { $$ = NULL; }
          ;


spaces : SPACES
       | %empty
       ;

%%

void yyerror (struct ast **root, char const *s) {
    free(*root);
    fprintf(stderr, "%s\n", s);
}
