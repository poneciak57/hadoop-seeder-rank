#include <iostream>
#include <string>
#include <vector>

int main() {
    std::ios_base::sync_with_stdio(false);
    std::cin.tie(NULL);

    std::string line;
    while (std::getline(std::cin, line)) {
        if (line.empty()) continue;
        
        size_t comma_pos = line.find(',');
        if (comma_pos != std::string::npos) {
            std::string ip = line.substr(0, comma_pos);
            std::string bytes_str = line.substr(comma_pos + 1);
            
            // Output tab-separated IP and bytes
            std::cout << ip << "\t" << bytes_str << "\n";
        }
    }
    return 0;
}
