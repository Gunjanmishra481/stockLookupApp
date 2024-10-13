//
//  ContentView.swift
//  stockLookupApp
//
//  Created by Gunjan Mishra on 13/10/24.
//


import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = StockViewModel()
    
    var body: some View {
        VStack {
            TextField("Enter stock symbol (e.g., AAPL)", text: $viewModel.stockSymbol)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button(action: {
                self.viewModel.fetchStockData()
            }) {
                Text("Search")
                    .font(.headline)
            }
            .padding()
            
            if viewModel.isLoading {
                ProgressView("Loading...")
                    .padding()
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            } else if let currentPrice = viewModel.currentPrice,
                      let priceChange = viewModel.priceChange,
                      let percentChange = viewModel.percentChange {
                VStack(alignment: .leading, spacing: 10) {
                    Text(viewModel.companyName)
                        .font(.title)
                        .padding(.top)
                    Text("Current Price: $\(String(format: "%.2f", currentPrice))")
                    Text("Change: $\(String(format: "%.2f", priceChange)) (\(String(format: "%.2f", percentChange))%)")
                        .foregroundColor(priceChange >= 0 ? .green : .red)
                }
                .padding()
            }
            Spacer()
        }
        .padding()
    }
}
