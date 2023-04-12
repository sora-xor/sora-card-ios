import Foundation
import UIKit
import SoraUIKit

protocol SCTermsConditionsViewModelProtocol {
    var onAccept: (() -> Void)? { get set }
    var onGeneralTerms: (() -> Void)? { get set }
    var onPrivacy: (() -> Void)? { get set }
}

final class SCTermsConditionsViewModel {

    var onBlacklistedCountries : (() -> Void)?
    var onGeneralTerms: (() -> Void)?
    var onPrivacy: (() -> Void)?
    var onAccept: (() -> Void)?
}

extension SCTermsConditionsViewModel: SCTermsConditionsViewModelProtocol {

}
