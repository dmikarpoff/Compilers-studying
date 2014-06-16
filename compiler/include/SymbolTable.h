#ifndef SYMBOLTABLE_H_
#define SYMBOLTABLE_H_

#include <map>

class VariableRecord {
public:
    std::string id, type;
    size_t depth;
    size_t offset;
};

class SymbolTable {
public:
    typedef std::pair<std::string, size_t> pair_str_sz;

    SymbolTable():
        free_offset(0) {}
    size_t free_offset;
    size_t last_depth;
    std::map<pair_str_sz, VariableRecord> variable;
};

#endif  // SYMBOLTABLE_H_
