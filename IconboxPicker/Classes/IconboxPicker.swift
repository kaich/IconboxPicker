//
//  IconBoxPicker.swift
//  DemoIcons
//
//  Created by mk on 2020/10/28.
//

import UIKit

public typealias IconBoxCompleteHandler = ((UIImage?) -> ())

enum IconboxAction: String {
    case iconPicker = "iconPicker"
    
    static let all: [IconboxAction] = [.iconPicker]
}

public enum IconboxPickerType {
    case scheme(scheme: String)
    case action(viewController: UIViewController)
}

public class IconboxPicker {
    public static let shared = IconboxPicker()
    fileprivate var id2handlers: [String : IconBoxCompleteHandler] = [:]
    
    /// 选择照片
    /// - Parameters:
    ///   - keyword: 关键字
    ///   - type: 类型
    ///   - complete: 完成回调
    public func pick(keyword: String, type: IconboxPickerType, complete: @escaping IconBoxCompleteHandler) {
        switch type {
        case .scheme(let scheme):
            schemePick(keyword: keyword, scheme: scheme, complete: complete)
        case .action(let viewController):
            actionPick(keyword: keyword, in: viewController, complete: complete)
        }
    }
    
    
    /// 处理URL Scheme
    /// - Parameter url: url
    public func hanlder(url: URL) {
        if let host = url.host {
            if let action = IconboxAction(rawValue: host) {
                switch action {
                case .iconPicker:
                    if let str = url.queryValue(for: "data") {
                        if let data = Data(base64Encoded: str) {
                            if let dic = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
                                if let uuid = dic["uuid"] as? String, let iconStr = dic["icon"] as? String {
                                    if let iconData = Data(base64Encoded: iconStr) {
                                        if let actionHandler = self.id2handlers[uuid], let icon = UIImage(data: iconData) {
                                            actionHandler(icon)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    /// 是否可以打开URL
    /// - Parameter url: url
    /// - Returns: true/false
    public func canHandle(url: URL) -> Bool {
        if let host = url.host {
            if IconboxAction(rawValue: host) != nil {
                return true
            }
        }
        return false
    }
    
    /// 判断是否安装iconbox
    /// - Returns: true/false
    public func checkIconboxInstalled() -> Bool {
        return UIApplication.shared.canOpenURL(URL(string: "iconbox://")!)
    }
    
    /// 选择图片（Scheme形式）
    /// - Parameters:
    ///   - keyword: 关键字
    ///   - scheme: 本App的URL Scheme
    ///   - complete: 完成回调
    fileprivate func schemePick(keyword: String, scheme: String, complete: @escaping IconBoxCompleteHandler) {
        do {
            let (uuid, payload) = try createPayload(keyword: keyword, scheme: scheme)
            if let uuid = uuid, let payload = payload?.base64EncodedString() {
                if let url = URL(string: "iconbox://\(IconboxAction.iconPicker.rawValue)?params=\(payload)") {
                    UIApplication.shared.open(url, options: [:]) { (isOK) in
                        if isOK {
                            self.id2handlers[uuid] = complete
                        }
                    }
                }
            }
        } catch {
            debugPrint(error)
        }
    }
    
    /// 选择图片（Action形式)
    /// - Parameters:
    ///   - keyword: 关键字
    ///   - viewController: ViewController
    ///   - complete: 完成回调
    fileprivate func actionPick(keyword: String, in viewController: UIViewController? = nil, complete: @escaping IconBoxCompleteHandler) {
        let containerVC = viewController ?? UIApplication.shared.rootViewController
        let activityVC = createActionPicker(keyword: keyword) { (image) in
            containerVC?.dismiss(animated: true, completion: nil)
        }
        if let activityVC = activityVC {
            containerVC?.present(activityVC, animated: true, completion: nil)
        }
        
    }
    
    /// 创建选择器
    /// - Parameters:
    ///   - keyword: 关键字
    ///   - complete: 完成回调
    /// - Returns: ViewController
    func createActionPicker(keyword: String, complete: @escaping IconBoxCompleteHandler) -> UIActivityViewController? {
        do {
            let (_, payload) = try createPayload(keyword: keyword)
            if let payload = payload {
                let item = NSExtensionItem()
                let attachment = NSItemProvider(item: payload as NSData, typeIdentifier: "com.kai.app.iconbox")
                item.attachments = [attachment]
                let activityVC = UIActivityViewController(activityItems: [item], applicationActivities: [])
                activityVC.completionWithItemsHandler = { (type, Bool, items, error) in
                    if let item = items?.first as? NSExtensionItem {
                        if let image = item.userInfo?["icon"] as? UIImage {
                            complete(image)
                        }
                    }
                }
                return activityVC
            }
        } catch {
            debugPrint(error)
        }
        return nil
    }
    
    /// 创建消息
    /// - Parameters:
    ///   - keyword: 关键字
    ///   - scheme: scheme
    /// - Throws: 错误
    /// - Returns: payload
    fileprivate func createPayload(keyword: String, scheme: String? = nil) throws -> (String?, Data?) {
        if let name = Bundle.main.infoDictionary![kCFBundleNameKey as String] as? String, let identifier = Bundle.main.infoDictionary![kCFBundleIdentifierKey as String] as? String {
            let uuid = UUID().uuidString
            var dic = [
                "name": name,
                "id": identifier,
                "keyword": keyword,
                "uuid": uuid
            ]
            if let scheme = scheme {
                dic["scheme"] = scheme
            }
            let data = try JSONSerialization.data(withJSONObject: dic, options: .fragmentsAllowed)
            return  (uuid, data)
        }
        return (nil, nil)
    }

}

fileprivate extension URL {
    func queryValue(for key: String) -> String? {
        return URLComponents(string: absoluteString)?
            .queryItems?
            .first(where: { $0.name == key })?
            .value
    }
    
}


extension UIApplication {
    var currentKeyWindow: UIWindow? {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .map { $0 as? UIWindowScene }
                .compactMap { $0 }
                .first?.windows
                .filter { $0.isKeyWindow }
                .first
        } else {
            return UIApplication.shared.windows.first
        }
    }
    
    var rootViewController: UIViewController? {
        currentKeyWindow?.rootViewController
    }
}
