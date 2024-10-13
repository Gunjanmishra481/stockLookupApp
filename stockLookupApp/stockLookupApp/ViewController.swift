//
//  ViewController.swift
//  stockLookupApp
//
//  Created by Gunjan Mishra on 13/10/24.
//

import UIKit
import Combine

class ViewController: UIViewController {
    
    @IBOutlet weak var stockSymbolTextField: UITextField!
    @IBOutlet weak var stockInfoLabel: UILabel!
    
    private var viewModel = StockViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Bind ViewModel properties to update the UI
        bindViewModel()
    }
    
    // Action when the user presses the search button
    @IBAction func searchStock(_ sender: UIButton) {
        guard let symbol = stockSymbolTextField.text, !symbol.isEmpty else {
            stockInfoLabel.text = "Please enter a stock symbol"
            return
        }
        
        // Fetch stock info via the ViewModel
        viewModel.fetchStockInfo(for: symbol)
    }
    
    // Bind ViewModel properties to update the UI when data changes
    private func bindViewModel() {
        // Combine the ViewModel's published properties into one subscription
        viewModel.$stockSymbol
            .combineLatest(viewModel.$stockName, viewModel.$stockExchange, viewModel.$errorMessage)
            .sink { [weak self] (symbol, name, exchange, errorMessage) in
                if !errorMessage.isEmpty {
                    self?.stockInfoLabel.text = errorMessage
                } else {
                    self?.stockInfoLabel.text = """
                    Symbol: \(symbol)
                    Name: \(name)
                    Exchange: \(exchange)
                    """
                }
            }
            .store(in: &cancellables)
    }
}



