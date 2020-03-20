//
//  GazeableAlertViewController.swift
//  Vocable AAC
//
//  Created by Patrick Gatewood on 2/28/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

final class GazableAlertAction: NSObject {

    let title: String
    @objc let handler: (() -> Void)?

    init(title: String, handler: (() -> Void)?) {
        self.title = title
        self.handler = handler
    }

}

private final class DividerView: UIView {

    override var intrinsicContentSize: CGSize {
        return CGSize(width: 1, height: 1)
    }
}

final class GazeableAlertViewController: UIViewController {

    private let regularLeadingTrailingWidth: CGFloat = 250
    private let compactLeadingTrailingWidth: CGFloat = 25
    private let regularButtonHeight: CGFloat = 100
    private let compactButtonHeight: CGFloat = 75

    private lazy var borderView: BorderedView = {
        let view = BorderedView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.roundedCorners = .allCorners
        view.cornerRadius = 14
        view.fillColor = .alertBackgroundColor
        return view
    }()

    private lazy var titleContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false

        if traitCollection.horizontalSizeClass == .regular {
            view.layoutMargins = UIEdgeInsets(top: 41, left: 50, bottom: 39, right: 50)
        } else {
            view.layoutMargins = UIEdgeInsets(top: 36, left: 12, bottom: 36, right: 12)
        }

        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0

        if traitCollection.horizontalSizeClass == .regular {
            label.font = UIFont.systemFont(ofSize: 34)
        } else {
            label.font = UIFont.systemFont(ofSize: 17)
        }

        return label
    }()

    private lazy var stackView: UIStackView = {
        let stackView: UIStackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .center
        stackView.spacing = 0
        return stackView
    }()

    private lazy var dividerView: DividerView = {
        let view = DividerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .grayDivider
        return view
    }()

    private var actions = [GazableAlertAction]() {
        didSet {
            updateButtonLayout()
        }
    }

    init(alertTitle: String) {
        super.init(nibName: nil, bundle: nil)

        self.titleLabel.text = alertTitle
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func addAction(_ action: GazableAlertAction) {
        actions.append(action)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear

        setupViews()
    }

    private func setupViews() {

        view.addSubview(borderView)
        NSLayoutConstraint.activate([
            borderView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: traitCollection.horizontalSizeClass == .regular ? regularLeadingTrailingWidth : compactLeadingTrailingWidth),
            borderView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: traitCollection.horizontalSizeClass == .regular ? -regularLeadingTrailingWidth : -compactLeadingTrailingWidth),
            borderView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            borderView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        borderView.addSubview(titleContainerView)
        titleContainerView.addSubview(titleLabel)
        borderView.addSubview(dividerView)
        borderView.addSubview(stackView)

        NSLayoutConstraint.activate([
            titleContainerView.topAnchor.constraint(equalTo: borderView.layoutMarginsGuide.topAnchor),
            titleContainerView.leadingAnchor.constraint(equalTo: borderView.layoutMarginsGuide.leadingAnchor),
            titleContainerView.trailingAnchor.constraint(equalTo: borderView.layoutMarginsGuide.trailingAnchor),
            titleContainerView.bottomAnchor.constraint(equalTo: dividerView.topAnchor),
            dividerView.widthAnchor.constraint(equalTo: stackView.layoutMarginsGuide.widthAnchor),
            dividerView.bottomAnchor.constraint(equalTo: stackView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: borderView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: borderView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: borderView.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: titleContainerView.layoutMarginsGuide.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: titleContainerView.layoutMarginsGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: titleContainerView.layoutMarginsGuide.trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: titleContainerView.layoutMarginsGuide.bottomAnchor)
        ])
    }

    private func updateButtonLayout() {

        for view in stackView.arrangedSubviews {
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        var firstButton: GazeableButton?

        actions.forEach { action in
            let button = GazeableButton(frame: .zero)
            button.fillColor = .alertBackgroundColor
            button.selectionFillColor = .primaryColor
            button.setTitleColor(.white, for: .selected)
            button.setTitleColor(.black, for: .normal)
            button.setTitle(action.title, for: .normal)

            button.translatesAutoresizingMaskIntoConstraints = false
            let buttonHeightConstraint = button.heightAnchor.constraint(equalToConstant: traitCollection.horizontalSizeClass == .regular ? regularButtonHeight : compactButtonHeight)
            buttonHeightConstraint.priority = .defaultHigh
            buttonHeightConstraint.isActive = true

            // Error: Argument of '#selector' does not refer to an '@objc' method, property, or initializer
            //button.addTarget(self, action: #selector(didTapButton(action)), for: .touchUpInside)

            if action.handler != nil {
                button.addTarget(self, action: #selector(getter: action.handler), for: .touchUpInside)
            } else {
                button.addTarget(self, action: #selector(dismissAlert), for: .touchUpInside)
            }

            if stackView.arrangedSubviews.isEmpty {
                firstButton = button
                stackView.addArrangedSubview(button)

            } else {

                let separator = UIView()
                separator.backgroundColor = .grayDivider
                separator.translatesAutoresizingMaskIntoConstraints = false

                if stackView.axis == .horizontal {
                    separator.widthAnchor.constraint(equalToConstant: 1).isActive = true
                } else {
                    separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
                }

                separator.heightAnchor.constraint(equalToConstant: traitCollection.horizontalSizeClass == .regular ? regularButtonHeight : compactButtonHeight).isActive = true

                stackView.addArrangedSubview(separator)
                stackView.addArrangedSubview(button)

                if stackView.axis == .horizontal {
                    button.widthAnchor.constraint(equalTo: firstButton!.widthAnchor).isActive = true
                } else {
                    button.heightAnchor.constraint(equalTo: firstButton!.heightAnchor).isActive = true
                }
            }

            if actions.count > 2 {
                stackView.axis = .vertical
            } else {
                stackView.axis = .horizontal
            }
        }
    }

    @objc func dismissAlert() {
        self.dismiss(animated: true)
    }

    @objc func didTapButton(_ sender: GazableAlertAction) {
        guard let handler = sender.handler else { return }
        handler()
    }

}
