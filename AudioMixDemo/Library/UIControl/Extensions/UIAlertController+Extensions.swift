// swiftlint:disable all
import UIKit
import AudioToolbox

// MARK: - Initializers
extension UIAlertController {

    /// Create new alert view controller.
    ///
    /// - Parameters:
    ///   - style: alert controller's style.
    ///   - title: alert controller's title.
    ///   - message: alert controller's message (default is nil).
    ///   - defaultActionButtonTitle: default action button title (default is "OK")
    ///   - tintColor: alert controller's tint color (default is nil)
    convenience init(style: UIAlertController.Style, source: UIView? = nil, title: String? = nil, message: String? = nil, tintColor: UIColor? = nil) {
        self.init(title: title, message: message, preferredStyle: style)

        // TODO: for iPad or other views
        let isPad: Bool = UIDevice.current.userInterfaceIdiom == .pad
        let root = UIApplication.shared.keyWindow?.rootViewController?.view

        //self.responds(to: #selector(getter: popoverPresentationController))
        if let source = source {
            Log("----- source")
            popoverPresentationController?.sourceView = source
            popoverPresentationController?.sourceRect = source.bounds
        } else if isPad, let source = root, style == .actionSheet {
            Log("----- is pad")
            popoverPresentationController?.sourceView = source
            popoverPresentationController?.sourceRect = CGRect(x: source.bounds.midX, y: source.bounds.midY, width: 0, height: 0)
            //popoverPresentationController?.permittedArrowDirections = .down
            popoverPresentationController?.permittedArrowDirections = .init(rawValue: 0)
        }

        if let color = tintColor {
            self.view.tintColor = color
        }
    }
}

// MARK: - Methods
extension UIAlertController {

    /// Present alert view controller in the current view controller.
    ///
    /// - Parameters:
    ///   - animated: set true to animate presentation of alert controller (default is true).
    ///   - vibrate: set true to vibrate the device while presenting the alert (default is false).
    ///   - completion: an optional completion handler to be called after presenting alert controller (default is nil).
    public func show(animated: Bool = true, vibrate: Bool = false, style: UIBlurEffect.Style? = nil, completion: (() -> Void)? = nil) {

        /// TODO: change UIBlurEffectStyle
        if let style = style {
            for subview in view.allSubViewsOf(type: UIVisualEffectView.self) {
                subview.effect = UIBlurEffect(style: style)
            }
        }

        DispatchQueue.main.async {
            UIApplication.shared.keyWindow?.rootViewController?.present(self, animated: animated, completion: completion)
            if vibrate {
                AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
            }
        }
    }

    /// Add an action to Alert
    ///
    /// - Parameters:
    ///   - title: action title
    ///   - style: action style (default is UIAlertActionStyle.default)
    ///   - isEnabled: isEnabled status for action (default is true)
    ///   - handler: optional action handler to be called when button is tapped (default is nil)
    func addAction(image: UIImage? = nil, title: String, color: UIColor? = nil, style: UIAlertAction.Style = .default, isEnabled: Bool = true, handler: ((UIAlertAction) -> Void)? = nil) {
        //let isPad: Bool = UIDevice.current.userInterfaceIdiom == .pad
        //let action = UIAlertAction(title: title, style: isPad && style == .cancel ? .default : style, handler: handler)
        let action = UIAlertAction(title: title, style: style, handler: handler)
        action.isEnabled = isEnabled

        // button image
        if let image = image {
            action.setValue(image, forKey: "image")
        }

        // button title color
        if let color = color {
            action.setValue(color, forKey: "titleTextColor")
        }

        addAction(action)
    }

    /// Set alert's title, font and color
    ///
    /// - Parameters:
    ///   - title: alert title
    ///   - font: alert title font
    ///   - color: alert title color
    func set(title: String?, font: UIFont, color: UIColor) {
        if title != nil {
            self.title = title
        }
        setTitle(font: font, color: color)
    }

    func setTitle(font: UIFont, color: UIColor) {
        guard let title = self.title else { return }
        let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
        let attributedTitle = NSMutableAttributedString(string: title, attributes: attributes)
        setValue(attributedTitle, forKey: "attributedTitle")
    }

    /// Set alert's message, font and color
    ///
    /// - Parameters:
    ///   - message: alert message
    ///   - font: alert message font
    ///   - color: alert message color
    func set(message: String?, font: UIFont, color: UIColor) {
        if message != nil {
            self.message = message
        }
        setMessage(font: font, color: color)
    }

    func setMessage(font: UIFont, color: UIColor) {
        guard let message = self.message else { return }
        let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
        let attributedMessage = NSMutableAttributedString(string: message, attributes: attributes)
        setValue(attributedMessage, forKey: "attributedMessage")
    }

    /// Set alert's content viewController
    ///
    /// - Parameters:
    ///   - vc: ViewController
    ///   - height: height of content viewController
    func set(vc: UIViewController?, width: CGFloat? = nil, height: CGFloat? = nil) {
        guard let vc = vc else { return }
        setValue(vc, forKey: "contentViewController")
        if let height = height {
            vc.preferredContentSize.height = height
            preferredContentSize.height = height
        }
    }
}
extension UIAlertController {

    /// Use this method to display an **Alert** or an **ActionSheet** on any viewController.
    ///
    /// - Parameters:
    ///   - controller: Object of controller on which you need to an display Alert/Actionsheet.
    ///   - title: String Title which you want to display.
    ///   - message: String Message which you want to display.
    ///   - style: .alert || .actionshhet
    ///   - cancelButton: String Title for Cancel Button type which you want to display.
    ///   - distrutiveButton: String Title for Distrutive Button type which you want to display.
    ///   - otherButtons: String Array of Other Button type which you want to display.
    ///   - completion: You will get the call back here when user tap on the button from the alert.
    ///
    ///     - Other Button Index will always be the first priority which will start from - **0...**
    ///     - If Cancel And Destructive both the buttons will be there then index of Destructive button is **0**(2nd Last) and Cancel Button index is **1** (Last).
    ///     - If Cancel, Destructive and Other Buttons will be there then index of Destructive button is **(2nd Last)** and Cancel Button index is **(Last)**. and Other Buttons index will start from **0**
    ///
    class func showAlert(controller: AnyObject ,
                         title: String? = nil,
                         message: String? = nil,
                         style: UIAlertController.Style = .alert ,
                         cancelButton: String? = nil ,
                         distrutiveButton: String? = nil ,
                         otherButtons: [String]? = nil,
                         completion: ((Int, String) -> Void)?) {

        // Set Title to the Local Variable
        //        let strTitle = ""

        // Set Message to the Local Variable
        //        let strMessage = message!

        // Create an object of Alert Controller
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: style)
        // Set Attributed title for Alert with custom Font and Color
        //        let titleAttribute: [String : Any] = [NSFontAttributeName: UIFont.MuliBold(size: 16.0), NSForegroundColorAttributeName: UIColor.orangeDark]
        //        let titleString = NSMutableAttributedString(string: strTitle, attributes: titleAttribute)
        //        alert.setValue(titleString, forKey: "attributedTitle") // attributedMessage // attributedTitle

        // Set Attributed message for Alert with custom Font and Color
        //        let messageAttribute: [String : Any] = [NSFontAttributeName: UIFont.MuliRegular(size: 14.0), NSForegroundColorAttributeName: UIColor.graySubTitle]
        //        let messageString = NSMutableAttributedString(string: strMessage, attributes: messageAttribute)
        //        alert.setValue(messageString, forKey: "attributedMessage") // attributedMessage // attributedTitle

        // Set Distrutive button if it is not nil
        if let strDistrutiveBtn = distrutiveButton {

            alert.addAction(UIAlertAction.init(title: strDistrutiveBtn, style: .destructive, handler: { (_) in

                completion?(otherButtons != nil ? otherButtons!.count : 0, strDistrutiveBtn)

            }))

        }

        // Set Cancel button if it is not nil
        if let strCancelBtn = cancelButton {

            alert.addAction(UIAlertAction.init(title: strCancelBtn, style: .cancel, handler: { (_) in

                // Pass action to the completion block
                if distrutiveButton != nil {
                    // If Distrutive button was added to the alert then pass the index 2nd last
                    completion?(otherButtons != nil ? otherButtons!.count + 1 : 1, strCancelBtn)
                } else {
                    // Pass the last index to the completion block
                    completion?(otherButtons != nil ? otherButtons!.count : 0, strCancelBtn)
                }

            }))

        }

        // Set Other Buttons if it is not nil
        if let arr = otherButtons {

            // Loop through all the array and add the individual action to the alert
            for (index, value) in arr.enumerated() {

                alert.addAction(UIAlertAction.init(title: value, style: .default, handler: { (_) in

                    // Pass the index and the string value to the completion block which will use to perform further action
                    completion?(index, value)

                }))

            }
        }

        // Change the Color of the button title
        //        alert.view.tintColor = UIColor.orangeDark

        // Display an alert on on the controller
        controller.present(alert, animated: true, completion: nil)

    }

    /// Use this method to display an **Alert** with **Ok** Button on any viewController.
    ///
    /// - Parameters:
    ///   - controller: Object of controller on which you need to display an Alert
    ///   - message: String Message which you want to display.
    ///   - completion: You will get the call back here when user tap on the button from the alert. Index will always be 0
    ///
    class func showAlertWithOkButton(controller: AnyObject ,
                                     message: String? = nil ,
                                     completion: ((Int, String) -> Void)?) {

        showAlert(controller: controller, message: message, style: .alert, cancelButton: nil, distrutiveButton: nil, otherButtons: ["OK"], completion: completion)

    }

    /// Use this method to display an **Alert** with **Cancel** Button on any viewController.
    ///
    /// - Parameters:
    ///   - controller: Object of controller on which you need to display an Alert
    ///   - message: String Message which you want to display.
    ///   - completion: You will get the call back here when user tap on the button from the alert. Index will always be 0
    class func showAlertWithCancelButton(controller: AnyObject ,
                                         message: String? = nil ,
                                         completion: ((Int, String) -> Void)?) {

        showAlert(controller: controller, message: message, style: .alert, cancelButton: "Cancel", distrutiveButton: nil, otherButtons: nil, completion: completion)

    }

    /// Use this method to display an **Alert** for Delete confirmation on any viewController.
    ///
    /// - Parameters:
    ///   - controller: Object of controller on which you need to display an Alert
    ///   - message: String Message which you want to display.
    ///   - completion: You will get the call back here when user tap on the button from the alert.
    ///
    ///     - If Cancel And Destructive both the buttons will be there then index of Destructive button is **0**(2nd Last) and Cancel Button index is **1** (Last).
    class func showDeleteAlert(controller: AnyObject ,
                               message: String? = nil ,
                               completion: ((Int, String) -> Void)?) {

        showAlert(controller: controller, message: message, style: .alert, cancelButton: "Cancel", distrutiveButton: "Delete", otherButtons: nil, completion: completion)

    }

    class func showYesNoAlert(controller: AnyObject ,
                              message: String? = nil ,
                              completion: ((Int, String) -> Void)?) {

        showAlert(controller: controller, message: message, style: .alert, cancelButton: "No", distrutiveButton: nil, otherButtons: ["Yes"], completion: completion)

    }

    /// Use this method to display an **ActionSheet** for Image Picker confirmation on any viewController.
    ///
    /// - Parameters:
    ///   - controller: Object of controller on which you need to display an Alert
    ///   - message: String Message which you want to display.
    ///   - completion: You will get the call back here when user tap on the button from the alert.
    ///
    ///     - Index For "Use Gallery" button = 0
    ///     - Index For "Use Camera" button = 1
    ///     - Index For "Cancel" button = 2
    class func showActionsheetForImagePicker(controller: AnyObject ,
                                             message: String? = nil ,
                                             completion: ((Int, String) -> Void)?) {

        showAlert(controller: controller, message: message, style: .actionSheet, cancelButton: "Cancel", distrutiveButton: nil, otherButtons: ["Use Gallery", "Use Camera"], completion: completion)

    }

}
