//
//  ViewController.swift
//  stockLookupApp
//
//  Created by Gunjan Mishra on 13/10/24.
//

import UIKit

class StockViewController: UIViewController {

    // MARK: - UI Elements
    private let stockSymbolTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter stock symbol (e.g., AAPL)"
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private let searchButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Search", for: .normal)
        return button
    }()
    
    private let companyNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let currentPriceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .regular)
        label.textAlignment = .center
        return label
    }()
    
    private let changeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.textAlignment = .center
        return label
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private let errorMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .red
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    // ViewModel to manage data fetching and business logic
    private let viewModel = StockViewModel()

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupUI()
        setupActions()
        bindViewModel()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.addSubview(stockSymbolTextField)
        view.addSubview(searchButton)
        view.addSubview(companyNameLabel)
        view.addSubview(currentPriceLabel)
        view.addSubview(changeLabel)
        view.addSubview(activityIndicator)
        view.addSubview(errorMessageLabel)
        
        stockSymbolTextField.translatesAutoresizingMaskIntoConstraints = false
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        companyNameLabel.translatesAutoresizingMaskIntoConstraints = false
        currentPriceLabel.translatesAutoresizingMaskIntoConstraints = false
        changeLabel.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        errorMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stockSymbolTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stockSymbolTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stockSymbolTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            searchButton.topAnchor.constraint(equalTo: stockSymbolTextField.bottomAnchor, constant: 20),
            searchButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            companyNameLabel.topAnchor.constraint(equalTo: searchButton.bottomAnchor, constant: 40),
            companyNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            companyNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            currentPriceLabel.topAnchor.constraint(equalTo: companyNameLabel.bottomAnchor, constant: 20),
            currentPriceLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            currentPriceLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            changeLabel.topAnchor.constraint(equalTo: currentPriceLabel.bottomAnchor, constant: 20),
            changeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            changeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            errorMessageLabel.topAnchor.constraint(equalTo: changeLabel.bottomAnchor, constant: 20),
            errorMessageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            errorMessageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
    
    // MARK: - Setup Actions
    private func setupActions() {
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - ViewModel Binding
    private func bindViewModel() {
        viewModel.$companyName.sink { [weak self] name in
            self?.companyNameLabel.text = name
        }.store(in: &viewModel.cancellables)
        
        viewModel.$currentPrice.sink { [weak self] price in
            if let price = price {
                self?.currentPriceLabel.text = "Current Price: $\(String(format: "%.2f", price))"
            }
        }.store(in: &viewModel.cancellables)
        
        viewModel.$priceChange.sink { [weak self] change in
            if let change = change, let percentChange = self?.viewModel.percentChange {
                self?.changeLabel.text = "Change: $\(String(format: "%.2f", change)) (\(String(format: "%.2f", percentChange))%)"
                self?.changeLabel.textColor = change >= 0 ? .green : .red
            }
        }.store(in: &viewModel.cancellables)
        
        viewModel.$isLoading.sink { [weak self] isLoading in
            if isLoading {
                self?.activityIndicator.startAnimating()
            } else {
                self?.activityIndicator.stopAnimating()
            }
        }.store(in: &viewModel.cancellables)
        
        viewModel.$hasError.sink { [weak self] hasError in
            self?.errorMessageLabel.isHidden = !hasError
            if hasError {
                self?.errorMessageLabel.text = self?.viewModel.errorMessage
            }
        }.store(in: &viewModel.cancellables)
    }
    
    // MARK: - Action Handlers
    @objc private func searchButtonTapped() {
        viewModel.stockSymbol = stockSymbolTextField.text ?? ""
        viewModel.fetchStockData()
    }
}


