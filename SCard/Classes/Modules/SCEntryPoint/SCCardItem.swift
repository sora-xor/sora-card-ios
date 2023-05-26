import SoraUIKit

public final class SCCardItem: NSObject {

    var onClose: (() -> Void)?
    var onCard: (() -> Void)?
    let userStatusStream: AsyncStream<SCKYCUserStatus>

    public init(
        service: SCard,
        onClose: (() -> Void)?,
        onCard: (() -> Void)?
    ) {
        self.onClose = onClose
        self.onCard = onCard
        self.userStatusStream = service.userStatusStream
        self.service = service
    }

    private let service: SCard
}

extension SCCardItem: SoramitsuTableViewItemProtocol {
    public var cellType: AnyClass { SCCardCell.self }
    public var clipsToBounds: Bool { false }
}
