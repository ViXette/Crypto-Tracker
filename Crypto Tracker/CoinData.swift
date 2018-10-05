//
//  Created by ViXette on 19/06/2018.
//

import UIKit
import Alamofire


@objc protocol CoinDataDelegate: class {
	
	@objc optional func pricesFetched ()
	
	@objc optional func historicalDataFetched ()

}

///
class CoinData {

	static let shared = CoinData()
	
	var coins = [Coin]()
	
	weak var delegate: CoinDataDelegate?
	
	private init () {
		let symbols = ["BTC", "ETH", "LTC"]

		for symbol in symbols {
			coins.append(Coin(symbol: symbol))
		}
		
		getPrices()
	}
	
	///
	func getPrices () {
		var listOfSymbols = ""
		
		for coin in coins {
			listOfSymbols += coin.symbol + ","
		}
		listOfSymbols = String(listOfSymbols.dropLast())
		
		Alamofire.request("https://min-api.cryptocompare.com/data/pricemulti?fsyms=\(listOfSymbols)&tsyms=USD")
			.responseJSON { (response) in
				if let json = response.result.value as? [String:Any] {
					for coin in self.coins {
						if let _coin = json[coin.symbol] as? [String:Double] {
							if let price = _coin["USD"] {
								coin.price = price
								
								UserDefaults.standard.set(price, forKey: coin.symbol)
							}
						}
					}
					
					self.delegate?.pricesFetched?()
				}
			}
	}

	///
	func calcNetWorth () -> String {
		var netWorth = 0.0

		for coin in self.coins {
			netWorth += coin.amount * coin.price
		}

		return netWorth.usd
	}
	
	///
	func html () -> String {
		var html = "<h1>My Crypto Report</h1>"
		
		html += "<h2>\(calcNetWorth())</h2>"
		html += "<ul>"
		for coin in coins {
			if coin.amount > 0 {
				html += "<li>\(coin.symbol) : \(coin.amount) - \((coin.amount * coin.price).usd)</li>"
			}
		}
		html += "</ul>"
		
		return html
	}
	
}

///
class Coin {
	
	var symbol = ""
	
	var image = UIImage()
	
	var price = 0.0
	
	var priceFormated: String {
		if price == 0.0 {
			return "... loading"
		}
		
		return price.usd
	}
	
	var amount = 0.0
	
	var historicalData = [Double]()
	
	//weak var delegate: CoinDataDelegate?

	init (symbol: String) {
		self.symbol = symbol

		if let image = UIImage(named: symbol) {
			self.image = image
		}
		
		self.price = UserDefaults.standard.double(forKey: self.symbol)
		self.amount = UserDefaults.standard.double(forKey: self.symbol + "_amount")
		if let history = UserDefaults.standard.array(forKey: self.symbol + "_history") as? [Double] {
			self.historicalData = history
		}
	}
	
	///
	func getHistoricalData () {
		Alamofire.request("https://min-api.cryptocompare.com/data/histoday?fsym=\(symbol)&tsym=USD&limit=30")
			.responseJSON { (response) in
				if let json = response.result.value as? [String:Any] {
					if let pricesJSON = json["Data"] as? [[String:Any]] {
						self.historicalData = []
						
						for priceJSON in pricesJSON {
							if let price = priceJSON["close"] as? Double {
								self.historicalData.append(price)
							}
						}
						
						CoinData.shared.delegate?.historicalDataFetched!()
						
						UserDefaults.standard.set(self.historicalData, forKey: self.symbol + "_history")
					}
				}
			}
	}
	
}
