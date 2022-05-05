//
//  ViewController.swift
//  MachineLearning2
//
//  Created by João Gabriel Biazus de Quevedo on 04/05/22.
//

import UIKit
import CoreML

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet var canvaImage: UIImageView!
    @IBOutlet weak var animalLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func recognizeButton(_ sender: Any) {
        do {
            // 1. Create a MLModelConfiguration
            let config = MLModelConfiguration()
            
            // 2. Instanciar o modelo de ML que tu for usar
            let model = try SqueezeNet(configuration: config)
            
            // 3. Instanciar um input (tentaiva de acerto da imagem) pra predizer o numero em uma imagem
            let input = try SqueezeNetInput(imageWith: (canvaImage.image?.resize(size: CGSize(width: 227, height: 227))?.cgImage)!)
            
            // 4. Enviar o input pra ML e receber o resultado
            let output = try model.prediction(input: input)
            
            // 5. Mostrar o resultado
            DispatchQueue.main.async {
                self.animalLabel.text = output.classLabel.description
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    @IBAction func cameraButton(_ sender: Any) {
        
        let imagePicketController = UIImagePickerController()
        imagePicketController.delegate = self
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicketController.sourceType = .camera
            self.present(imagePicketController, animated: true, completion: nil)
        }else{
            print("Camera not available")
        }
        print("camera")
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        canvaImage.image = image
        self.dismiss(animated: true, completion: nil)
        print(canvaImage.bounds.size)
    }
}
extension UIImage {
    func resize(size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContext(size)
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

