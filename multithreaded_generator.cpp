#include <iostream>
#include <thread>
#include <vector>
#include <atomic>
#include <unordered_set>
#include <memory> 

struct IPAddress {
    char address[16]; // Format: xxx.xxx.xxx.xxx\0
};

// Ip address is 255.255.255.255 so can be repressented as a 32-bit integer
IPAddress int_to_ip(uint32_t ip_int) {
    IPAddress ip;
    snprintf(ip.address, sizeof(ip.address), "%u.%u.%u.%u",
             (ip_int >> 24) & 0xFF,
             (ip_int >> 16) & 0xFF,
             (ip_int >> 8) & 0xFF,
             ip_int & 0xFF);
    return ip;
}

uint32_t random_ip() {
    return rand() % 0xFFFFFFFF;
}

uint32_t random_bytes(int from, int to) {
    return from + (rand() % (to - from + 1));
}

std::vector<IPAddress> generate_ips(int unique_count) {
  std::unordered_set<uint32_t> unique_ips;
  std::vector<IPAddress> result;
  result.reserve(unique_count);
  for (int i = 0; i < unique_count; i++) {
    uint32_t ip_int;
    do {
      ip_int = random_ip();
    } while (unique_ips.find(ip_int) != unique_ips.end());
    unique_ips.insert(ip_int);
    result.emplace_back(int_to_ip(ip_int));
  }
  return std::move(result);
}

struct Slot {
  std::vector<std::pair<IPAddress, unsigned int>> ips;
  std::atomic<bool> ready = false;
};

std::atomic<unsigned long long> occupied_space = 0;
std::atomic<unsigned long long> slot_index = 0;
std::vector<IPAddress> generated_ips;
std::vector<std::unique_ptr<Slot>> slots;


void printer_job() {
  int index = 0;
  while (index < slots.size()) {
    if (slots[index]->ready.load(std::memory_order_acquire)) {
      for (const auto& ip : slots[index]->ips) {
        std::cout << ip.first.address << "," << ip.second << "\n";
      }
      index++;
      auto prev_capacity = slots[index - 1]->ips.capacity();
      slots[index - 1].reset();
      occupied_space.fetch_sub(sizeof(Slot) * prev_capacity, std::memory_order_acq_rel);
    } else {
      std::this_thread::yield();
    }
  }
}

void generator_job(int slot_size) {
  while (true) {
    if (occupied_space.load(std::memory_order_acquire) > 5ULL * 1024 * 1024 * 1024) {
      std::this_thread::yield();
      continue;
    }
    int index = slot_index.fetch_add(1, std::memory_order_acq_rel);
    if (index >= slots.size()) {
      break;
    }
    slots[index]->ips.reserve(slot_size);
    occupied_space.fetch_add(sizeof(Slot) * slot_size, std::memory_order_acq_rel);
    for (int i = 0; i < slot_size; i++) {
      const unsigned int byte_count = random_bytes(40, 1500);
      const IPAddress& ip = generated_ips[rand() % generated_ips.size()];
      slots[index]->ips.emplace_back(ip, byte_count);
    }
    slots[index]->ready.store(true, std::memory_order_release);
  }
}


void generate(int ip_count, unsigned long long test_len) {
  generated_ips = generate_ips(ip_count);

  const int slot_size = 10000;
  const unsigned long long slot_count = (test_len + slot_size - 1) / slot_size;
  slots.reserve(slot_count);
  for (unsigned long long i = 0; i < slot_count; ++i) {
    slots.push_back(std::make_unique<Slot>());
  }

  const int thread_count = std::thread::hardware_concurrency() - 1;
  std::vector<std::thread> threads;
  threads.reserve(thread_count + 1);

  threads.emplace_back(printer_job);
  for (int i = 0; i < thread_count; i++) {
    threads.emplace_back(generator_job, slot_size);
  }

  for (auto& t : threads) {
    t.join();
  }
}


int main() {
  std::ios_base::sync_with_stdio(false);
  std::cin.tie(nullptr);
  std::cout.tie(nullptr);

  const int ip_count = 100 * 1000;
  const unsigned long long test_len = 3ULL * 1000 * 1000 * 1000;
  generate(ip_count, test_len);


  std::cout.flush();
}
