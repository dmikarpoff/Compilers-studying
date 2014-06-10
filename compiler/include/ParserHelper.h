#ifndef INCLUDE_PARSERHELPER_H_
#define INCLUDE_PARSERHELPER_H_

#include <cstdlib>

#include <SyntaxTree.h>

class ParserHelper {
 public:
    static ParserHelper* getInstance();
    SyntNode* ast;
 private:
    static ParserHelper* object;

    ParserHelper();
    ~ParserHelper();
};

#endif  // INCLUDE_PARSERHELPER_H_
