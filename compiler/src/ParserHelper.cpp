#include <ParserHelper.h>

ParserHelper* ParserHelper::object = NULL;


ParserHelper *ParserHelper::getInstance()
{
    if (object == NULL)
        object = new ParserHelper();
    return object;
}

ParserHelper::~ParserHelper()
{
    if (ast != NULL)
        delete ast;
}
