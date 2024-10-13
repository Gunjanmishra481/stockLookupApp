//
//  StockQuote.swift
//  stockLookupApp
//
//  Created by Gunjan Mishra on 13/10/24.
//
import Foundation

struct StockQuote: Codable {
    let c: Double? // Current price
    let pc: Double? // Previous close price
    
    enum CodingKeys: String, CodingKey {
        case c
        case pc
    }
    
    var currentPrice: Double {
        return c ?? 0.0
    }
    
    var previousClose: Double {
        return pc ?? 0.0
    }
}

