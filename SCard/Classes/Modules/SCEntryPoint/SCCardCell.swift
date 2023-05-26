import SoraUIKit
import SnapKit

public final class SCCardCell: SoramitsuTableViewCell {

    var onClose: (() -> Void)?
    var onCard: (() -> Void)?

    private var userStatusUpdateTask: Task<(), Never>?

    private lazy var bgImage: SoramitsuImageView = {
        let view = SoramitsuImageView()
        view.sora.picture = .logo(image: R.image.scFront()!)
        view.sora.isUserInteractionEnabled = true
        view.addTapGesture { [unowned self] _ in
            self.onCard?()
        }
        return view
    }()

    private lazy var closeButton: ImageButton = {
        let button = ImageButton(size: .init(width: 32, height: 32))
        button.setImage(R.image.close(), for: .normal)
        button.sora.addHandler(for: .touchUpInside) { [unowned self] in
            self.onClose?()
        }
        button.sora.backgroundColor = .bgSurface
        button.sora.cornerRadius = .circle
        return button
    }()

    private lazy var getCardContainer: SoramitsuView = {
        let view = SoramitsuView()
        view.sora.cornerRadius = .custom(24)
        view.sora.backgroundColor = .accentSecondary
        return view
    }()

    private lazy var getCardLabel: SoramitsuLabel = {
        let view = SoramitsuLabel()
        view.sora.text = SCKYCUserStatus.notStarted.text
        view.sora.textColor = .bgSurface
        view.sora.alignment = .center

        return view
    }()


    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupConstraints()

        let localizableTitle = { (locale: Locale) in
            R.string.soraCard.statusNotStarted(preferredLanguages: locale.rLanguages)
        }

        LocalizationManager.shared.addObserver(with: getCardLabel) { [weak getCardLabel] (_, _) in
            let currentTitle = localizableTitle(LocalizationManager.shared.selectedLocale)
            getCardLabel?.sora.text = currentTitle
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupConstraints() {
        let ratio = self.bgImage.image!.size.height / self.bgImage.image!.size.width
        contentView.addSubview(self.bgImage) {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.top.bottom.equalToSuperview().inset(8)
            $0.height.equalTo(self.bgImage.snp.width).multipliedBy(ratio)
        }

        bgImage.addSubview(self.closeButton) {
            $0.top.trailing.equalToSuperview().inset(10)
        }

        getCardContainer.addSubview(self.getCardLabel) {
            $0.top.bottom.equalToSuperview().inset(20)
            $0.leading.trailing.equalToSuperview().inset(30)
        }

        bgImage.addSubview(self.getCardContainer) {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(24)
            $0.width.lessThanOrEqualToSuperview().multipliedBy(0.90)
        }
    }
}

extension SCCardCell: SoramitsuTableViewCellProtocol {
    public func set(item: SoramitsuTableViewItemProtocol, context: SoramitsuTableViewContext?) {
        guard let item = item as? SCCardItem else { return }
        sora.backgroundColor = .custom(uiColor: .clear)
        self.onClose = item.onClose
        self.onCard = item.onCard

        self.userStatusUpdateTask?.cancel()

        self.userStatusUpdateTask = Task { [weak self] in
            for await userStatus in item.userStatusStream {
              await MainActor.run { [weak self] in
                  self?.update(status: userStatus)
              }
            }
        }
    }

    private func update(status: SCKYCUserStatus) {
        self.closeButton.isHidden = status == .successful
        self.getCardContainer.isHidden = status == .successful
        self.getCardLabel.sora.text = status.text
        self.getCardLabel.sora.textColor = (status == .notStarted || status == .userCanceled) ? .bgSurface : .accentTertiary
        self.getCardContainer.sora.backgroundColor = (status == .notStarted || status == .userCanceled) ? .accentSecondary : .accentTertiaryContainer
    }
}

extension SCKYCUserStatus {

    var text: String {
        switch self {
        case .notStarted, .userCanceled: // TODO: use See the details
            return R.string.soraCard.statusNotStarted(preferredLanguages: .currentLocale)
        case .pending:
            return R.string.soraCard.kycResultVerificationInProgress(preferredLanguages: .currentLocale)
        case .rejected:
            return R.string.soraCard.verificationRejectedTitle(preferredLanguages: .currentLocale)
        case .successful:
            return R.string.soraCard.verificationSuccessfulTitle(preferredLanguages: .currentLocale)
        }
    }
}