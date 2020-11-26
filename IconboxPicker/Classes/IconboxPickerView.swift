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
    @Binding public var image: UIImage
    @Binding public var isShow: Bool
    
    public func makeUIViewController(context: Self.Context) -> UIActivityViewController {
        let viewController = IconboxPicker.shared.createActionPicker(keyword: keyword) { (image) in
            if let image = image {
                self.image = image
            }
            self.isShow = false
        }
        return viewController!
    }
    
    public func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        
    }

}
