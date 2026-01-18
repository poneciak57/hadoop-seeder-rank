#include <iostream>
#include <string>
#include <cstdlib>

int main() {
    std::ios_base::sync_with_stdio(false);
    std::cin.tie(NULL);

    std::string line;
    while (std::getline(std::cin, line)) {
        size_t tab_pos = line.find('\t');
        if (tab_pos != std::string::npos) {
            std::string ip = line.substr(0, tab_pos);
            std::string count_str = line.substr(tab_pos + 1);
            
            try {
                long long count = std::stoll(count_str);
                // Output negative count for descending sort
                std::cout << -count << "\t" << ip << "\n";
            } catch (...) {
                continue;
            }
        }
    }
    return 0;
}
