import UIKit

final class BottomPopupPresentationController: UIPresentationController {
    private var dimmingView: UIView!
    private var popupHeight: CGFloat
    private unowned var attributesDelegate: BottomPopupAttributesDelegate

    override var frameOfPresentedViewInContainerView: CGRect {
        get {
            return super.frameOfPresentedViewInContainerView
        }
    }

    private func changeDimmingViewAlphaAlongWithAnimation(to alpha: CGFloat) {
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.backgroundColor = UIColor.black.withAlphaComponent(alpha)
            return
        }

        coordinator.animate(alongsideTransition: { _ in
            self.dimmingView.backgroundColor = UIColor.black.withAlphaComponent(alpha)
        })
    }

    init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, attributesDelegate: BottomPopupAttributesDelegate) {
        self.attributesDelegate = attributesDelegate
        popupHeight = attributesDelegate.popupHeight
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        setupDimmingView()
    }

    override func containerViewWillLayoutSubviews() {
        guard let containerView = containerView else { return }

        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dimmingView.topAnchor.constraint(equalTo: containerView.topAnchor),
            dimmingView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            dimmingView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            dimmingView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])

        guard let presentedView = presentedView else { return }
        presentedView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            presentedView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            presentedView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            presentedView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            presentedView.heightAnchor.constraint(equalToConstant: popupHeight)
        ])
    }

    override func presentationTransitionWillBegin() {
        containerView?.insertSubview(dimmingView, at: 0)
        changeDimmingViewAlphaAlongWithAnimation(to: attributesDelegate.popupDimmingViewAlpha)
    }

    override func dismissalTransitionWillBegin() {
        changeDimmingViewAlphaAlongWithAnimation(to: 0)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { [weak self] _ in
            guard let self = self else { return }
            self.containerView?.setNeedsLayout()
            self.containerView?.layoutIfNeeded()
        }, completion: nil)
    }

    func setHeight(to height: CGFloat) {
        popupHeight = height
        UIView.animate(withDuration: attributesDelegate.popupPresentDuration) {
            self.containerView?.setNeedsLayout()
            self.containerView?.layoutIfNeeded()
        }
    }

    @objc private func handleTap(_ tap: UITapGestureRecognizer) {
        guard attributesDelegate.popupShouldBeganDismiss else { return }
        guard attributesDelegate.popupShouldDismissOnTap else { return }
        presentedViewController.dismiss(animated: true, completion: nil)
    }

    @objc private func handleSwipe(_ swipe: UISwipeGestureRecognizer) {
        guard attributesDelegate.popupShouldBeganDismiss else { return }
        guard attributesDelegate.popupShouldDismissInteractivelty else { return }
        presentedViewController.dismiss(animated: true, completion: nil)
    }
}

private extension BottomPopupPresentationController {
    func setupDimmingView() {
        dimmingView = UIView()
        dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeGesture.direction = [.down, .up]
        dimmingView.isUserInteractionEnabled = true
        [tapGesture, swipeGesture].forEach { dimmingView.addGestureRecognizer($0) }
    }
}
