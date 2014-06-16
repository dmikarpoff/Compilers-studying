#ifndef INCLUDE_PARSERHELPER_H_
#define INCLUDE_PARSERHELPER_H_

#include <cstdlib>

#include <SyntaxTree.h>
#include <SymbolTable.h>

class ParserHelper {
 public:
    static ParserHelper* getInstance();
    static std::string convertBisonString(const std::string& str);
    static std::string errorMessageForUnexpecedToken(const std::string& str);
    SyntNode* ast;
    int error_count[3];

 private:
    static ParserHelper* object;
    SymbolTable sym_table;
    ParserHelper();
    ~ParserHelper();
};

#endif  // INCLUDE_PARSERHELPER_H_
