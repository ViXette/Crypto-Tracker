//
//  Created by ViXette on 23/06/2018.
//

import Foundation


extension Double {
	
	var usd: String {
		let numberFormater = NumberFormatter()
		numberFormater.locale = Locale(identifier: "en_US")
		numberFormater.numberStyle = .currency
		
		if let _price = numberFormater.string(from: NSNumber(floatLiteral: self)) {
			return _price
		} else {
			return "Error!"
		}
	}
}
