import SoraUIKit

public final class SCCardItem: NSObject {

    var onClose: (() -> Void)?
    var onCard: (() -> Void)?
    var onUpdate: ((SCKYCUserStatus, Int?) -> Void)?
    var userStatus: SCKYCUserStatus = .notStarted
    var availableBalance: Int?
    private let service: SCKYCService

    public init(
        service: SCard,
        onClose: (() -> Void)?,
        onCard: (() -> Void)?
    ) {
        self.onClose = onClose
        self.onCard = onCard
        self.service = service.service
        super.init()

        Task { [weak self] in
            for await userStatus in service.userStatusStream {
                self?.userStatus = userStatus
                await self?.updateBalance()
                await MainActor.run { [weak self] in
                    guard let self = self else { return }
                    self.onUpdate?(self.userStatus, self.availableBalance)
                }
            }
        }
    }

    private func updateBalance() async {
        switch await service.iban() {
        case .success(let ibanResponse):
            guard let availableBalance = ibanResponse.ibans?.first?.availableBalance else { return }
            self.availableBalance = availableBalance
            await MainActor.run { [weak self] in
                guard let self = self else { return }
                self.onUpdate?(self.userStatus, availableBalance)
            }
        case .failure(let error):
            print(error)
        }
    }
}

extension SCCardItem: SoramitsuTableViewItemProtocol {
    public var cellType: AnyClass { SCCardCell.self }
    public var clipsToBounds: Bool { false }
}
