#include <iostream>
#include <fstream>
#include <sstream>
#include <vector>
#include <string>
#include <cmath>
#include <algorithm>
#include <chrono>

// Structure to hold timestamp/price pairs
struct TimePrice {
    long long timestampNs;
    double price;
};

// Function to calculate the Simple Moving Average (SMA) over a window.
double calculateSMA(const std::vector<double>& prices, int index, int window) {
    int start = (index - window + 1) < 0 ? 0 : (index - window + 1);
    double sum = 0.0;
    int count = 0;
    for (int i = start; i <= index; ++i) {
        sum += prices[i];
        ++count;
    }
    return (count > 0) ? (sum / count) : 0.0;
}

// Find the index of the price whose timestamp is closest to 'targetTimestamp' uisng BST.
int findClosestIndex(const std::vector<TimePrice>& data, long long targetTimestamp) {
    if (data.empty()) return -1;
    if (targetTimestamp <= data.front().timestampNs) return 0;
    if (targetTimestamp >= data.back().timestampNs) 
        return static_cast<int>(data.size() - 1);

    int left = 0;
    int right = static_cast<int>(data.size()) - 1;
    while (left <= right) {
        int mid = (left + right) / 2;
        long long midTs = data[mid].timestampNs;

        if (midTs == targetTimestamp) {
            return mid; // exact match
        } else if (midTs < targetTimestamp) {
            left = mid + 1;
        } else {
            right = mid - 1;
        }
    }

    // After binary search, 'right' is the largest index with timestamp <= targetTimestamp
    // 'left' is the smallest index with timestamp >= targetTimestamp
    if (right < 0) 
        return 0;
    if (left >= static_cast<int>(data.size())) 
        return static_cast<int>(data.size() - 1);

    long long distLeft  = std::llabs(data[left].timestampNs  - targetTimestamp);
    long long distRight = std::llabs(data[right].timestampNs - targetTimestamp);
    return (distLeft < distRight) ? left : right;
}


int main() {
    // -----------------------------
    // 1) Read CSV: (timestamp_ns, price_ns) pairs
    // -----------------------------
    std::ifstream file("us_data.csv");
    if (!file.is_open()) {
        std::cerr << "Error opening the file!\n";
        return 1;
    }

    std::vector<TimePrice> data;
    data.reserve(100000); // optional reserve

    std::string line;
    int row = 0;
    while (std::getline(file, line)) {
        if (line.empty()) continue;  // skip blank lines
        if (row++ == 0) continue;  // skip first row

        std::istringstream ss(line);
        std::string token;
        TimePrice tp;

        // Read timestamp_ns
        if (!std::getline(ss, token, ',')) continue;
        try {
            tp.timestampNs = std::stoll(token);
        } catch (...) {
            std::cerr << "Invalid timestamp in CSV: " << token << std::endl;
            continue;
        }

        // Read price_ns
        if (!std::getline(ss, token, ',')) continue;
        try {
            tp.price = std::stod(token);
        } catch (...) {
            std::cerr << "Invalid price in CSV: " << token << std::endl;
            continue;
        }

        data.push_back(tp);
    }
    file.close();

    // If no data, exit
    if (data.empty()) {
        std::cerr << "No valid data found in the CSV.\n";
        return 1;
    }

    // Ensure ascending order by timestamp
    std::sort(data.begin(), data.end(),
              [](const TimePrice& a, const TimePrice& b) {
                  return a.timestampNs < b.timestampNs;
              });

    // Window size for SMA
    const int window = 20;

    // We'll track 'simulatedTimestamp' in nanoseconds
    // Start it at the earliest data timestamp
    long long simulatedTimestamp = data.front().timestampNs;

    // Vector of observed prices (used for the SMA calculation)
    std::vector<double> observedPrices;
    observedPrices.reserve(data.size());

    // We'll do the largest time for the data
    int maxDataTime = 6758663;

    // We'll measure the real time each iteration takes
    auto prevTime = std::chrono::high_resolution_clock::now();
    auto totalTime = 0;
    int iter = 0;
    do {
        iter++;
        // Measure how many ns have elapsed since last iteration
        auto currentTime = std::chrono::high_resolution_clock::now();
        auto elapsedNs = std::chrono::duration_cast<std::chrono::nanoseconds>(currentTime - prevTime).count();
        prevTime = currentTime;

        // Add that elapsed time to our simulated time
        simulatedTimestamp += elapsedNs;
        totalTime = simulatedTimestamp >> 10;

        // Find the price whose timestamp is closest to our current simulated timestamp
        int idx = findClosestIndex(data,totalTime);
        if (idx < 0) {
            std::cerr << "No data found (unexpected).\n";
            continue;
        }
        double currentPrice = data[idx].price;

        // Push into 'observedPrices'
        observedPrices.push_back(currentPrice);

        // Compute SMA over observedPrices
        int i = static_cast<int>(observedPrices.size()) - 1;
        double sma = calculateSMA(observedPrices, i, window);

        // Print out the result
        std::cout << "[Iteration " << iter << "] "
                  << " TradeTimeElapsedNs=" << elapsedNs 
                  << " | TotaltimeNs=" << simulatedTimestamp 
                  << " | Price=" << currentPrice
                  << " | SMA=" << sma << " => ";
        
        // rounding if needed
        // auto roundTo3 = [](double x) {
        //     return std::round(x * 1000.0) / 1000.0;
        // };
        // double p = roundTo3(currentPrice);
        // double m = roundTo3(sma);
        // if (std::fabs(p - m) < 1e-9) {
        //     std::cout << "Hold\n";
        // } else if (currentPrice > sma) {
        //     std::cout << "Buy\n";
        // } else if (currentPrice < sma) {
        //     std::cout << "Sell\n";
        // }

        if (currentPrice > sma) {
            std::cout << "Buy\n";
        } else if (currentPrice < sma) {
            std::cout << "Sell\n";
        } else if (currentPrice = sma){
            std::cout << "Hold\n";
        }
        std::cout << std::endl;
    } while (totalTime < maxDataTime);

    return 0;
}
