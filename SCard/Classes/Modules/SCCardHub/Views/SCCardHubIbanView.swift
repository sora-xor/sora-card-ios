import UIKit
import SoraUIKit

final class SCCardHubIbanView: SoramitsuView {

    var onIbanShare: ((String) -> Void)?
    var onIbanCopy: ((String) -> Void)?

    private let titleLabel: SoramitsuLabel = {
        let label = SoramitsuLabel()
        label.sora.font = FontType.headline2
        label.sora.textColor = .fgPrimary
        label.sora.numberOfLines = 0
        label.sora.text = R.string.soraCard.cardhubIbanTitle(preferredLanguages: .currentLocale)
        return label
    }()

    private lazy var subtitleLabel: SoramitsuLabel = {
        let label = SoramitsuLabel()
        label.sora.font = FontType.textM
        label.sora.textColor = .fgPrimary
        label.sora.numberOfLines = 0
        label.sora.text = ""
        label.isUserInteractionEnabled = true
        label.addTapGesture { [weak self] _ in
            self?.onIbanCopy?(self?.subtitleLabel.sora.text ?? "")
        }
        return label
    }()

    private lazy var shareButton: SoramitsuButton = {
        let button = SoramitsuButton(size: .large, type: .bleached(.tertiary))
        button.sora.tintColor = .accentTertiary
        button.sora.backgroundColor = .custom(uiColor: .clear)
        button.sora.leftImage = R.image.upload()
        button.sora.addHandler(for: .touchUpInside) { [weak self] in
            self?.onIbanShare?(self?.subtitleLabel.sora.text ?? "")
        }
        return button
    }()

    convenience init() {
        self.init(frame: .zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = false
        self.sora.backgroundColor = .bgSurface
        self.sora.shadow = .default
        self.sora.cornerRadius = .max
        setupInitialLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(iban: String?) {
        subtitleLabel.sora.text = iban
    }

    private func setupInitialLayout() {

        addSubview(titleLabel) {
            $0.top.leading.equalToSuperview().inset(24)
        }

        addSubview(shareButton) {
            $0.top.trailing.equalToSuperview().inset(24)
            $0.leading.equalTo(titleLabel.snp.trailing).offset(16)
            $0.size.equalTo(32)
        }

        addSubview(subtitleLabel) {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.bottom.leading.trailing.equalToSuperview().inset(24)
        }
    }
}
