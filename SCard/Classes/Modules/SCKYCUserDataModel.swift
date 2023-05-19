import Foundation

final class SCKYCUserDataModel {
    
    var name = ""
    var lastname = ""
    var phoneNumber = ""
    var email = ""

    var lastPhoneOTPSentDate = Date()
    var lastEmailOTPSentDate = Date()
    var otpLength = 6

    var referenceId = ""
    var referenceNumber = ""
    var userId = ""
    var kycId = ""

    var haveEnoughXor = false
}
