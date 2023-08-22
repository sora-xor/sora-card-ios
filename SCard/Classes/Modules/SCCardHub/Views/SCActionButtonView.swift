import Foundation
import SoraUIKit

public final class SCActionButtonView: SoramitsuView {

    public let button: SoramitsuButton = {
        let button = SoramitsuButton(size: .large, type: .bleached(.tertiary))
        button.sora.cornerRadius = .circle
        button.sora.shadow = .small
        button.sora.clipsToBounds = false
        return button
    }()

    public let titleLabel: SoramitsuLabel = {
        let label = SoramitsuLabel()
        label.sora.font = FontType.textBoldXS
        label.sora.textColor = .fgSecondary
        label.sora.alignment = .center
        return label
    }()

    private let stackView: SoramitsuStackView = {
        let stackView = SoramitsuStackView()
        stackView.sora.axis = .vertical
        stackView.spacing = 8
        stackView.clipsToBounds = false
        return stackView
    }()


    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup() {
        clipsToBounds = false
        addSubview(stackView)
        stackView.addArrangedSubviews(button, titleLabel)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 76),
        ])
    }
}
