//
//  IconboxPickerView.swift
//  IconboxPicker
//
//  Created by mk on 2020/11/26.
//

import SwiftUI

@available(iOS 14, *)
public struct IconboxPickerView: UIViewControllerRepresentable {
    public var keyword: String
    public var complete: ((UIImage?) -> ())
    
    public init(keyword: String, complete: @escaping ((UIImage?) -> ())) {
        self.keyword = keyword
        self.complete = complete
    }
    
    public func makeUIViewController(context: Context) -> UIActivityViewController {
        let viewController = IconboxPicker.shared.createActionPicker(keyword: keyword) { (image) in
            if let image = image {
                complete(image)
            }
        }
        return viewController!
    }
    
    public func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        
    }

}
