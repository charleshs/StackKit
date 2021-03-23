import UIKit

/// A `UIView` subclass that layouts its managed subviews in a list layout with scrolling.
open class ListScrollView: UIView {
    public enum Size {
        /// When set to `fill`, the stack view fills the entire available space of the current view,
        /// i.e. the current view's width subtracted by the horizontal content insets.
        case fill
        /// When set to `natural`, the stack view fits to its content size and aligns to the current view
        /// based on the provided `Alignment` value.
        case natural(Alignment)
    }

    public enum Alignment {
        /// Indicates that the stack view aligns to the left of current view, as `natural` size being set.
        case left
        /// Indicates that the stack view aligns to the center of current view, as `natural` size being set.
        case center
        /// Indicates that the stack view aligns to the right of current view, as `natural` size being set.
        case right
    }

    /// Describes the filling behavior of the stack view.
    public final var size: Size = .fill {
        didSet {
            remakeConstraintsForStackView()
        }
    }

    /// Insets of the stack view to the current view (zero point by default).
    public final var contentInsets: UIEdgeInsets = .zero {
        didSet {
            remakeConstraintsForStackView()
        }
    }

    public let scrollView: UIScrollView = {
        let v = UIScrollView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .clear
        return v
    }()

    private let stackView: UIStackView = {
        let v = UIStackView(axis: .vertical, alignment: .fill, distribution: .fill, spacing: 8)
        v.isUserInteractionEnabled = true
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .clear
        return v
    }()

    private var constraintsForStackView: [NSLayoutConstraint] = []

    // MARK: Initializer

    public override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }
}

// MARK: - API

extension ListScrollView {
    open func append(_ newView: UIView, spacingPrev: CGFloat? = nil, spacingNext: CGFloat? = nil) {
        stackView.addArrangedSubview(newView, spacingPrev: spacingPrev, spacingNext: spacingNext)
    }

    open func insert(_ newView: UIView, at index: Int, spacingPrev: CGFloat? = nil, spacingNext: CGFloat? = nil) {
        stackView.insertArrangedSubview(newView, at: index, spacingPrev: spacingPrev, spacingNext: spacingNext)
    }

    open func insert(_ newView: UIView, after existingView: UIView, spacingPrev: CGFloat? = nil, spacingNext: CGFloat? = nil) {
        stackView.insertArrangedSubview(newView, after: existingView, spacingPrev: spacingPrev, spacingNext: spacingNext)
    }

    open func insert(_ newView: UIView, before existingView: UIView, spacingPrev: CGFloat? = nil, spacingNext: CGFloat? = nil) {
        stackView.insertArrangedSubview(newView, before: existingView, spacingPrev: spacingPrev, spacingNext: spacingNext)
    }

    open func replace(_ oldView: UIView, with newView: UIView) {
        stackView.replaceArrangedSubview(oldView, with: newView)
    }

    open func remove(_ subview: UIView) {
        stackView.removeArrangedSubview(subview)
    }

    open func removeAll() {
        stackView.removeAllArrangedSubviews()
    }
}

extension ListScrollView {
    /// The default spacings among all managed subviews (8 points by default).
    public final var spacing: CGFloat {
        get {
            return stackView.spacing
        }
        set(spacing) {
            stackView.spacing = spacing
        }
    }


    /// The `distribution` property of the list-managing stack view (`fill` by default)
    public final var distribution: UIStackView.Distribution {
        get {
            return stackView.distribution
        }
        set(distribution) {
            stackView.distribution = distribution
        }
    }

    /// The `alignment` property of the list-managing stack view (`fill` by default)
    public final var alignment: UIStackView.Alignment {
        get {
            return stackView.alignment
        }
        set(alignment) {
            stackView.alignment = alignment
        }
    }
}

// MARK: - Private

extension ListScrollView {
    private func sharedInit() {
        scrollView.addSubview(stackView)
        self.addSubview(scrollView)
        setupInitialConstraints()
    }

    private func setupInitialConstraints() {
        let scrollViewConstraints = [
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
        ]

        constraintsForStackView = produceConstraintsForStackView()
        NSLayoutConstraint.activate([scrollViewConstraints, constraintsForStackView].flatMap { $0 })
    }

    private func remakeConstraintsForStackView() {
        NSLayoutConstraint.deactivate(constraintsForStackView)
        constraintsForStackView = produceConstraintsForStackView()
        NSLayoutConstraint.activate(constraintsForStackView)
    }

    private func produceConstraintsForStackView() -> [NSLayoutConstraint] {
        typealias Reference<Anchor> = (anchor: Anchor, constant: CGFloat)

        let leading: Reference<NSLayoutXAxisAnchor> = (scrollView.frameLayoutGuide.leadingAnchor, contentInsets.left)
        let trailing: Reference<NSLayoutXAxisAnchor> = (scrollView.frameLayoutGuide.trailingAnchor, contentInsets.right)
        let top: Reference<NSLayoutYAxisAnchor> = (scrollView.contentLayoutGuide.topAnchor, contentInsets.top)
        let bottom: Reference<NSLayoutYAxisAnchor> = (scrollView.contentLayoutGuide.bottomAnchor, contentInsets.bottom)
        let centerX: Reference<NSLayoutXAxisAnchor> = (scrollView.frameLayoutGuide.centerXAnchor, .zero)

        let verticalConstraints = [
            stackView.topAnchor.constraint(equalTo: top.anchor, constant: top.constant),
            bottom.anchor.constraint(equalTo: stackView.bottomAnchor, constant: bottom.constant),
        ]

        let horizontalConstraints: [NSLayoutConstraint]
        switch size {
        case .fill:
            horizontalConstraints = [
                stackView.leadingAnchor.constraint(equalTo: leading.anchor, constant: leading.constant),
                trailing.anchor.constraint(equalTo: stackView.trailingAnchor, constant: trailing.constant),
            ]
        case .natural(let alignment):
            switch alignment {
            case .left:
                horizontalConstraints = [
                    stackView.leadingAnchor.constraint(equalTo: leading.anchor, constant: leading.constant),
                    trailing.anchor.constraint(greaterThanOrEqualTo: stackView.trailingAnchor, constant: trailing.constant),
                ]
            case .center:
                horizontalConstraints = [
                    stackView.leadingAnchor.constraint(greaterThanOrEqualTo: leading.anchor, constant: leading.constant),
                    stackView.centerXAnchor.constraint(equalTo: centerX.anchor, constant: centerX.constant),
                    trailing.anchor.constraint(greaterThanOrEqualTo: stackView.trailingAnchor, constant: trailing.constant),
                ]
            case .right:
                horizontalConstraints = [
                    stackView.leadingAnchor.constraint(greaterThanOrEqualTo: leading.anchor, constant: leading.constant),
                    trailing.anchor.constraint(equalTo: stackView.trailingAnchor, constant: trailing.constant),
                ]
            }
        }
        return [verticalConstraints, horizontalConstraints].flatMap { $0 }
    }
}
