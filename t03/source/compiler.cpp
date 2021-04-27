
#include "compiler.hpp"

err_t Compiler::compile ( const char* const inNameP,
                          const char* const outNameP )
{
    size_t numOFChars = 0;

    /* reading file */
    err_t error = readFile2Buff (inNameP, &codeP_, &numOFChars);
    if (error != err_t::OK_)
        return error;

    error = tokenize ();
    if (error != err_t::OK_)
        return error;

    for (size_t tokId = 0; tokensP_ [tokId].type_ != tokenType_t::UNDF_T_; ++tokId)
        printf ("%s" "\n", tokensP_ [tokId].location_);

    return err_t::OK_;
}