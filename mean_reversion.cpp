#include <iostream>
#include <fstream>
#include <sstream>
#include <vector>
#include <string>

// Function to calculate the Simple Moving Average (SMA) over a window.
// For indices with fewer than 'window' points, use the average of available data.
double calculateSMA(const std::vector<double>& prices, int index, int window) {
    int start = (index - window + 1) < 0 ? 0 : (index - window + 1);
    double sum = 0.0;
    int count = 0;
    for (int i = start; i <= index; ++i) {
        sum += prices[i];
        ++count;
    }
    return sum / count;
}

int main() {
    std::ifstream file("data.csv");
    if (!file.is_open()) {
        std::cerr << "Error opening the file!" << std::endl;
        return 1;
    }

    std::string line;
    int skipRows = 3; // Number of initial rows to skip (non-data rows)
    for (int i = 0; i < skipRows && std::getline(file, line); ++i) {
        // Skipping first three rows
    }

    std::vector<double> closePrices;
    // Read CSV lines and extract the "Close" price (assumed to be the 5th column)
    while (std::getline(file, line)) {
        std::istringstream ss(line);
        std::string token;
        int columnIndex = 0;
        double closePrice = 0.0;
        // Assuming columns: Date,Open,High,Low,Close,Volume,...
        while (std::getline(ss, token, ',')) {
            // Trim whitespace from token
            token.erase(0, token.find_first_not_of(" \t\r\n"));
            token.erase(token.find_last_not_of(" \t\r\n") + 1);
            if (columnIndex == 4) {  // 5th column is "Close"
                try {
                    closePrice = std::stod(token);
                } catch (const std::invalid_argument& e) {
                    std::cerr << "Invalid number in CSV: " << token << std::endl;
                    closePrice = 0.0;
                }
                break;  // Found the close price; no need to parse further tokens.
            }
            ++columnIndex;
        }
        closePrices.push_back(closePrice);
    }
    file.close();

    // Set the window size for the SMA calculation.
    const int window = 20;

    // Generate signals for each data point using an expanding SMA
    // For each index, if price > SMA, then signal a "Buy", if price < SMA, signal a "Sell", otherwise "Hold".
    for (size_t i = 0; i < closePrices.size(); ++i) {
        double sma = calculateSMA(closePrices, i, window);
        double currentPrice = closePrices[i];

        std::cout << "Index " << i 
                  << " | Price: " << currentPrice 
                  << " | SMA: " << sma << " => ";

        if (currentPrice > sma) {
            std::cout << "Buy signal";
        } else if (currentPrice < sma) {
            std::cout << "Sell signal";
        } else {
            std::cout << "Hold";
        }
        std::cout << std::endl;
    }

    return 0;
}
