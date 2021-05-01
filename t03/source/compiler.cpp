
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

            {
                free (binCodeP_);
                return err_t::SYNT_ERR_;
            }

            case tokenType_t::KEYWORD_:

            {
                switch (tok.data_.keywordId_)
                {
                    case keywordId_t::CMD_ADD_:

                    {
                        /* there should be 3 registers */
                        int ftArgId = getRegId (tokensP_ [++tokId]);
                        int sdArgId = getRegId (tokensP_ [++tokId]);

                        int destId  = getRegId (tokensP_ [++tokId]);

                        if (ftArgId != BAD_REG_ID_ &&
                            sdArgId != BAD_REG_ID_ &&
                            destId  != BAD_REG_ID_)
                        {
                            binCodeP_ [binShift++] = (char)keywordId_t::CMD_ADD_ +
                            (ftArgId << 8) + (sdArgId << 16) + (destId << 24);

                            break;
                        }

                        free (binCodeP_);
                        return err_t::SYNT_ERR_;
                    }
                    break;

                    case keywordId_t::CMD_MOV_:

                    {
                        size_t tokOffset = 0;
                        int ftNum = 0;
                        int sdNum = 0;

                        int ftArg = parseMov (tokensP_ + (++tokId), &tokOffset, &ftNum);
                        int sdArg = 0;

                        tokId += tokOffset;

                        sdArg = parseMov (tokensP_ + tokId, &tokOffset, &sdNum);

                        if ((ftArg & ARG_ERR_MASK_) || (sdArg & ARG_ERR_MASK_) || 
                            ((ftArg & ARG_NUM_MASK_) && !(ftArg & ARG_MEM_MASK_)))
                        {
                            free (binCodeP_);
                            return err_t::SYNT_ERR_;
                        }

                        tokId += tokOffset - 1;

                        binCodeP_ [binShift++] = (char) keywordId_t::CMD_MOV_ +
                                                 (ftArg << 8) + (sdArg << 20);

                        binCodeP_ [binShift++] = ftNum;
                        binCodeP_ [binShift++] = sdNum;
                    }
                    break;

                    case keywordId_t::CMD_CMP_:

                    {
                        /* there should be 2 registers */
                        int ftArgId = getRegId (tokensP_ [++tokId]);
                        int sdArgId = getRegId (tokensP_ [++tokId]);

                        if (ftArgId != BAD_REG_ID_ &&
                            sdArgId != BAD_REG_ID_)
                        {
                            binCodeP_ [binShift++] = (char)tok.data_.keywordId_ +
                            (ftArgId << 8) + (sdArgId << 16);

                            break;
                        }

                        free (binCodeP_);
                        return err_t::SYNT_ERR_;
                    }
                    break;

                    case keywordId_t::CMD_JEQ_:
                    case keywordId_t::CMD_JMP_:
                    case keywordId_t::CMD_JGG_:

                    {
                        token_t arg = tokensP_ [++tokId];

                        if (arg.type_ == tokenType_t::IDENT_)
                        {
                            int labelId = getLabel (arg.location_);

                            if (labelId != BAD_TOKEN_ID_)
                            {
                                binCodeP_ [binShift++] = (char)tok.data_.keywordId_;
                                binCodeP_ [binShift++] = labelsP_[labelId].binOffset_ + 1 - binShift;

                                break;
                            }
                        }

                        free (binCodeP_);
                        return err_t::SYNT_ERR_;
                    }
                    break;
                    
                    default:

                    {
                        free (binCodeP_);
                        return err_t::SYNT_ERR_;
                    }
                }
            }
            break;

            case tokenType_t::IDENT_:

            {
                token_t nextTok = tokensP_ [++tokId];

                if (nextTok.type_ == tokenType_t::KEYWORD_ &&
                    nextTok.data_.keywordId_ == keywordId_t::TR_LABEL_)
                    break;

                free (binCodeP_);
                return err_t::SYNT_ERR_;
            }
            break;
        }
    }

    binSize_ = binShift;
    return err_t::OK_;
}

err_t Compiler::firstPass()
{
    size_t tokId   = 0;
    size_t labelId = 0;

    size_t offset = 0;

    token_t tok = tokensP_[0];

    for (; tok.type_ != tokenType_t::UNDF_T_; tok = tokensP_ [++tokId])
    {
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
            switch (tok.data_.keywordId_)
            {

            case keywordId_t::CMD_ADD_:
                tokId += 3;
                break;

            case keywordId_t::CMD_CMP_:
                tokId += 2;
                break;

            case keywordId_t::CMD_JEQ_:
            case keywordId_t::CMD_JMP_:
            case keywordId_t::CMD_JGG_:
                tokId += 1;
                ++offset;
                break;

            case keywordId_t::CMD_MOV_:
            
            {
                size_t tokOffset = 0;
                int number = 0;

                int firstArg = parseMov (tokensP_ + (++tokId), &tokOffset, &number);
                if (firstArg & ARG_ERR_MASK_ || ((firstArg & ARG_NUM_MASK_) && !(firstArg & ARG_MEM_MASK_)))
                    return err_t::SYNT_ERR_;

                tokId += tokOffset;

                int secondArg = parseMov (tokensP_ + tokId, &tokOffset, &number);
                if (secondArg & ARG_ERR_MASK_)
                    return err_t::SYNT_ERR_;

                tokId += tokOffset - 1;

                offset += 2;
            }
            break;

            default:
                return err_t::SYNT_ERR_;

            }

            ++offset;
        }
        break;

        default:

        {
            assert (0);
        }
        
        }
    }

    return err_t::OK_;
}

int Compiler::parseMov( token_t const * args, size_t * offset, int * number )
{
    token_t ftTok = args [0];
    token_t sdTok = args [1];
    token_t trTok = args [2];

    *offset = 1;
    *number = ftTok.data_.number_;

    if (ftTok.type_ == tokenType_t::KEYWORD_)
    {
        int regId = getRegId (ftTok);

        if (regId == BAD_REG_ID_)
        {
            *offset = 3;
            *number = sdTok.data_.number_;

            if (ftTok.data_.keywordId_ != keywordId_t::TR_LBR_  ||
                trTok.type_            != tokenType_t::KEYWORD_ ||
                trTok.data_.keywordId_ != keywordId_t::TR_RBR_)

                return ARG_ERR_MASK_;

            if (sdTok.type_ == tokenType_t::NUM_)
                return ARG_MEM_MASK_ | ARG_NUM_MASK_;

            regId = getRegId (sdTok);

            if (regId != BAD_REG_ID_)
                return ARG_MEM_MASK_ | regId;

            return ARG_ERR_MASK_;
        }

        else return regId;
    }

    if (ftTok.type_ == tokenType_t::NUM_)
        return ARG_NUM_MASK_;

    return ARG_ERR_MASK_;
}

int Compiler::getRegId( token_t token )
{
    if (token.type_ != tokenType_t::KEYWORD_)
        return BAD_REG_ID_;

    if (token.data_.keywordId_ >= keywordId_t::R00_ &&
        token.data_.keywordId_ <= keywordId_t::R1F_)
        return (int) token.data_.keywordId_ - (int) keywordId_t::R00_;

    return BAD_REG_ID_;
}

int Compiler::getLabel( tokenLocation_t nameP )
{
    label_t label = labelsP_[0];

    for (int labelId = 0; label.tokenId_ != BAD_TOKEN_ID_; label = labelsP_ [++labelId])
    {
        if (!nameCmp (nameP, tokensP_ [label.tokenId_].location_))
            return labelId;
    }

    return BAD_TOKEN_ID_;
}

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

/* end of name symbols */
static const char EON_SYMBOLS_[] = ": \n\r";

static bool checkEON( const char symbol )
{
    for (size_t symbolId = 0; symbolId < sizeof (EON_SYMBOLS_); ++symbolId)
        if (symbol == EON_SYMBOLS_[symbolId])
            return true;

    return false;
}