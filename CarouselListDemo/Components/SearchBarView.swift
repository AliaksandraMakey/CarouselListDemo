//
//  SearchBarView.swift
//  CarouselListDemo
//
//  Created by Alexandra Homan
//

 
import UIKit

final class SearchBarView: UIView {

    private enum Layout {
        static let smallCornerRadius: CGFloat = 8
        static let horizontalPadding: CGFloat = 12
    }

    var text: String = "" {
        didSet {
            textField.text = text
            clearButton.isHidden = text.isEmpty
        }
    }

    var onTextChange: ((String) -> Void)?
    var onClear: (() -> Void)?

    // MARK: - UI

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .searchBar
        view.layer.cornerRadius = Layout.smallCornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: AppIcons.magnifyingGlass)
        imageView.tintColor = .secondaryLabel
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var textField: UITextField = {
        let field = UITextField()
        field.placeholder = AppStrings.List.searchPlaceholder.localized
        field.accessibilityIdentifier = "searchBar"
        field.borderStyle = .none
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    private lazy var clearButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: AppIcons.xmarkCircleFill), for: .normal)
        button.tintColor = .secondaryLabel
        button.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraint()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupUI() {
        addSubview(containerView)
        containerView.addSubview(iconImageView)
        containerView.addSubview(textField)
        containerView.addSubview(clearButton)
    }

    private func setupConstraint() {
        NSLayoutConstraint.activate([
            // container
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            // icon
            iconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Layout.horizontalPadding),
            iconImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20),
            // text field
            textField.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            textField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            textField.trailingAnchor.constraint(equalTo: clearButton.leadingAnchor, constant: -8),
            // clear button
            clearButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Layout.horizontalPadding),
            clearButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            clearButton.widthAnchor.constraint(equalToConstant: 24),
            clearButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }

    @objc private func textDidChange() {
        let newText = textField.text ?? ""
        text = newText
        clearButton.isHidden = newText.isEmpty
        onTextChange?(newText)
    }

    @objc private func clearTapped() {
        textField.text = ""
        text = ""
        clearButton.isHidden = true
        onTextChange?("")
        onClear?()
    }
}
 
