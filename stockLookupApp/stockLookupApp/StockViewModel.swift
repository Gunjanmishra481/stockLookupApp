import Foundation

class StockViewModel: ObservableObject {
    
    @Published var stockSymbol: String = ""
    @Published var stockName: String = ""
    @Published var stockExchange: String = ""
    @Published var errorMessage: String = ""
    
    private let rapidAPIKey = "042e799f55msh76dcf4182b36b9ep1cb2f9jsn7691ad93d01b"  // Replace with your API key
    
    // Function to fetch stock info using the Yahoo Finance Autocomplete API
    func fetchStockInfo(for symbol: String) {
        let headers = [
            "x-rapidapi-key": rapidAPIKey,
            "x-rapidapi-host": "yahoo-finance166.p.rapidapi.com"
        ]
        
        let urlString = "https://yahoo-finance166.p.rapidapi.com/api/autocomplete?query=\(symbol)"
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                self.errorMessage = "Invalid URL"
            }
            return
        }
        
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Error: \(error.localizedDescription)"
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    self.errorMessage = "Server error"
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "No data received"
                    return
                }
                
                // Parse the JSON data
                self.parseStockData(data: data)
            }
        }
        
        dataTask.resume()
    }
    
    // Function to parse the JSON data and extract relevant stock info
    private func parseStockData(data: Data) {
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                if let quotes = json["quotes"] as? [[String: Any]], let firstQuote = quotes.first {
                    self.stockSymbol = firstQuote["symbol"] as? String ?? "N/A"
                    self.stockName = firstQuote["shortname"] as? String ?? "N/A"
                    self.stockExchange = firstQuote["exchDisp"] as? String ?? "N/A"
                    self.errorMessage = ""
                } else {
                    self.errorMessage = "No stock information found."
                }
            } else {
                self.errorMessage = "Invalid response format"
            }
        } catch {
            self.errorMessage = "Failed to parse data"
        }
    }
}
