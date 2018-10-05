//
//  Created by ViXette on 19/06/2018.
//

import UIKit
import LocalAuthentication


private let headerHeight: CGFloat = 100.0
private let netWorthHeight: CGFloat = 45.0


///
class CryptoTableVC: UITableViewController {

	let amountLabel = UILabel()
	
	///
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.view.backgroundColor = #colorLiteral(red: 0.2039215686, green: 0.5960784314, blue: 0.8470588235, alpha: 1)
		
		CoinData.shared.delegate = self
		
		navigationItem.leftBarButtonItem = UIBarButtonItem(title: "PDF", style: .plain, target: self, action: #selector(pdfTapped))
		
		if LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
			updateSecureButton()
		}
	}
	
	///
	override func viewWillAppear(_ animated: Bool) {
		CoinData.shared.delegate = self
		
		self.displayNetWorth()
		
		tableView.reloadData()
	}
	
	///
	func updateSecureButton () {
		let title = UserDefaults.standard.bool(forKey: "Secure") ? "Unsecure App" : "Secure App"
		
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(secureTapped))
	}
	
	///
	@objc func secureTapped () {
		UserDefaults.standard.set(!UserDefaults.standard.bool(forKey: "Secure"), forKey: "Secure")
		
		self.updateSecureButton()
	}
	
	///
	@objc func pdfTapped () {
		let formatter = UIMarkupTextPrintFormatter(markupText: CoinData.shared.html())
		
		let renderer = UIPrintPageRenderer()
		
		renderer.addPrintFormatter(formatter, startingAtPageAt: 0)
		
		let page = CGRect(x: 0, y: 0, width: 595.2, height: 841.8)
		
		renderer.setValue(page, forKey: "paperRect")
		renderer.setValue(page, forKey: "printableRect")
		
		let pdfData = NSMutableData()
		
		UIGraphicsBeginPDFContextToData(pdfData, .zero, nil)
		
		for i in 0 ..< renderer.numberOfPages {
			UIGraphicsBeginPDFPage()
			
			renderer.drawPage(at: i, in: UIGraphicsGetPDFContextBounds())
		}
		
		UIGraphicsEndPDFContext()
		
		let shareVC = UIActivityViewController(activityItems: [pdfData], applicationActivities: nil)
		
		present(shareVC, animated: true, completion: nil)
	}
	
	///
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return CoinData.shared.coins.count
	}
	
	///
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = UITableViewCell()

		let coin = CoinData.shared.coins[indexPath.row]

		cell.textLabel?.text = coin.symbol + " - \(coin.priceFormated) \(coin.amount > 0.0 ? "- \(coin.amount)": "")"
		cell.imageView?.image = coin.image

		return cell
	}
	
	///
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let coinVC = CoinVC()
		coinVC.coin = CoinData.shared.coins[indexPath.row]
		
		navigationController?.pushViewController(coinVC, animated: true)
	}
	
	///
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return headerHeight
	}
	
	///
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		return self.createHeaderView()
	}
	
	///
	func createHeaderView () -> UIView {
		let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: headerHeight))
		headerView.backgroundColor = UIColor.white

		let netWorthLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: netWorthHeight))
		netWorthLabel.text = "My Crypto Net Worth:"
		netWorthLabel.textAlignment = .center

		headerView.addSubview(netWorthLabel)

		amountLabel.frame = CGRect(x: 0, y: netWorthHeight, width: view.frame.width, height: headerHeight - netWorthHeight)
		amountLabel.textAlignment = .center
		amountLabel.font = UIFont.boldSystemFont(ofSize: 60.0)

		headerView.addSubview(amountLabel)

		self.displayNetWorth()
		
		return headerView
	}

	///
	func displayNetWorth () {
		amountLabel.text = CoinData.shared.calcNetWorth()
	}
	
}


///
extension CryptoTableVC: CoinDataDelegate {
	
	///
	func pricesFetched() {
		self.displayNetWorth()
		
		tableView.reloadData()
	}

}
