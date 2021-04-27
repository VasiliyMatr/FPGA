
#ifndef COMPILER_INCL
#define COMPILER_INCL

#include "tokenization.hpp"

class Compiler
{
  /* data types & consts */
  private:

  /* poison value for token id's */
    static const int BAD_TOKEN_ID_ = -1;
  /* maximum number of labels in one asm file */
    static const size_t LABELS_MAX_NUM_ = 0x400;

  /* to store labels info */
    struct label_t
    {
        int tokenId_        = BAD_TOKEN_ID_;
        size_t binOffset_   = 0;
    };

  /* fixed size numbers for binary buffer */
  typedef int binType;

  /* fields */
  private:

  /* buffer with code */
    char * codeP_ = nullptr;
  /* binary output stuff */
    /* buffer with output binary code */
    binType * binCodeP_ = nullptr;
    /* number of used binType numbers */
    size_t binSize_ = 0;
  /* tokens stuff */
    /* tokens massive */
    token_t * tokensP_  = nullptr;
    /* num of tokens */
    size_t tokNum_ = 0;
  /* for all labels */
    label_t labelsP_ [LABELS_MAX_NUM_];

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

  /* func to assemble code */
    err_t assemble();

  /* func to make first pass */
    err_t firstPass();

  /* func to find label */
    int getLabel( tokenLocation_t nameP );

  /* names cmp */
    int nameCmp( tokenLocation_t ftNameP, tokenLocation_t sdNameP );

};

#endif
