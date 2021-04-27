
#ifndef UTILS_INCL
#define UTILS_INCL

#include <cstdio>
#include <cstdlib>
#include <cstddef>
#include <string.h>
#include <cmath>
#include <cassert>
#include <memory.h>

/* for errors output */
enum class err_t
{
    OK_ = 0              ,

    MEM_ERR_ = -0xFFFF   ,
    PTR_ERR_             ,
    FILE_ERR_            ,
    SYNT_ERR_            ,
};

/* to check ptrs validity */
  bool isBadPtr( void const * const ptr );


/* To read file to buff */
  err_t readFile2Buff( char const * const inFileNameP,
                       char ** const buffPP,
                       size_t * const sizeP );

/* To write buff to file */
  err_t writeBuff2File( char const * const outFileNameP,
                        char const * const buffP,
                        size_t const buffSize );

/* To get file length */
  /* Rewinds file back! */
  size_t getFileLength( FILE* const fileP );

/* Compiler class */
class Compiler;

#endif