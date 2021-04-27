
#include "utils.hpp"

#ifndef TOKENIZATION_INCL
#define TOKENIZATION_INCL

constexpr size_t NAME_SIZE_ = 32;

/* tokens types */
enum class tokenType_t
{
    /* num const */
    NUM_        = 'N',
    /* unknown identifier */
    IDENT_      = 'I',
    /* in-build cmds */
    KEYWORD_    = 'K',

    /* init value */
    UNDF_T_     = 'U'
};

/* keywords identifiers enum */
enum class keywordId_t
{
    /* to move data */
    CMD_MOV_        = 'M',
    
    /* to add data */
    CMD_ADD_        = 'A',
    
    /* to dump specified registers */
    CMD_DMP_        = 'D',
    
    /* to make comparsion */
    CMD_CMP_        = 'C',

    /* to make jumps */
        CMD_JMP_    = 'J',
        CMD_JEQ_    = 'E',
        CMD_JGG_    = 'G',

    /* terminal symbol for labels */
    TR_LABEL_       = 'L',

    /* undefined cmd */
    UNDEF_KEYW_     = 'U'
};

/* struct to store info about all keywords */
struct keywordInfo_t
{
    /* keyword id */
    enum keywordId_t keywordId_  = keywordId_t::UNDEF_KEYW_;
    /* keyword */
    const char * const name_     = "UNDEF";
};

/* all keywords massive */
const keywordInfo_t KEYS_[] = {
    { keywordId_t::CMD_MOV_, "MOV" },
    { keywordId_t::CMD_ADD_, "ADD" },
    { keywordId_t::CMD_DMP_, "DMP" },
    { keywordId_t::CMD_CMP_, "CMP" },
    { keywordId_t::CMD_JMP_, "JMP" },
    { keywordId_t::CMD_JEQ_, "JEQ" },
    { keywordId_t::CMD_JGG_, "JGG" }
};

/* number of commands */
const size_t CMD_NUM_ = sizeof (KEYS_) / sizeof (keywordInfo_t);

/* to store token code location & name */
typedef char const * tokenLocation_t;
/* undefined location */
const tokenLocation_t UNDEF_LOC_ = "UNDEF";

/* to store number constant or keyword id */
union tokenData_t
{
    keywordId_t keywordId_ = keywordId_t::UNDEF_KEYW_;
    int number_;
};

/* lexical token type */
struct token_t
{

    tokenType_t type_           = tokenType_t::UNDF_T_; /* this token type */
    
    tokenLocation_t location_   = UNDEF_LOC_; /* token buffer location (token name begin) */
    
    tokenData_t data_;
};

/* poison value */
const token_t UNDEF_TOKEN_ = { tokenType_t::UNDF_T_, UNDEF_LOC_, keywordId_t::UNDEF_KEYW_ };

#endif