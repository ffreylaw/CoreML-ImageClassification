//
//  ViewController.swift
//  CoreMLTest-01
//
//  Created by Geoffrey Ka-Hoi Law on 5/7/17.
//  Copyright © 2017 El Root. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let model = GoogLeNetPlaces()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    func runNetwork() {
        if let pixelBuffer = ImageProcessor.pixelBuffer(forImage: (predictView.image?.cgImage)!) {
            guard let prediction = try? model.prediction(sceneImage: pixelBuffer) else {
                fatalError("Unexpected runtime error")
            }
            var output = ""
            for keyValuePair in prediction.sceneLabelProbs.sorted(by: { $0.value > $1.value }) {
                output += "(key: \"\(keyValuePair.key)\", value: \(String(format: "%.8f", arguments: [keyValuePair.value])))\n"
            }
            predictText.text = String(describing: output)
//            print(prediction.sceneLabelProbs)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // get taken picture as UIImage
        let uiImg = info[UIImagePickerControllerEditedImage] as! UIImage
        
        // display the image in UIImage View
        predictView.image = resize(withImage: uiImg, scaledToSize: CGSize(width: 224, height: 224))
        
        // hide infoTextLabel
        infoTextLabel.isHidden = true
        
        // to keep track of which image is being displayed
        dismiss(animated: true, completion: nil)
    }
    
    func resize(withImage image: UIImage?, scaledToSize newSize: CGSize) -> UIImage? {
        let newWidth = newSize.width
        let newHeight = newSize.height
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image?.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func setupViews() {
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.title = "CoreML-ImageRecognition"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(handleReset))
        
        view.backgroundColor = .white
        
        view.addSubview(predictView)
        predictView.topAnchor.constraint(equalTo: view.topAnchor, constant: 8).isActive = true
        predictView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        predictView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -16).isActive = true
        predictView.heightAnchor.constraint(equalTo: predictView.widthAnchor).isActive = true
        predictView.addSubview(infoTextLabel)
        infoTextLabel.centerXAnchor.constraint(equalTo: predictView.centerXAnchor).isActive = true
        infoTextLabel.centerYAnchor.constraint(equalTo: predictView.centerYAnchor).isActive = true
        infoTextLabel.widthAnchor.constraint(equalTo: predictView.widthAnchor, constant: -16).isActive = true
        infoTextLabel.heightAnchor.constraint(equalTo: predictView.heightAnchor, constant: -16).isActive = true
        
        view.addSubview(runButton)
        runButton.topAnchor.constraint(equalTo: predictView.bottomAnchor, constant: 8).isActive = true
        runButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8).isActive = true
        runButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1/2 ,constant: -12).isActive = true
        runButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        view.addSubview(chooseButton)
        chooseButton.topAnchor.constraint(equalTo: predictView.bottomAnchor, constant: 8).isActive = true
        chooseButton.leftAnchor.constraint(equalTo: runButton.rightAnchor, constant: 8).isActive = true
        chooseButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1/2 ,constant: -12).isActive = true
        chooseButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        view.addSubview(predictText)
        predictText.topAnchor.constraint(equalTo: runButton.bottomAnchor, constant: 8).isActive = true
        predictText.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8).isActive = true
        predictText.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -16).isActive = true
        predictText.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8).isActive = true
    }
    
    @objc func handleRun() {
        if predictView.image != nil {
            // run the neural network to get predictions
            runNetwork()
        }
    }
    
    @objc func handleChoose() {
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Camera", style: .default) { (UIAlertAction) in self.openCamera() })
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default) { (UIAlertAction) in self.openPhotoLibrary() })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func openCamera() {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.sourceType = UIImagePickerControllerSourceType.camera
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    
    func openPhotoLibrary() {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    
    @objc func handleReset() {
        predictText.text = nil
        predictView.image = nil
        infoTextLabel.isHidden = false
    }
    
    let predictText: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.backgroundColor = .white
        textView.font = UIFont.preferredFont(forTextStyle: .callout)
        textView.layer.borderColor = UIColor.black.cgColor
        textView.layer.borderWidth = 1 / UIScreen.main.scale
        return textView
    }()
    
    let predictView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .white
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.layer.borderWidth = 1 / UIScreen.main.scale
        return imageView
    }()
    
    let infoTextLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.text = "Core ML"
        label.textColor = .lightGray
        label.textAlignment = NSTextAlignment.center
        label.numberOfLines = 0
        label.sizeToFit()
        return label
    }()
    
    lazy var runButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.setTitle("Run Network", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1 / UIScreen.main.scale
        button.addTarget(self, action: #selector(handleRun), for: .touchUpInside)
        return button
    }()
    
    lazy var chooseButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.setTitle("Choose Image", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1 / UIScreen.main.scale
        button.addTarget(self, action: #selector(handleChoose), for: .touchUpInside)
        return button
    }()

}

