
#include "utils.hpp"

bool isBadPtr(const void* ptr)
{
    return ptr == nullptr;
}

err_t readFile2Buff( char const * const inFileNameP,
                     char ** const buffPP ,
                     size_t * const sizeP )
{
  /* Pointers check */
    if (isBadPtr (inFileNameP) || isBadPtr (buffPP) || isBadPtr (sizeP))
        return err_t::PTR_ERR_;

  /* Opening input file */
    FILE* inFileP = fopen (inFileNameP, "rb");
    if (inFileP == nullptr)
        return err_t::FILE_ERR_;

  /* Getting num of bytes in input file */
    size_t bytesNum = getFileLength (inFileP);
    if (bytesNum == 0)
        return err_t::FILE_ERR_;

  /* Allocating memory for buff */
    char * const buffP = (char* )calloc (sizeof (char), bytesNum + 1);
    if (buffP == nullptr)
    {
        fclose (inFileP);
        return err_t::MEM_ERR_;
    }

  /* Reading info and closing input file */
    fread (buffP, sizeof (char), bytesNum, inFileP);
    fclose (inFileP);

  /* Values return stuff */
    *buffPP = buffP;
    *sizeP  = bytesNum;

    return err_t::OK_;
}

/* Rewinds file back!!! */
size_t getFileLength( FILE* const fileP )
{
    assert (!isBadPtr (fileP));

  /* Moving to file end */
    fseek (fileP, 0, SEEK_END);
  /* Getting num of bytes */
    int bytesNum = ftell (fileP);
  /* Rewinding file back to begin */
    rewind (fileP);

    return bytesNum;
}

/* To write buff to file */
err_t writeBuff2File( char const * const outFileNameP,
                      char const * const buffP,
                      size_t const buffSize )
{
  /* Pointers check */
    if (isBadPtr (outFileNameP) || isBadPtr (buffP))
        return err_t::PTR_ERR_;

  /* Opening out file */
    FILE* outFileP = fopen (outFileNameP, "wb");
    if (outFileP == nullptr)
        return err_t::FILE_ERR_;

  /* Writing 2 file */
    fwrite (buffP, buffSize, sizeof (char), outFileP);
    fclose (outFileP);

    return err_t::OK_;
}