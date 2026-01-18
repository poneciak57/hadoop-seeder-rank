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
            std::string count_str = line.substr(0, tab_pos);
            std::string ip = line.substr(tab_pos + 1);
            
            try {
                long long neg_count = std::stoll(count_str);
                // Convert back to positive
                std::cout << ip << "\t" << -neg_count << "\n";
            } catch (...) {
                continue;
            }
        }
    }
    return 0;
}
