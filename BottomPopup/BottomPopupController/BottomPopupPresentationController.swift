//
//  BottomPopupPresentationController.swift
//  PresentationController
//
//  Created by Emre on 11.09.2018.
//  Copyright © 2018 Emre. All rights reserved.
//

import UIKit

final class BottomPopupPresentationController: UIPresentationController {
    private var dimmingView: UIView!
    private var popupHeight: CGFloat
    private var popupWidth: CGFloat
    private unowned var attributesDelegate: BottomPopupAttributesDelegate
    
    override var frameOfPresentedViewInContainerView: CGRect {
        let viewWidth = containerView?.frame.width ?? 0
        let x = (viewWidth - popupWidth) / 2
        return CGRect(origin: CGPoint(x: x, y: UIScreen.main.bounds.size.height - popupHeight), size: CGSize(width: popupWidth, height: popupHeight))
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
        popupWidth = attributesDelegate.popupWidth
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        setupDimmingView()
    }
    
    override func containerViewDidLayoutSubviews() {
        dimmingView.frame = containerView?.bounds ?? .zero
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
    
    override func presentationTransitionWillBegin() {
        containerView?.insertSubview(dimmingView, at: 0)
        if let containerView {
            dimmingView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                dimmingView.topAnchor.constraint(equalTo: containerView.topAnchor),
                dimmingView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
                dimmingView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
                dimmingView.rightAnchor.constraint(equalTo: containerView.rightAnchor),
            ])
        }
        changeDimmingViewAlphaAlongWithAnimation(to: attributesDelegate.popupDimmingViewAlpha)
    }
    
    override func dismissalTransitionWillBegin() {
        changeDimmingViewAlphaAlongWithAnimation(to: 0)
    }

    func setHeight(to height: CGFloat) {
        popupHeight = height
        UIView.animate(withDuration: attributesDelegate.popupPresentDuration) {
            self.containerViewWillLayoutSubviews()
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
        dimmingView.frame = CGRect(origin: .zero, size: UIScreen.main.bounds.size)
        dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeGesture.direction = [.down, .up]
        dimmingView.isUserInteractionEnabled = true
        [tapGesture, swipeGesture].forEach { dimmingView.addGestureRecognizer($0) }
    }
}
