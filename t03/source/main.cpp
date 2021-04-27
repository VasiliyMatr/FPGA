
#include "compiler.hpp"

int main( int argc, char* argv[] )
{
    char* inName  = nullptr;
    char* outName = nullptr;

    /* version info */
    printf ("\n"
            "compiling ..." "\n"
            "\n");

    /* args parce */
    for (int i = 1; i < argc; ++i)
    {
        if (argv[i][0] == '-')
            switch (argv[i][1])
            {
              /* Out file name */
                case 'o':

                if ((++i) == argc)
                    break;

                outName = argv[i];
                break;
            }
        else
            inName = argv[i];
    }

    /* assembler data init */
    Compiler compiler;

    err_t error = compiler.compile (inName, outName);
    if (error != err_t::OK_)
    {
        printf ("compilation error!" "\n"
                "error code = %d" "\n", error);
    }

    return 0;

}