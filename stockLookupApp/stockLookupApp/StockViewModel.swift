import Foundation
import Combine

class StockViewModel: ObservableObject {
    @Published var stockSymbol: String = ""
    @Published var companyName: String = ""
    @Published var currentPrice: Double?
    @Published var priceChange: Double?
    @Published var percentChange: Double?
    @Published var isLoading: Bool = false
    @Published var hasError: Bool = false
    @Published var errorMessage: String?

    private let apiKey = "042e799f55msh76dcf4182b36b9ep1cb2f9jsn7691ad93d01b"
    

    // Define cancellables to store subscriptions
    var cancellables = Set<AnyCancellable>()

    func fetchStockData() {
        self.companyName = ""
        self.currentPrice = nil
        self.priceChange = nil
        self.percentChange = nil
        self.errorMessage = nil
        self.isLoading = true
        self.hasError = false
        
        let symbol = stockSymbol.uppercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !symbol.isEmpty else {
            self.errorMessage = "Please enter a stock symbol."
            self.hasError = true
            self.isLoading = false
            return
        }
        
        let dispatchGroup = DispatchGroup()
        var fetchedQuote: StockQuote?
        var fetchedCompany: CompanyProfile?
        
        dispatchGroup.enter()
        fetchQuote(for: symbol) { result in
            switch result {
            case .success(let quote):
                fetchedQuote = quote
            case .failure(let error):
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.hasError = true
                }
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        fetchCompany(for: symbol) { result in
            switch result {
            case .success(let company):
                fetchedCompany = company
            case .failure(let error):
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.hasError = true
                }
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            self.isLoading = false
            if self.hasError {
                return
            }
            if let quote = fetchedQuote, let company = fetchedCompany {
                self.companyName = company.name ?? symbol
                self.currentPrice = quote.currentPrice
                let change = quote.currentPrice - quote.previousClose
                self.priceChange = change
                self.percentChange = quote.previousClose != 0 ? (change / quote.previousClose) * 100 : 0
            } else {
                self.errorMessage = "Failed to fetch data."
                self.hasError = true
            }
        }
    }
    
    private func fetchQuote(for symbol: String, completion: @escaping (Result<StockQuote, Error>) -> Void) {
        let urlString = "https://finnhub.io/api/v1/quote?symbol=\(symbol)&token=\(apiKey)"
        guard let url = URL(string: urlString) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(APIError.noData))
                return
            }
            do {
                let quote = try JSONDecoder().decode(StockQuote.self, from: data)
                completion(.success(quote))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    private func fetchCompany(for symbol: String, completion: @escaping (Result<CompanyProfile, Error>) -> Void) {
        let urlString = "https://finnhub.io/api/v1/stock/profile2?symbol=\(symbol)&token=\(apiKey)"
        guard let url = URL(string: urlString) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(APIError.noData))
                return
            }
            do {
                let company = try JSONDecoder().decode(CompanyProfile.self, from: data)
                completion(.success(company))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    enum APIError: Error, LocalizedError {
        case invalidURL
        case noData
        case invalidSymbol
        
        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid URL."
            case .noData:
                return "No data received."
            case .invalidSymbol:
                return "Invalid stock symbol."
            }
        }
    }
}

