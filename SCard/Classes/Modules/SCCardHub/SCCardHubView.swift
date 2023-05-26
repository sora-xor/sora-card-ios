import UIKit
import SoraUIKit

final class SCCardHubView: UIView {

    var onLogout: (() -> Void)?

    private let scrollView = UIScrollView()

    // TODO: use table if needed
    private var containerView: SoramitsuStackView = {
        var view = SoramitsuStackView()
        view.sora.axis = .vertical
        view.sora.backgroundColor = .custom(uiColor: .clear)
        view.spacing = 16
        return view
    }()

    private var cardContainerView: SoramitsuStackView = {
        var view = SoramitsuStackView()
        view.sora.backgroundColor = .bgSurface
        view.sora.axis = .vertical
        view.sora.shadow = .default
        view.spacing = 16
        view.sora.cornerRadius = .max
        view.sora.distribution = .fill
        view.layoutMargins = UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)
        view.isLayoutMarginsRelativeArrangement = true
        return view
    }()

    private let iconView: SoramitsuImageView = {
        let view = SoramitsuImageView()
        let icon = R.image.scFront()
        view.sora.picture = .logo(image: R.image.scFront()!)
        return view
    }()

    private let titleLabel: SoramitsuLabel = {
        let label = SoramitsuLabel()
        label.sora.font = FontType.headline1
        label.sora.textColor = .fgPrimary
        label.sora.numberOfLines = 0
        label.sora.text = "SORA Card" // TODO:
        return label
    }()

    private var settingsContainerView: SoramitsuStackView = {
        var view = SoramitsuStackView()
        view.sora.backgroundColor = .bgSurface
        view.sora.axis = .vertical
        view.sora.shadow = .default
        view.spacing = 16
        view.sora.cornerRadius = .medium
        view.sora.distribution = .fill
        view.layoutMargins = UIEdgeInsets(top: 16, left: 24, bottom: 16, right: 24)
        view.isLayoutMarginsRelativeArrangement = true
        return view
    }()

    private let settingsTitleLabel: SoramitsuLabel = {
        let label = SoramitsuLabel()
        label.sora.font = FontType.headline2
        label.sora.textColor = .fgPrimary
        label.sora.numberOfLines = 0
        label.sora.text = R.string.soraCard.cardHubSettingsTitle(preferredLanguages: .currentLocale)
        return label
    }()

    private lazy var logoutView: SCTitleIconView = {
        let view = SCTitleIconView()
        view.addTapGesture { [weak self] _ in
            self?.onLogout?()
        }
        view.configure(title: R.string.soraCard.cardHubSettingsLogout(preferredLanguages: .currentLocale), titleColor: .statusError)

        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupInitialLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupInitialLayout() {

        addSubview(scrollView)

        cardContainerView.addArrangedSubviews([
            iconView,
            titleLabel
        ])

        settingsContainerView.addArrangedSubviews([
            settingsTitleLabel,
            logoutView
        ])

        containerView.addArrangedSubviews([
            cardContainerView,
            settingsContainerView
        ])

        scrollView.addSubview(containerView)

        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        containerView.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide).offset(24)
            $0.top.bottom.equalToSuperview()
            $0.leading.trailing.equalTo(self).inset(16)
        }
    }
}
