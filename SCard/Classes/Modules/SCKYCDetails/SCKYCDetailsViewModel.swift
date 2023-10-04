final class SCKYCDetailsViewModel {

    static let requiredAmountOfEuro = 100
    static let minAmountOfEuroProcentage: Float = 0.95

    var onBalanceUpdate: ((Float, String, Bool, String) -> Void)?
    var onIssueCardForFree: (() -> Void)?
    var onIssueCard: (() -> Void)?
    var onSwapXor: (() -> Void)?
    var onGetXorWithFiat: (() -> Void)?
    var onUnsupportedCountries: (() -> Void)?

    private let data: SCKYCUserDataModel

    private let service: SCKYCService
    private let balanceStream: SCStream<Decimal>
    private var xorPriceInEuro: Float?
    private var kycAttempts: SCKYCAtempts?

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
            guard let self = self else { return }
            await self.service.updateFees()
            switch await self.service.kycAttempts() {
            case .failure(_): ()
            case .success(let kycAttempts):
                self.kycAttempts = kycAttempts
            }

            await self.fetchFiat()
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
        let isKYCFree = self.kycAttempts?.hasFreeAttempts ?? true // TODO: SC fix logic on Phase 2
        let haveEnoughXor = percentage >= Self.minAmountOfEuroProcentage

        data.haveEnoughXor = haveEnoughXor

        if isKYCFree {
            if haveEnoughXor {
                balanceText = R.string.soraCard.detailsEnoughXorDesription(preferredLanguages: .currentLocale)
            } else {
                balanceText = R.string.soraCard.detailsNeedXorDesription(
                    xorBalanceLeftText,
                    fiatBalanceLeftText,
                    preferredLanguages: .currentLocale
                )
            }
        } else {
            balanceText = R.string.soraCard.detailsAlreadyUsedFreeTry(preferredLanguages: .currentLocale)
        }

        DispatchQueue.main.async  {
            self.onBalanceUpdate?(
                haveEnoughXor ? 1 : percentage,
                balanceText,
                isKYCFree,
                self.service.applicationFeeCach
            )
        }
    }
}
