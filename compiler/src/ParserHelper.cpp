#include <ParserHelper.h>
#include <LexHelper.h>

ParserHelper* ParserHelper::object = NULL;


ParserHelper *ParserHelper::getInstance()
{
    if (object == NULL)
        object = new ParserHelper();
    return object;
}

std::string ParserHelper::convertBisonString(const std::string &str) {
    if (str == "SEMICOL")
        return "\';\'";
    if (str == "ID")
        return "\'identificator\'";
    if (str == "LPAREN")
        return "\'(\'";
    if (str == "RPAREN")
        return "\')\'";
    if (str == "$end")
        return "\'EOF\'";
    if (str == "BASIC_TYPE")
        return "\'basic_type\'";
    if (str == "CLASS")
        return "\'class\'";
    if (str == "RBRACE")
        return "\'}\'";
    if (str == "LBRACE")
        return "\'{\'";
    return str;
}

std::string ParserHelper::
                errorMessageForUnexpecedToken(const std::string &str) {
    std::string res;
    if (LexHelper::getInstance()->cur_token == BASIC_TYPE)
        res = "basic_type (\'";
    if (LexHelper::getInstance()->cur_token == NUMBER)
        res = "number (\'";
    if (LexHelper::getInstance()->cur_token == ID)
        res = "identificator (\'";
    if (res != "") {
        res += str;
        res += "\')";
        return res;
    }
    res = std::string("\'") + str + "\'";
    return res;
}

ParserHelper::ParserHelper():
    ast(NULL) {
    for (size_t i = 0; i < 3; ++i)
        error_count[i] = 0;
}

ParserHelper::~ParserHelper()
{
    if (ast != NULL)
        delete ast;
}
