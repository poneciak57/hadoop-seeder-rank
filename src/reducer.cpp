#include <iostream>
#include <string>
#include <cstdlib>

int main() {
    std::ios_base::sync_with_stdio(false);
    std::cin.tie(NULL);

    std::string line;
    std::string current_ip = "";
    long long current_sum = 0;

    while (std::getline(std::cin, line)) {
        size_t tab_pos = line.find('\t');
        if (tab_pos != std::string::npos) {
            std::string ip = line.substr(0, tab_pos);
            std::string count_str = line.substr(tab_pos + 1);
            
            try {
                long long count = std::stoll(count_str);
                
                if (ip == current_ip) {
                    current_sum += count;
                } else {
                    if (!current_ip.empty()) {
                        std::cout << current_ip << "\t" << current_sum << "\n";
                    }
                    current_ip = ip;
                    current_sum = count;
                }
            } catch (...) {
                continue;
            }
        }
    }
    // Output the last IP
    if (!current_ip.empty()) {
        std::cout << current_ip << "\t" << current_sum << "\n";
    }
    return 0;
}
