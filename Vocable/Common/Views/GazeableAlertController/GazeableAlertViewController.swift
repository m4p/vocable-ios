//
//  GazeableAlertViewController.swift
//  Vocable AAC
//
//  Created by Patrick Gatewood on 2/28/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

public struct GazableAlertAction {

    enum Style {
        case `default`
        case cancel
    }

    let title: String
    let style: Style? = .default
    let handler: ((GazableAlertAction) -> Void)?
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

    private lazy var dividerView: UIView = {
        let view = UIView()
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

        borderView.addSubview(titleLabel)
        borderView.addSubview(dividerView)
        borderView.addSubview(stackView)

        var virticalPadding: CGFloat
        var horizontalPadding: CGFloat

        if traitCollection.horizontalSizeClass == .regular {
            virticalPadding = 41
            horizontalPadding = 50
        } else {
            virticalPadding = 36
            horizontalPadding = 12
        }

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: borderView.topAnchor, constant: virticalPadding),
            titleLabel.leadingAnchor.constraint(equalTo: borderView.leadingAnchor, constant: horizontalPadding),
            titleLabel.trailingAnchor.constraint(equalTo: borderView.trailingAnchor, constant: -horizontalPadding),
            titleLabel.bottomAnchor.constraint(equalTo: dividerView.topAnchor, constant: -virticalPadding),
            dividerView.heightAnchor.constraint(equalToConstant: 1),
            dividerView.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            dividerView.bottomAnchor.constraint(equalTo: stackView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: borderView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: borderView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: borderView.bottomAnchor)
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

            //button.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)

            if stackView.arrangedSubviews.isEmpty {
                firstButton = button
                stackView.addArrangedSubview(button)

            } else {

                let dividerView = UIView()
                dividerView.backgroundColor = .grayDivider
                dividerView.translatesAutoresizingMaskIntoConstraints = false

                if stackView.axis == .horizontal {
                    dividerView.widthAnchor.constraint(equalToConstant: 1).isActive = true
                } else {
                    dividerView.heightAnchor.constraint(equalToConstant: 1).isActive = true
                }

                dividerView.heightAnchor.constraint(equalToConstant: traitCollection.horizontalSizeClass == .regular ? regularButtonHeight : compactButtonHeight).isActive = true

                stackView.addArrangedSubview(dividerView)
                stackView.addArrangedSubview(button)

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

    func didTapButton(_ action: GazableAlertAction) {
        if action.style == .cancel {
            dismiss(animated: true)
        } else {
            dismiss(animated: true) {
                _ = action.handler
            }
        }
    }

}
