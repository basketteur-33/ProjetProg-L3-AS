/**
 * \file string.c
 * \brief Test unitaire du lexer concernant la reconnaissance d'ensembles de type string.
 * \author LAHAYE Valentin <br>
 * PARPAITE Thibault
 * \date 4 Mars 2016
 */

#include <stdlib.h>
#include <ut/lexer.h>

int main (void) {
    return ((ut_run(UT_NEW("\"string\"", 8, '"', CHARACTER, CHARACTER, CHARACTER, CHARACTER, CHARACTER, CHARACTER, '"')) == UT_PASSED) &&
            (ut_run(UT_NEW("\"s s  s \"", 9, '"', CHARACTER, SPACES, CHARACTER, SPACES, CHARACTER, SPACES, '"'))         == UT_PASSED) &&
	    (ut_run(UT_NEW("\"\\\"\"", 3, '"', CHARACTER, '"'))                                                          == UT_PASSED) &&
            (ut_run(UT_NEW("\"\\\\\"", 3, '"', CHARACTER, '"'))                                                          == UT_PASSED))
        ? EXIT_SUCCESS : EXIT_FAILURE ;
}
