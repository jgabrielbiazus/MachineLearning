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
    var thePixelBuffer : CVPixelBuffer?
    
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

    func pixelBufferFromImage(image: UIImage) -> CVPixelBuffer {
            
            
            let ciimage = CIImage(image: image)
            //let cgimage = convertCIImageToCGImage(inputImage: ciimage!)
            let tmpcontext = CIContext(options: nil)
            let cgimage =  tmpcontext.createCGImage(ciimage!, from: ciimage!.extent)
            
            let cfnumPointer = UnsafeMutablePointer<UnsafeRawPointer>.allocate(capacity: 1)
            let cfnum = CFNumberCreate(kCFAllocatorDefault, .intType, cfnumPointer)
            let keys: [CFString] = [kCVPixelBufferCGImageCompatibilityKey, kCVPixelBufferCGBitmapContextCompatibilityKey, kCVPixelBufferBytesPerRowAlignmentKey]
            let values: [CFTypeRef] = [kCFBooleanTrue, kCFBooleanTrue, cfnum!]
            let keysPointer = UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: 1)
            let valuesPointer =  UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: 1)
            keysPointer.initialize(to: keys)
            valuesPointer.initialize(to: values)
            
            let options = CFDictionaryCreate(kCFAllocatorDefault, keysPointer, valuesPointer, keys.count, nil, nil)
           
            let width = cgimage!.width
            let height = cgimage!.height
         
            var pxbuffer: CVPixelBuffer?
            // if pxbuffer = nil, you will get status = -6661
            var status = CVPixelBufferCreate(kCFAllocatorDefault, width, height,
                                             kCVPixelFormatType_32BGRA, options, &pxbuffer)
            status = CVPixelBufferLockBaseAddress(pxbuffer!, CVPixelBufferLockFlags(rawValue: 0));
            
            let bufferAddress = CVPixelBufferGetBaseAddress(pxbuffer!);

            
            let rgbColorSpace = CGColorSpaceCreateDeviceRGB();
            let bytesperrow = CVPixelBufferGetBytesPerRow(pxbuffer!)
            let context = CGContext(data: bufferAddress,
                                    width: width,
                                    height: height,
                                    bitsPerComponent: 8,
                                    bytesPerRow: bytesperrow,
                                    space: rgbColorSpace,
                                    bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue);
            context?.concatenate(CGAffineTransform(rotationAngle: 0))
            context?.concatenate(__CGAffineTransformMake( 1, 0, 0, -1, 0, CGFloat(height) )) //Flip Vertical
    //        context?.concatenate(__CGAffineTransformMake( -1.0, 0.0, 0.0, 1.0, CGFloat(width), 0.0)) //Flip Horizontal
            

            context?.draw(cgimage!, in: CGRect(x:0, y:0, width:CGFloat(width), height:CGFloat(height)));
            status = CVPixelBufferUnlockBaseAddress(pxbuffer!, CVPixelBufferLockFlags(rawValue: 0));
            return pxbuffer!;
            
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

