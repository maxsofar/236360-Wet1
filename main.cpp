#include "tokens.hpp"
#include "output.hpp"
#include <string>
#include <sstream>
#include <iostream>

std::string process_string(const char *str) {
    std::string processed;
    const char *src = str;

    while (*src) {
        if (*src == '\\') {
            src++;
            switch (*src) {
                case 'n': processed += '\n'; break;
                case 't': processed += '\t'; break;
                case 'r': processed += '\r'; break;
                case '\\': processed += '\\'; break;
                case '\"': processed += '\"'; break;
                case 'x': {
                    src++;
                    if (isxdigit(src[0]) && isxdigit(src[1])) {
                        std::stringstream ss;
                        ss << std::hex << src[0] << src[1];
                        int hexValue;
                        ss >> hexValue;
                        processed += static_cast<char>(hexValue);
                        src += 1; // Move past the second hex digit
                    } else {
                        processed += 'x'; // If not valid hex, just add 'x'
                    }
                    break;
                }
                // Add more escape sequences
                default: processed += *src; break;
            }
        } else {
            processed += *src;
        }
        src++;
    }

     // Pop the last character if it is a double quote
    if (!processed.empty() && processed.back() == '"') {
        processed.pop_back();
    }

    return processed;
}

int main() {
    tokentype token;

    // Read tokens until the end of file is reached
    while (token = static_cast<tokentype>(yylex())) {
        switch (token) {
            case STRING: {
                // std::cout << "test: " << yytext << std::endl;
                std::string processed = process_string(yytext);
                output::printToken(yylineno, token, processed.c_str());
                break;
            }
            default:
                output::printToken(yylineno, token, yytext);
                break;
        }
    }
    return 0;
}
