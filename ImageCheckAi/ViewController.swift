//
//  ViewController.swift
//  ImageCheckAi
//
//  Created by 井手翔平 on 2024/01/12.
//
//画像認識したものがホットドッグかどうかを識別する



//フレームワークをインポートする
import UIKit
import CoreML
import Vision

//ビュー用のクラス
class ViewController: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate{

    @IBOutlet weak var imageView: UIImageView!
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //画像の初期設定みたいなもの
        //tyoeで.cameraにすればカメラで撮った画像にできる
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = userPickedImage
            
            guard let ciimage = CIImage(image:userPickedImage) else {
                fatalError("画像変換が失敗した")
            }
            detect(image: ciimage)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detect(image:CIImage) {
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("modelみつけれなかったよ")
        }
        
        let request = VNCoreMLRequest(model: model) {(request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("model faild to proess image.")
            }
            if let firstResult = results.first{
                if firstResult.identifier.contains("hotdog") {
                    self.navigationItem.title = "この写真はホットドッグだぜ！！"
                } else {
                    self.navigationItem.title = "おっと、この写真はホットドッグじゃないぜ、、、"
                }
            }
        }
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        }
        catch{
            print(error)
        }
    }

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
}

