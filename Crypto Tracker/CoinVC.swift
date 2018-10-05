//
//  Created by ViXette on 22/06/2018.
//

import UIKit
import SwiftChart


private let imageSize: CGFloat = 100.0
private let labelHeight: CGFloat = 25.0
private let marginVertical: CGFloat = 8.0


class CoinVC: UIViewController {
	
	var coin: Coin? = nil
	
	var chart = Chart()
	
	var priceLabel = UILabel()
	
	var youOwnLabel = UILabel()
	
	var worthLabel = UILabel()
	
	private var chartHeight: CGFloat = 0.0
	
	///
	override func viewDidLoad() {
		super.viewDidLoad()
		
		edgesForExtendedLayout = []
		view.backgroundColor = UIColor.white
		
		title = coin?.symbol
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editTapped))
		
		chartHeight = view.frame.height / 2
		
		chart.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: chartHeight)
		chart.yLabelsFormatter = { $1.usd }
		chart.xLabels = [0, 5, 10, 15, 20, 25, 30]
		chart.xLabelsFormatter = { String(30 - Int($1)) + "d" }
		view.addSubview(chart)
		
		let imageView = UIImageView(frame: CGRect(
			x: view.frame.width / 2 - imageSize / 2,
			y: chartHeight + marginVertical,
			width: imageSize,
			height: imageSize))
		imageView.image = coin?.image
		view.addSubview(imageView)
		
		priceLabel.frame = CGRect(
			x: 0,
			y: chartHeight + imageSize + marginVertical * 2,
			width: view.frame.width,
			height: labelHeight)
		priceLabel.textAlignment = .center
		view.addSubview(priceLabel)
		
		youOwnLabel.frame = CGRect(
			x: 0,
			y: chartHeight + imageSize + labelHeight + marginVertical * 3,
			width: view.frame.width,
			height: labelHeight)
		youOwnLabel.textAlignment = .center
		youOwnLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
		view.addSubview(youOwnLabel)
		
		worthLabel.frame = CGRect(
			x: 0,
			y: chartHeight + imageSize + labelHeight * 2 + marginVertical * 4,
			width: view.frame.width,
			height: labelHeight)
		worthLabel.textAlignment = .center
		worthLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
		view.addSubview(worthLabel)
		
		CoinData.shared.delegate = self
		
		coin?.getHistoricalData()
		
		setLabels()
	}
	
	///
	func setLabels () {
		if let coin = coin {
			priceLabel.text = coin.price.usd
			
			youOwnLabel.text = "You own: \(coin.amount) \(coin.symbol)"
			
			let worth = coin.amount * coin.price
			worthLabel.text = "Worth: \(worth.usd)"
		}
	}
	
	///
	@objc func editTapped () {
		if let coin = coin {
			let alert = UIAlertController(
				title: "How much \(coin.symbol) do you own?",
				message: nil,
				preferredStyle: .alert)
			
			alert.addTextField { (textField) in
				if coin.amount > 0.0 {
					textField.text = "\(coin.amount)"
				} else {
					textField.placeholder = "0.0"
				}
				
				textField.keyboardType = .decimalPad
			}
			
			alert.addAction(UIAlertAction(
				title: "OK",
				style: .default,
				handler: { (action) in
					if let text = alert.textFields?[0].text, let amount = Double(text) {
						self.coin?.amount = amount
						
						UserDefaults.standard.set(amount, forKey: coin.symbol + "_amount")
						
						self.setLabels()
					}
			}))
			
			self.present(alert, animated: true)
		}
	}
	
}

// MARK: - CoinDataDelegate
extension CoinVC: CoinDataDelegate {
	
	///
	func historicalDataFetched () {
		if let historicalData = coin?.historicalData {
			let series = ChartSeries(historicalData)
			series.area = true
			
			chart.add(series)
		}
	}
	
	///
	func pricesFetched () {
		setLabels()
	}
	
}
