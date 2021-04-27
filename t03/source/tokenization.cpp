
#include "compiler.hpp"

/* func to get symbols sequence from code buff */
static int getSeq( char * const dest, char const * const code, size_t const inFormatId );

/* choose correct sequences of symbols
 * first  format string in pair is for first symbol (usually first symbol have diffirent rules)
 * second format string in pair is for all next symbols
 */
/* max format str size */
static const size_t INPUT_FORMAT_MAX_LEN_ = 0x40;

static const char INPUT_FORMATS_ [][0x02][INPUT_FORMAT_MAX_LEN_] = {
      /* for non-inbuild identifiers
       * SHOULD CHECK AT FIRST, BECAUSE THEN,
       * IF THERE ARE NO MATCHES IN CASES, ERROR CAN BE EASELY FOUND
       */
      { "%1[A-Za-z_]"       , "%31[A-Za-z0-9_]%n"   } ,
      /* for terminal    sequences    */
      { "%1[][:PE+R-]"      , "%31[ROCNDP0-9]%n"    } ,
      /* for in-build    cmd names    */
      { "%1[A-Z]"           , "%31[A-Z]%n"          }
};

/* number of formats to check */
static const size_t INPUT_FORMATS_NUM_ = sizeof (INPUT_FORMATS_) / (0x02 * INPUT_FORMAT_MAX_LEN_);
/* identifier input format */
static const size_t IDENT_INPUT_FORMAT_ = 0x00;
/* initial number of tokens for allocation */
static const size_t NUMOF_TOC_ = 0x0100;

err_t Compiler::tokenize ()
{
    /* allocating memory for tokens */
    tokensP_ = (token_t* )calloc (sizeof (token_t), NUMOF_TOC_);
    if (tokensP_ == nullptr)
        return err_t::MEM_ERR_;

    /* global code buff shift */
    int globalShift = 0;
    /* additional code buff shift */
    int localShift  = 0;

    /* for reallocations */
    int numOfToks = NUMOF_TOC_;

    /* running trought all found tokens until EOF found */
    for (int tokId = 0;; tokId++)
    {
        /* number of tokens check, if there are to many tokens => reallocating */
        if (tokId >= numOfToks)
        {
            /* reallocation */
                numOfToks *= 2;
                token_t* reallp = (token_t* )realloc (tokensP_, sizeof (token_t) * numOfToks);
                if (reallp == nullptr)
                {
                    free (tokensP_);
                    return err_t::MEM_ERR_;
                }

            /* new ptr assignation */
                tokensP_ = reallp;
        }

        token_t newToken = UNDEF_TOKEN_;

        /* skipping spaces */
            sscanf (codeP_ + globalShift, " %n", &localShift);
            globalShift += localShift;
            localShift = 0;

        newToken.location_ = codeP_ + globalShift;

        /* trying to get number */
        if (sscanf (codeP_ + globalShift, " %d%n ", &newToken.data_.number_, &localShift) > 0)
            newToken.type_ = tokenType_t::NUM_;

        /* trying to get format name */
        else for (size_t formatId = 0; formatId < INPUT_FORMATS_NUM_; ++formatId)
        {

            /* trying to get symbol sequence, consisting of formats symbols */
            char name [32] = "";
            localShift = getSeq (name, codeP_ + globalShift, formatId);

            /* sequence get success! */
            if (localShift != 0)
            {
                for (size_t cmdId = 0; cmdId < CMD_NUM_; ++cmdId)
                {
                    if (!strcmp (KEYS_ [cmdId].name_, name))
                    {
                        newToken.type_ = tokenType_t::KEYWORD_;
                        newToken.data_.keywordId_ = KEYS_ [cmdId].keywordId_;
                        break;
                    }
                }

                /* known sequences not found */
                if (newToken.type_ == UNDEF_TOKEN_.type_)
                    if (formatId == IDENT_INPUT_FORMAT_)
                        /* identifier format used => all is ok */
                        newToken.type_ = tokenType_t::IDENT_;
            }

            /* token parse success */
            if (newToken.type_ != tokenType_t::UNDF_T_)
                break;
        }

        /* token parsed => try to get next */
        if (newToken.type_ != tokenType_t::UNDF_T_)
        {
            globalShift += localShift;
            localShift = 0;
            tokensP_ [tokId] = newToken;
            continue;
        }
            
        /* can't parse token */
        /* not EOF => not OK */
        if (codeP_[globalShift] != '\0')
        {
            free (tokensP_);
            return err_t::SYNT_ERR_;
        }

        tokensP_ [tokId] = newToken;

        return err_t::OK_;
    }

    return err_t::OK_;
}

int getSeq( char * const dest, char const * const code, size_t const inFormatId )
{
    /* assertions */
    assert (!isBadPtr (dest));
    assert (!isBadPtr (code));
    assert (inFormatId < INPUT_FORMATS_NUM_);

    /* buff shift */
    int localShift = 0;

    /* first symbol format check */
    if (sscanf (code, INPUT_FORMATS_ [inFormatId][0], dest) <= 0)
        return 0;

    /* other symbols format check */
    sscanf (code + 1, INPUT_FORMATS_ [inFormatId][1], dest + 1, &localShift);

    return localShift + 1;
}