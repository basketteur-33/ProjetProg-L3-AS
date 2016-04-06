#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>
#include <lexer.h>
#include <parser.h>

static void usage (const char const *s_program) {
    printf("\nusage : %s [OPTIONS]\n\n"
	   "OPTIONS :\n"
	   "-f : a source file to compile.\n"
	   "By default, the program takes his input on stdin.\n"
	   "-o : an output file.\n"
	   "By default, the program writes his output on stdout.\n\n"
	   , s_program);
    exit(EXIT_FAILURE);
}

int main (int argc, char *argv[]) {
    FILE *fdout = stdout;
    FILE *fdin  = stdin;
    int c;
    while ((c = getopt(argc, argv, "f:o:")) > -1) {
	switch (c) {
	case 'f' :
	    fdin = fopen(optarg, "r");
	    if (fdin == NULL) {
		fprintf(stderr, "An error occured while opening input file %s !\n", optarg);
	        return EXIT_FAILURE;
	    }
	    break ;

	case 'o' :
	    fdout = fopen(optarg, "w");
	    if (fdout == NULL) {
		fprintf(stderr, "An error occured while creating output file %s !\n", optarg);
		return EXIT_FAILURE;
	    }
	    break ;

	case '?' :
	    if (optopt == 'f' || optopt == 'o') {
		fprintf (stderr, "Option -%c requires an argument.\n", optopt);
	    } else if (isprint (optopt)) {
		fprintf (stderr, "Unknown option `-%c'.\n", optopt);
	    } else {
		fprintf (stderr, "Unknown option character `\\x%x'.\n", optopt);
	    }
	    usage(argv[0]);
	    break ;

	default : break ;
	}
    }
    parser_context_t context = &(struct parser_context_s){ .t = NULL, .st = NULL };
    yyin = fdin;
    int status = yyparse(context);
    tree_to_xml(PARSER_CONTEXT_GET_TREE(context), fdout);
    fclose(fdin);
    fclose(fdout);

    return (status == 0) ? EXIT_SUCCESS : EXIT_FAILURE ;
}
