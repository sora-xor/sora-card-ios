final class SCKYCDetailsViewModel {

    static let requiredAmountOfEuro = 100
    static let minAmountOfEuroProcentage: Float = 0.95

    var onBalanceUpdate: ((Float, String, Bool, String) -> Void)?
    var onIssueCardForFree: (() -> Void)?
    var onIssueCard: (() -> Void)?
    var onReceiveXor: (() -> Void)?
    var onSwapXor: (() -> Void)?
    var onGetXorWithFiat: (() -> Void)?
    var onUnsupportedCountries: (() -> Void)?

    private let data: SCKYCUserDataModel

    private let service: SCKYCService
    private let balanceStream: SCStream<Decimal>
    private var xorPriceInEuro: Float?

    init(
        data: SCKYCUserDataModel,
        service: SCKYCService,
        balanceStream: SCStream<Decimal>
    ) {
        self.data = data
        self.service = service
        self.balanceStream = balanceStream
        getData()
    }

    func refreshBalanceStart() {
        // TODO: impl
    }

    func refreshBalanceStop() {
        // TODO: impl
    }

    private func getData() {
        Task { [weak self] in
            await self?.service.updateFees()
            await self?.fetchFiat()
        }
    }

    private func fetchFiat() async {

        if case .success(let priceResponse) = await service.xorPriceInEuro() {
            xorPriceInEuro = Float(priceResponse.price)
             try? await Task.sleep(nanoseconds: 1000000000)
            updateBalance(xorBalance: balanceStream.wrappedValue)
        } else {
            print("### fetchFiat error")
        }

        subscribeUpdateBalance()
    }

    private func subscribeUpdateBalance() {
        Task { [weak self, balanceStream] in
            for await balance in balanceStream.stream {
                await MainActor.run { [weak self] in
                    self?.updateBalance(xorBalance: balance)
                }
            }
        }
    }

    static func isEnoughXor(xorBalance: Decimal, service: SCKYCService) async -> Bool {

        let xorPriceInEuro: Double
        if case .success(let priceResponse) = await service.xorPriceInEuro() {
            xorPriceInEuro = Double(priceResponse.price) ?? .zero
        } else {
            print("### fetchFiat error")
            return false
        }

        let xorPriceInEuroDecimal = Decimal(xorPriceInEuro)
        let requiredAmountOfXORInEuro = Decimal(Self.requiredAmountOfEuro) // 95€
        let requiredAmountOfXOR = requiredAmountOfXORInEuro / xorPriceInEuroDecimal

        let fiatBalanceDecimal = xorBalance * xorPriceInEuroDecimal
        let percentage = (min(1, (fiatBalanceDecimal) / requiredAmountOfXORInEuro) as NSNumber).floatValue
        let haveEnoughXor = percentage >= Self.minAmountOfEuroProcentage

        return haveEnoughXor
    }

    private func updateBalance(xorBalance: Decimal) {
        guard let xorPriceInEuro = self.xorPriceInEuro else { return }

        let xorPriceInEuroDecimal = Decimal(Double(xorPriceInEuro))
        let requiredAmountOfXORInEuro = Decimal(Self.requiredAmountOfEuro) // 95€
        let requiredAmountOfXOR = requiredAmountOfXORInEuro / xorPriceInEuroDecimal

        let fiatBalanceDecimal = xorBalance * xorPriceInEuroDecimal
        let percentage = (min(1, (fiatBalanceDecimal) / requiredAmountOfXORInEuro) as NSNumber).floatValue
        let fiatBalanceLeftText = NumberFormatter.fiat.stringFromDecimal(requiredAmountOfXORInEuro - fiatBalanceDecimal) ?? ""
        let xorBalanceLeftText = NumberFormatter.polkaswapBalance.stringFromDecimal(requiredAmountOfXOR - xorBalance) ?? ""

        let balanceText: String
        let haveEnoughXor = percentage >= Self.minAmountOfEuroProcentage

        data.haveEnoughXor = haveEnoughXor

        if haveEnoughXor {
            balanceText = R.string.soraCard.detailsEnoughXorDesription(preferredLanguages: .currentLocale)
        } else {
            balanceText = R.string.soraCard.detailsNeedXorDesription(
                xorBalanceLeftText,
                fiatBalanceLeftText,
                preferredLanguages: .currentLocale
            )
        }

        DispatchQueue.main.async  {
            self.onBalanceUpdate?(
                haveEnoughXor ? 1 : percentage,
                balanceText,
                true,
                self.service.applicationFeeCache
            )
        }
    }
}
