
#include "compiler.hpp"

Compiler::Compiler() { }

Compiler::~Compiler()
{
    if (codeP_ != nullptr)
    {
        free (codeP_);
        codeP_ = nullptr;
    }

    if (tokensP_ != nullptr)
    {
        free (tokensP_);
        tokensP_ = nullptr;
    }
}

err_t Compiler::compile ( const char* const inNameP,
                          const char* const outNameP )
{
    size_t numOFChars = 0;

    /* reading file */
    err_t error = readFile2Buff (inNameP, &codeP_, &numOFChars);
    if (error != err_t::OK_)
        return error;

    /* tokenization */
    error = tokenize ();
    if (error != err_t::OK_)
        return error;

    /* assembling */
    error = assemble ();
    if (error != err_t::OK_)
        return error;

    /* writing to output file */
    error = writeBuff2File (outNameP, (char* )binCodeP_, binSize_ * sizeof (binType));

    return error;
}

err_t Compiler::assemble()
{
    assert (tokNum_ != 0);

    binCodeP_ = (binType* )calloc (sizeof (binType), tokNum_);
    if (binCodeP_ == nullptr)
        return err_t::MEM_ERR_;

    err_t error = firstPass ();
    if (error != err_t::OK_)
        return error;

    token_t tok = tokensP_[0];
    size_t binShift = 0;

    for (size_t tokId = 0; tok.type_ != tokenType_t::UNDF_T_; ++tokId)
    {
        tok = tokensP_[tokId];

        switch (tok.type_)
        {
            case tokenType_t::NUM_:
                free (binCodeP_);
                return err_t::SYNT_ERR_;

            case tokenType_t::KEYWORD_:
                switch (tok.data_.keywordId_)
                {
                    case keywordId_t::CMD_ADD_:
                    {
                        token_t ftArg = tokensP_ [++tokId];
                        token_t sdArg = tokensP_ [++tokId];

                        if (ftArg.type_ == tokenType_t::KEYWORD_ &&
                            sdArg.type_ == tokenType_t::KEYWORD_)
                        {
                            int ftReg = (int)ftArg.data_.keywordId_;
                            int sdReg = (int)sdArg.data_.keywordId_;

                            if (ftReg >  (int)keywordId_t::R00_ &&
                                ftReg <= (int)keywordId_t::R1F_)
                            if (sdReg >  (int)keywordId_t::R00_ &&
                                sdReg <= (int)keywordId_t::R1F_)

                            {
                                binCodeP_
                            }
                        }
                    }
                    break;

                    case keywordId_t::CMD_CMP_:
                    case keywordId_t::CMD_MOV_:
                    {

                    }
                    break;
                    
                    case keywordId_t::CMD_DMP_:
                    {

                    }
                    break;

                    case keywordId_t::CMD_JEQ_:
                    case keywordId_t::CMD_JMP_:
                    case keywordId_t::CMD_JGG_:
                    {

                    }
                    break;
                    
                    default:
                        free (binCodeP_);
                        return err_t::SYNT_ERR_;
                }

                break;

            case IDENT_:
               if (data->tokens_[++tok_id].type   == TERM_ &&
                  (data->tokens_[tok_id  ].id     == TR_PROC_ ||
                   data->tokens_[tok_id  ].id     == TR_LABL_))
                   break;

                free (binCode);
                return SYNT_ERR;
        }

    }
}

err_t Compiler::firstPass()
{
    size_t tokId   = 0;
    size_t labelId = 0;

    size_t offset = 0;

    token_t tok = tokensP_[0];

    for (; tok.type_ != tokenType_t::UNDF_T_; ++tokId)
    {
        tok = tokensP_[tokId];

        switch (tok.type_)
        {

        case tokenType_t::IDENT_:
        
        {
            token_t nextTok = tokensP_ [++tokId];
            if (nextTok.type_ == tokenType_t::KEYWORD_ &&
                nextTok.data_.keywordId_ == keywordId_t::TR_LABEL_)
            {
                if (getLabel (tok.location_) != BAD_TOKEN_ID_)
                    return err_t::SYNT_ERR_;
                
                labelsP_ [labelId  ].tokenId_ = tokId - 1;
                labelsP_ [labelId++].binOffset_ = offset;
            }

            else return err_t::SYNT_ERR_;
        }
        break;

        case tokenType_t::KEYWORD_:
                
        {
            if (tok.data_.keywordId_ == keywordId_t::CMD_JEQ_ ||
                tok.data_.keywordId_ == keywordId_t::CMD_JMP_ ||
                tok.data_.keywordId_ == keywordId_t::CMD_JGG_   ) ++tokId;

            ++offset;
        }
        break;

        case tokenType_t::NUM_:
        
        {
            ++offset;
        }
        break;

        default:
            assert (0);
        
        }

    }

}

int Compiler::getLabel( tokenLocation_t nameP )
{
    label_t label = labelsP_[0];

    for (int labelId = 0; label.binOffset_ != BAD_TOKEN_ID_; ++labelId)
    {
        if (!nameCmp (nameP, tokensP_ [label.tokenId_].location_))
            return labelId;
    }

    return BAD_TOKEN_ID_;
}

/* end of name symbols */
static const char EON_SYMBOLS_[] = ": \n\r";

/* to check end of name */
static bool checkEON( const char symbol );

int Compiler::nameCmp( tokenLocation_t ftNameP, tokenLocation_t sdNameP )
{
    for (size_t charId = 0;; ++charId)
    {
        char ftChar = ftNameP[charId];
        char sdChar = sdNameP[charId];

        if (checkEON (ftChar))
        {
            if (checkEON (sdChar))
                return 0;
            
            return -1;
        }

        else if (checkEON (sdChar))
            return 1;

        if (ftChar != sdChar)
            return ftChar - sdChar;
    }

    assert (0);
    return 0;
}

static bool checkEON( const char symbol )
{       
    for (size_t symbolId = 0; symbolId < sizeof (EON_SYMBOLS_); ++symbolId)
        if (symbol == EON_SYMBOLS_[symbolId])
            return true;

    return false;
}