import UIKit
import SoraUIKit

final class SCCardHubHeaderView: SoramitsuView {

    enum Action {
        case topUp
        case transfer
        case exchange
        case freeze
    }

    var onAction: ((Action) -> Void)?

    private let iconView: SoramitsuImageView = {
        let view = SoramitsuImageView()
        view.sora.picture = .logo(image: R.image.scFront()!)
        view.snp.makeConstraints {
            $0.width.equalTo(view.snp.height).multipliedBy(1.66)
        }
        return view
    }()

    private let titleLabel: SoramitsuLabel = {
        let label = SoramitsuLabel()
        label.sora.font = FontType.textS
        label.sora.textColor = .fgSecondary
        label.sora.alignment = .center
        label.sora.text = R.string.soraCard.cardhubComingSoon(preferredLanguages: .currentLocale)
        return label
    }()

    private let actionButtonsScrollView: SoramitsuScrollView = {
        let view = SoramitsuScrollView()
        view.alwaysBounceHorizontal = true
        view.contentMode = .center
        view.contentInset = .init(top: 0, left: 24, bottom: 0, right: 24)
        return view
    }()

    private let actionButtonsView: SoramitsuStackView = {
        var view = SoramitsuStackView()
        view.sora.backgroundColor = .custom(uiColor: .clear)
        view.sora.axis = .horizontal
        view.sora.distribution = .equalCentering
        view.sora.alignment = .center
        view.spacing = 20
        view.clipsToBounds = false
        return view
    }()

    private lazy var topUpButton: SCActionButtonView = {
        let view = SCActionButtonView()
        view.titleLabel.sora.text = R.string.soraCard.cardhubTopUp(preferredLanguages: .currentLocale)
        view.button.sora.leftImage = R.image.newArrowDown()
        view.button.sora.addHandler(for: .touchUpInside) {
            self.onAction?(.topUp)
        }
        view.button.isEnabled = false
        view.button.sora.shadow = .none
        return view
    }()

    private lazy var transferButton: SCActionButtonView = {
        let view = SCActionButtonView()
        view.titleLabel.sora.text = R.string.soraCard.cardhubTransfer(preferredLanguages: .currentLocale)
        view.button.sora.leftImage = R.image.newArrowUp()
        view.button.sora.addHandler(for: .touchUpInside) {
            self.onAction?(.transfer)
        }
        view.button.isEnabled = false
        view.button.sora.shadow = .none
        return view
    }()

    private lazy var exchangeButton: SCActionButtonView = {
        let view = SCActionButtonView()
        view.titleLabel.sora.text = R.string.soraCard.cardhubExchange(preferredLanguages: .currentLocale)
        view.button.sora.leftImage = R.image.exchange()
        view.button.sora.addHandler(for: .touchUpInside) {
            self.onAction?(.exchange)
        }
        view.button.isEnabled = false
        view.button.sora.shadow = .none
        return view
    }()

    private lazy var freezeButton: SCActionButtonView = {
        let view = SCActionButtonView()
        view.titleLabel.sora.text = R.string.soraCard.cardhubFreeze(preferredLanguages: .currentLocale)
        view.button.sora.leftImage = R.image.freeze()
        view.button.sora.addHandler(for: .touchUpInside) {
            self.onAction?(.freeze)
        }
        view.button.isEnabled = false
        view.button.sora.shadow = .none
        return view
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

    private func setupInitialLayout() {

        addSubview(iconView) {
            $0.top.leading.trailing.equalToSuperview().inset(16)
        }

        addSubview(titleLabel) {
            $0.top.equalTo(iconView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        actionButtonsView.addArrangedSubviews([
            topUpButton,
            transferButton,
            exchangeButton,
            freezeButton
        ])

        addSubview(actionButtonsScrollView) {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(16)
        }

        actionButtonsScrollView.addSubview(actionButtonsView) {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(self).inset(16)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
        let offset = max(0, actionButtonsScrollView.bounds.width - actionButtonsScrollView.contentSize.width) / 2
        actionButtonsScrollView.contentInset = .init(top: 0, left: offset, bottom: 0, right: offset)
    }
}