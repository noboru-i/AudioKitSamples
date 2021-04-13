//
//  FilePicker.swift
//  AudioKitSamples
//
//  Created by noboru_ishikura on 2021/04/13.
//

import SwiftUI

protocol FilePickerDelegate {
    func onFileSelected(_ url: URL)
}

struct FilePickerController: UIViewControllerRepresentable {
    var delegate: FilePickerDelegate
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: UIViewControllerRepresentableContext<FilePickerController>) {
        // Update the controller
    }
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        print("Making the picker")
        let controller = UIDocumentPickerViewController(documentTypes: [String("public.data")], in: .open)
        
        controller.delegate = context.coordinator
        print("Setup the delegate \(context.coordinator)")
        
        return controller
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: FilePickerController
        
        init(_ pickerController: FilePickerController) {
            self.parent = pickerController
            print("Setup a parent")
            print("Callback: \(parent.delegate)")
        }
       
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            print("Selected a document: \(urls[0])")
            parent.delegate.onFileSelected(urls[0])
        }
        
        func documentPickerWasCancelled() {
            print("Document picker was thrown away :(")
        }
        
        deinit {
            print("Coordinator going away")
        }
    }
}
