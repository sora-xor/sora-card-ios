import SoraUIKit
import SnapKit

public final class SCBuyXorCell: SoramitsuTableViewCell {

    var onClose: (() -> Void)?
    var onTap: (() -> Void)?

    private lazy var title: SoramitsuLabel = {
        let view = SoramitsuLabel()
        view.sora.text = R.string.soraCard.exchangeBannerTitle(preferredLanguages: .currentLocale)
        view.sora.textColor = .custom(uiColor: .black)
        view.sora.font = FontType.headline2
        return view
    }()

    private lazy var subTitle: SoramitsuLabel = {
        let view = SoramitsuLabel()
        view.sora.text = R.string.soraCard.exchangeBannerSubtitle(preferredLanguages: .currentLocale)
        view.sora.textColor = .custom(uiColor: .black)
        view.sora.font = FontType.paragraphXS
        return view
    }()

    private lazy var button: SoramitsuButton = {
        let view = SoramitsuButton(size: .extraSmall, type: .filled(.primary))
        view.sora.title = R.string.soraCard.exchangeBannerButton(preferredLanguages: .currentLocale)
        view.sora.cornerRadius = .circle
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

    private lazy var icon: SoramitsuImageView = {
        let view = SoramitsuImageView()
        view.sora.picture = .logo(image: R.image.buyXOR()!)
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupConstraints()
        contentView.backgroundColor = SoramitsuUI.shared.theme.palette.color(.bgSurface)
        contentView.layer.cornerRadius = 32
        contentView.clipsToBounds = true
        contentView.addTapGesture { _ in
            self.onTap?()
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupConstraints() {

        contentView.addSubview(icon) {
            $0.trailing.bottom.equalToSuperview().inset(-16)
        }

        contentView.addSubview(closeButton) {
            $0.top.equalToSuperview().inset(12)
            $0.trailing.equalToSuperview().inset(16)
        }

        contentView.addSubview(title) {
            $0.top.equalToSuperview().inset(16)
            $0.leading.equalToSuperview().inset(24)
        }

        contentView.addSubview(subTitle) {
            $0.top.equalTo(title.snp.bottom).offset(8)
            $0.leading.equalToSuperview().inset(24)
        }

        contentView.addSubview(button) {
            $0.top.equalTo(subTitle.snp.bottom).offset(12)
            $0.leading.bottom.equalToSuperview().inset(24)
            $0.width.equalTo(100)
        }
    }
}

extension SCBuyXorCell: SoramitsuTableViewCellProtocol {
    public func set(item: SoramitsuTableViewItemProtocol, context: SoramitsuTableViewContext?) {
        guard let item = item as? SCBuyXorItem else { return }
        self.onClose = item.onClose
        self.onTap = item.onTap
    }
}
