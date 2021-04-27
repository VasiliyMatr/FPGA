
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

    R00_            = 0xff,
    R01_, R02_, R03_, R04_,
    R05_, R06_, R07_, R08_,
    R09_, R0A_, R0B_, R0C_,
    R0D_, R0E_, R0F_, R10_,
    R11_, R12_, R13_, R14_,
    R15_, R16_, R17_, R18_,
    R19_, R1A_, R1B_, R1C_,
    R1D_, R1E_, R1F_,

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
    { keywordId_t::CMD_JGG_, "JGG" },

    { keywordId_t::TR_LABEL_, ":"  },

    { keywordId_t::R00_, "R00" },
    { keywordId_t::R01_, "R01" },
    { keywordId_t::R02_, "R02" },
    { keywordId_t::R03_, "R03" },
    { keywordId_t::R04_, "R04" },
    { keywordId_t::R05_, "R05" },
    { keywordId_t::R06_, "R06" },
    { keywordId_t::R07_, "R07" },
    { keywordId_t::R08_, "R08" },
    { keywordId_t::R09_, "R09" },
    { keywordId_t::R0A_, "R0A" },
    { keywordId_t::R0B_, "R0B" },
    { keywordId_t::R0C_, "R0C" },
    { keywordId_t::R0D_, "R0D" },
    { keywordId_t::R0E_, "R0E" },
    { keywordId_t::R0F_, "R0F" },

    { keywordId_t::R10_, "R10" },
    { keywordId_t::R11_, "R11" },
    { keywordId_t::R12_, "R12" },
    { keywordId_t::R13_, "R13" },
    { keywordId_t::R14_, "R14" },
    { keywordId_t::R15_, "R15" },
    { keywordId_t::R16_, "R16" },
    { keywordId_t::R17_, "R17" },
    { keywordId_t::R18_, "R18" },
    { keywordId_t::R19_, "R19" },
    { keywordId_t::R1A_, "R1A" },
    { keywordId_t::R1B_, "R1B" },
    { keywordId_t::R1C_, "R1C" },
    { keywordId_t::R1D_, "R1D" },
    { keywordId_t::R1E_, "R1E" },
    { keywordId_t::R1F_, "R1F" }

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