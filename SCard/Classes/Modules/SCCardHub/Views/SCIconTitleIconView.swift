import Foundation
import SoraUIKit

class SCTitleIconView: SoramitsuView {

    var onTap: (()->())?

    private let titleLabel: SoramitsuLabel = {
        let label = SoramitsuLabel()
        label.numberOfLines = 1
        label.textAlignment = .left
        label.backgroundColor = .clear
        label.sora.font = FontType.textM
        label.sora.textColor = .fgPrimary
        return label
    }()

    private let rightImageView: SoramitsuImageView = {
        let imageView = SoramitsuImageView()
        imageView.image = R.image.arrowRightSmall()
        return imageView
    }()

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)

        setupInitialLayout()

        self.addTapGesture { [weak self] _ in
            self?.onTap?()
        }
    }

    func configure(title: String, titleColor: SoramitsuColor = .fgPrimary) {
        titleLabel.sora.text = title
        titleLabel.sora.textColor = titleColor
    }

    private func setupInitialLayout() {
        addSubview(titleLabel) {
            $0.top.bottom.equalToSuperview().inset(20)
            $0.leading.equalToSuperview()
        }

        addSubview(rightImageView) {
            $0.leading.equalTo(self.titleLabel.snp.trailing).offset(20)
            $0.trailing.centerY.equalToSuperview()
            $0.size.equalTo(24)
        }
    }
}
