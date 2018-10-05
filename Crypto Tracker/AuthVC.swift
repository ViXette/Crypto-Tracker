//
//  Created by ViXette on 23/07/2018.
//

import UIKit
import LocalAuthentication

///
class AuthVC: UIViewController {
	
	///
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.presentAuth()
	}
	
	///
	func presentAuth () {
		LAContext().evaluatePolicy(
			.deviceOwnerAuthenticationWithBiometrics,
			localizedReason: "Your Crypto is protected by biometrics") {
				success, error in
				
				if success {
					DispatchQueue.main.async {
						let cryptoTableVC = CryptoTableVC()
						cryptoTableVC.title = "Crypto"
						
						let navController = UINavigationController(rootViewController: cryptoTableVC)
						
						self.present(navController, animated: true, completion: nil)
					}
				} else {
					self.presentAuth()
				}
		}
	}
	
}
