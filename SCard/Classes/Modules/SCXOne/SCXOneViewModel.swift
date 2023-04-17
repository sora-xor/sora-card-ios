import Foundation

public final class SCXOneViewModel {
    var onDone: (() -> Void)?

    public init(address: String, service: SCKYCService) {
        self.address = address
        self.service = service
    }

    func checkStatus() {

        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] (timer) in
            guard let self = self else { return }
            Task {
                let result = await self.service.xOneStatus(paymentId: self.paymentId)
                switch result {
                case .failure(let error):
                    print(error)

                case .success(let response):
                    if response.userStatus == .successful {
                        self.onDone?()
                    } else {
                        self.checkStatus()
                    }
                }
            }
        }
    }

    var xOneHtmlString: String {
        """
        <!DOCTYPE html>
        <html lang="en">

        <head>
          <meta name="description" content="" />
          <meta charset="utf-8">
          <title>x1ex</title>
          <meta name="viewport" content="width=device-width, initial-scale=1">
          <meta name="author" content="">
          <link rel="stylesheet" href="css/style.css">
        </head>

        <body>
        <div
            id="sprkwdgt-WYL6QBNC"
            data-from-currency="EUR"

            data-from-amount="\(SCKYCDetailsViewModel.requiredAmountOfEuro)"
            data-hide-buy-more-button="true"
            data-hide-try-again-button="false"
            data-locale="en"
            data-payload="\(paymentId)"
            data-address="\(address)"
        ></div>
        <script async src="https://dev.x1ex.com/widgets/sdk.js"></script>

        </body>
        </html>
        """
// prod
//        id="sprkwdgt-WUQBA5U2"
//        <script async src="https://x1ex.com/widgets/sdk.js"></script>
    }

    private let service: SCKYCService

    private let paymentId = UUID().uuidString
    private let address: String
}
