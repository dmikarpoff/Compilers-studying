cmake_minimum_required(VERSION 2.8)

find_package(FLEX REQUIRED)
find_package(BISON REQUIRED)

BISON_TARGET(Parser "${CMAKE_SOURCE_DIR}/bison/Grammar.y" "${CMAKE_SOURCE_DIR}/bison/grammar.cpp")
FLEX_TARGET(Scanner "lex/vocabulary.flex" "${CMAKE_SOURCE_DIR}/lex/lexer.cpp")
ADD_FLEX_BISON_DEPENDENCY(Scanner Parser)

find_package(Boost COMPONENTS system filesystem unit_test_framework REQUIRED)

include_directories(	"${CMAKE_SOURCE_DIR}/include"
			"${CMAKE_SOURCE_DIR}/bison"
			)

# lex test block

add_executable(test_bin/scanner_test		${FLEX_Scanner_OUTPUTS}
						${BISON_Parser_OUTPUTS}
						src/LexHelper.cpp
						include/LexHelper.h
						src/SyntaxTree.cpp
						utest/lex_test.cpp
						)

target_link_libraries(test_bin/scanner_test		${Boost_UNIT_TEST_FRAMEWORK_LIBRARY}
							${Boost_FILESYSTEM_LIBRARY}
							${Boost_SYSTEM_LIBRARY}					
							)

add_test(test_bin/scanner_test lex_test)

#end of lex test block

# lex application block

add_executable(bin/scanner			${FLEX_Scanner_OUTPUTS}
						${BISON_Parser_OUTPUTS}			
						include/LexHelper.h
						src/LexHelper.cpp
						src/SyntaxTree.cpp
						bison/grammar.hpp
						src/scanner.cpp)

# end of lex application block

# bison test block

add_executable(test_bin/parser_test		${FLEX_Scanner_OUTPUTS}
						${BISON_Parser_OUTPUTS}
						src/SyntaxTree.cpp
						src/LexHelper.cpp
						include/SyntaxTree.h
						include/LexHelper.h
						utest/bison_test.cpp
						)

target_link_libraries(test_bin/parser_test		${Boost_UNIT_TEST_FRAMEWORK_LIBRARY}
							${Boost_FILESYSTEM_LIBRARY}
							${Boost_SYSTEM_LIBRARY}					
							)

add_test(test_bin/parser_test test)

#end of bison test block
