import UIKit
import SoraUIKit

final class SCKYCEnterPhoneView: UIView {

    var onInput: ((String) -> Void)?
    var onContinueButton: (() -> Void)?

    private let textLabel: SoramitsuLabel = {
        let label = SoramitsuLabel()
        label.sora.font = FontType.paragraphM
        label.sora.textColor = .fgPrimary
        label.sora.numberOfLines = 0
        label.sora.alignment = .center
        label.sora.text = R.string.soraCard.enterPhoneNumberDescription(preferredLanguages: .currentLocale)
        return label
    }()

    private(set) lazy var inputField: InputField = {
        let view = InputField()
        view.sora.titleLabelText = R.string.soraCard.enterPhoneNumberPhoneInputFieldLabel(preferredLanguages: .currentLocale)
        view.sora.textFieldPlaceholder = "+12345678901"
        view.sora.descriptionLabelText = R.string.soraCard.commonNoSpam(preferredLanguages: .currentLocale)
        view.sora.keyboardType = .phonePad
        view.sora.textContentType = .telephoneNumber
        view.sora.addHandler(for: .editingChanged) { [weak self] in
            self?.onInput?(self?.inputField.sora.text ?? "")
        }
        view.sora.addHandler(for: .editingDidBegin) { [weak self] in
            if view.sora.text?.isEmpty ?? true {
                view.sora.text = "+"
            }
        }
        return view
    }()

    private lazy var continueButton: SoramitsuButton = {
        let button = SoramitsuButton(size: .large, type: .filled(.secondary))
        button.sora.isEnabled = false
        button.sora.cornerRadius = .custom(28)
        button.sora.addHandler(for: .touchUpInside) { [weak self] in
            self?.onContinueButton?()
        }
        button.sora.title = R.string.soraCard.commonSendCode(preferredLanguages: .currentLocale)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setupInitialLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(errorMessage: String, isContinueEnabled: Bool) {
        inputField.sora.state = errorMessage.isEmpty ? .success : .fail
        inputField.sora.descriptionLabelText = errorMessage
        continueButton.sora.isEnabled = isContinueEnabled
    }

    private func setupInitialLayout() {
        addSubview(textLabel)
        addSubview(inputField)
        addSubview(continueButton)

        textLabel.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview().inset(24)
        }

        inputField.snp.makeConstraints {
            $0.top.equalTo(textLabel.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(76) // TODO: Ivan fix InputField constraints to have min content size
        }

        continueButton.snp.makeConstraints {
            $0.top.equalTo(inputField.snp.bottom).offset(28)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
    }
}
