import UIKit
import SoraUIKit

final class SCCardHubView: UIView {

    var onLogout: (() -> Void)?
    var onIbanShare: ((String) -> Void)?
    var onUpdateApp: (() -> Void)?
    var onClose: (() -> Void)?

    private let titleLabel: SoramitsuLabel = {
        let label = SoramitsuLabel()
        label.sora.font = FontType.headline2
        label.sora.textColor = .fgPrimary
        label.sora.numberOfLines = 0
        label.sora.text = R.string.soraCard.cardHubTitle(preferredLanguages: .currentLocale)
        return label
    }()

    private lazy var closeButton: ImageButton = {
        let button = ImageButton(size: .init(width: 24, height: 24))
        let image = R.image.close()?.withTintColor(SoramitsuUI.shared.theme.palette.color(.accentPrimary))
        button.setImage(image, for: .normal)
        button.sora.addHandler(for: .touchUpInside) { [unowned self] in
            self.onClose?()
        }
        button.sora.backgroundColor = .custom(uiColor: .clear)
        return button
    }()

    private let scrollView = UIScrollView()

    private var containerView: UIStackView = {
        var view = UIStackView()
        view.axis = .vertical
        view.spacing = 16
        return view
    }()

    private var cardHubHeaderView = SCCardHubHeaderView()


    private lazy var updateView: SCCardHubUpdateAppView = {
        let view = SCCardHubUpdateAppView()
        view.onUpdate = { [weak self] in
            self?.onUpdateApp?()
        }
        return view
    }()

    private lazy var ibanView: SCCardHubIbanView = {
        let view = SCCardHubIbanView()
        view.onIbanShare = { [weak self] iban in
            self?.onIbanShare?(iban)
        }
        view.onIbanCopy = { [weak self] iban in
            UIPasteboard.general.string = iban
            self?.showToast(
                message: R.string.soraCard.commonCopied(preferredLanguages: .currentLocale),
                font: FontType.textM.font
            )
        }
        return view
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
        view.rightImageView.image = R.image.arrowRightSmall()
        view.titleLabel.sora.text = R.string.soraCard.cardHubSettingsLogoutTitle(preferredLanguages: .currentLocale)
        view.titleLabel.sora.textColor = .statusError
        view.addTapGesture { [weak self] _ in
            self?.onLogout?()
        }
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = false
        setupInitialLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(iban: String?, balance: Int?, needUpdateApp: Bool) {
        ibanView.configure(iban: iban)
        cardHubHeaderView.configure(balance: balance)
        updateView.sora.isHidden = !needUpdateApp
    }
    
    private func setupInitialLayout() {

        addSubview(titleLabel) {
            $0.top.equalTo(self.safeAreaLayoutGuide).offset(8)
            $0.leading.greaterThanOrEqualToSuperview()
            $0.centerX.equalToSuperview()
        }

        addSubview(closeButton) {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalToSuperview().inset(24)
            $0.leading.greaterThanOrEqualTo(titleLabel.snp.trailing)
        }

        addSubview(scrollView)

        settingsContainerView.addArrangedSubviews([
            settingsTitleLabel,
            logoutView
        ])

        containerView.addArrangedSubviews([
            cardHubHeaderView,
            updateView,
            ibanView,
            settingsContainerView
        ])

        scrollView.addSubview(containerView)

        scrollView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        containerView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.trailing.equalTo(self).inset(16)
        }
    }

    private func showToast(message : String, font: UIFont) {
        let toastLabel = UILabel()
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message

        let toastView = UIView()
        toastView.backgroundColor = .black.withAlphaComponent(0.8)
        toastView.layer.cornerRadius = 10;
        toastView.clipsToBounds  =  true
        toastView.addSubview(toastLabel) {
            $0.top.bottom.equalToSuperview().inset(5)
            $0.leading.trailing.equalToSuperview().inset(8)
        }

        self.addSubview(toastView) {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().multipliedBy(0.8)
        }

        UIView.animate(withDuration: 1.0, delay: 0.5, options: .curveEaseOut,
        animations: {
            toastView.alpha = 0.0
        }, completion: { _ in
            toastView.removeFromSuperview()
        })
    }
}
