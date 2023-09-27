import SoraUIKit

public final class SCCardItem: NSObject {

    var onClose: (() -> Void)?
    var onCard: (() -> Void)?
    var onUpdate: ((SCKYCUserStatus, Int?) -> Void)?
    var userStatus: SCKYCUserStatus = .notStarted
    var availableBalance: Int?

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
                await MainActor.run { [weak self] in
                    guard let self = self else { return }
                    self.onUpdate?(self.userStatus, self.availableBalance)
                }
            }
        }
        
        Task { [weak self] in

            switch await self?.service.iban() {
            case .success(let ibanResponse):
                guard let availableBalance = ibanResponse.ibans.first?.availableBalance else { return }
                self?.availableBalance = availableBalance
                await MainActor.run { [weak self] in
                    guard let self = self else { return }
                    self.onUpdate?(self.userStatus, availableBalance)
                }
            case .failure(let error):
                print(error)
            case .none:
                return
            }
        }
    }

    private let service: SCKYCService
}

extension SCCardItem: SoramitsuTableViewItemProtocol {
    public var cellType: AnyClass { SCCardCell.self }
    public var clipsToBounds: Bool { false }
}
