#include <ParserHelper.h>

ParserHelper* ParserHelper::object = NULL;


ParserHelper *ParserHelper::getInstance()
{
    if (object == NULL)
        object = new ParserHelper();
    return object;
}

ParserHelper::ParserHelper():
    ast(NULL)
{
    types.insert("double");
    types.insert("float");
    types.insert("long");
    types.insert("int");
    types.insert("short");
    types.insert("char");
    types.insert("bool");
    types.insert("void");
}

ParserHelper::~ParserHelper()
{
    if (ast != NULL)
        delete ast;
}
