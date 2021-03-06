#include <stdlib.h>
#include <ut/lexer.h>

int main (void) {
    return ((ut_run(UT_NEW("$..a/b/bar->f", 7, '$', '.', '.', DIRECTORY, DOCUMENT, ARROW, SYMBOL))         == UT_PASSED) &&
            (ut_run(UT_NEW("$..a/b/bar->xml_f", 7, '$', '.', '.', DIRECTORY, DOCUMENT, ARROW, SYMBOL)) == UT_PASSED) &&
            (ut_run(UT_NEW("$..bar->f", 6, '$', '.', '.', DOCUMENT, ARROW, SYMBOL))                        == UT_PASSED) &&
            (ut_run(UT_NEW("$a/bar->f", 5, '$', DIRECTORY, DOCUMENT, ARROW, SYMBOL))                       == UT_PASSED) &&
            (ut_run(UT_NEW("$bar->f", 4, '$', DOCUMENT, ARROW, SYMBOL))                                    == UT_PASSED))
        ? EXIT_SUCCESS : EXIT_FAILURE ;
}
