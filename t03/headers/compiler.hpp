
#ifndef COMPILER_INCL
#define COMPILER_INCL

#include "tokenization.hpp"

class Compiler
{

  /* fields */
  private:

  /* buffer with code */
    char * codeP_ = nullptr;
  /* tokens massive */
    token_t * tokensP_  = nullptr;

  /* compile error info */
    err_t compileError_                     = err_t::OK_;
    tokenLocation_t compileErrorLocation_   = UNDEF_LOC_;
    
  /* methods */
  public:

  /* default ctor */
    Compiler();

  /* to free all memory */
   ~Compiler();

  /* deleted stuff */
   Compiler( const Compiler& toCpy ) = delete;
   Compiler operator=( const Compiler& rVal ) = delete; 

  /* compile file */
    err_t compile( const char* const inNameP,
                   const char* const outNameP );

  private:

  /* func to tokenize code */
    err_t tokenize();

};

#endif
