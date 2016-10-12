//
//  FirstViewController.swift
//  Bonapp
//
//  Created by Jonas Larsen on 06/10/2016.
//  Copyright © 2016 Jonas Larsen. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import TesseractOCR
import FirebaseAuth
import Firebase


class FirstViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var imageVIew: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var imagePicker: UIImagePickerController!
    var picData: Data?
    var lines: [Line]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        progressView.progress = 0
        progressView.isHidden = true
        activityIndicator.hidesWhenStopped = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func takePhoto(_ sender: AnyObject) {
//        imagePicker =  UIImagePickerController()
//        imagePicker.delegate = self
//        imagePicker.sourceType = .camera
//        present(imagePicker, animated: true, completion: nil)
        
        analysePicture(image: #imageLiteral(resourceName: "føtexBon"))
        
        
    }
    
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        analysePicture(image: image!)
        
    }
    
    func analysePicture(image: UIImage) {
        imageVIew.image = image
        activityIndicator.startAnimating()
        DispatchQueue.global(qos: .background).async {
            
            let tesseract = G8Tesseract(language: "dan+eng")
            if let tes = tesseract {
                
                tes.pageSegmentationMode = .auto
                tes.maximumRecognitionTime = 30
                tes.image = image.g8_blackAndWhite()
                tes.recognize()
                
                debugPrint(tes.recognizedText)
                let stores = OCR.getStores(tes.recognizedText)
                let total = OCR.getTotalAmount(tes.recognizedText, store: stores.first).first
                let products = OCR.getProducts(from: tes.recognizedText, store: stores.first)
                DispatchQueue.main.async {
                    self.textView.text = stores.reduce("Butik: ") { result, current in
                        "\(result ?? "")  \(current.name)"
                    }
                    self.textView.text = self.textView.text! + " \nTotal: " + (total != nil ? String(describing: total!) : "ukendt")
                    self.textView.text = self.textView.text! + products.reduce("\n Produkter: \n ") { result, current in
                        result + current.description + ", \n   "
                    }
                    debugPrint(products)
                    self.activityIndicator.stopAnimating()
                    
                    
                    let storeName = stores.flatMap { store in
                        store.name != "" ? store.name : nil
                    }
                    
                    guard let user = FIRAuth.auth()?.currentUser else {
                        return
                    }
                    
                    let receipt = Receipt(products: products, total: total, storeName: storeName.first ?? "", ownerUid: user.uid)
                    FirebaseUtility.write(receipt: receipt)
                }
            }
        }
    }
    
    
    func uploadToAzureOCR(data: Data?) {

        guard let data = data else { return }

        debugPrint("started upload")
        let url = "https://api.projectoxford.ai/vision/v1.0/ocr?language=unk&detectOrientation=true"
        let headers: HTTPHeaders = [
            "Ocp-Apim-Subscription-Key":"24ddf036c57b4e93965f8b336daa6f13",
            "Content-Type":"application/octet-stream"
        ]
        Alamofire.upload(data, to: url, headers: headers).uploadProgress { (hej) in
            debugPrint(hej.fractionCompleted)
            self.progressView.progress = Float(hej.fractionCompleted)
        }.responseJSON { response in
            self.progressView.progress = 0
            switch response.result {
            case .success:
                let json = JSON(response.result.value)

                self.lines = self.parseJsonToLines(json)
                self.analyseLines(lines: self.lines)
            case .failure(let error):
                debugPrint("Request failed with error: \(error)")
                
            }
            
        }
    }
    
    
    func parseJsonToLines(_ json: JSON) -> [Line] {
        var lines: [Line] = []
        
        for (_,subJson):(String, JSON) in json["regions"]{
            for (_,line):(String, JSON) in subJson["lines"]{
                
                var words: [Word] = []
                for (_,word):(String, JSON) in line["words"]{
                    
                    guard let box = getBoundingBox(line["boundingBox"].string) else {
                        continue
                    }
                    let text = word["text"].string ?? ""
                    let word = Word(box: box, text: text)
                    
                    words.append(word)
                }
                
                guard let box = getBoundingBox(line["boundingBox"].string) else {
                    continue
                }
                let line = Line(box: box, words: words)
                lines.append(line)
            }
        }
        
        return lines
    }
    
    func getBoundingBox(_ str: String?) -> BoundingBox? {
        guard let input = str else {
            return nil
        }
        
        let components = input.components(separatedBy: ",")
        
        guard components.count == 4 else {
            return nil
        }
        
        let x = Int(components[0])!
        let y = Int(components[1])!
        let width = Int(components[2])!
        let heigth = Int(components[3])!
        
        return BoundingBox(x: x, y: y, width: width, heigth: heigth)
    }
    
    
    func analyseLines(lines: [Line]?) {
        textView.text = ""

        guard let lines = lines else { return }
        
        // Get all words
        let words = Set(lines.flatMap {
            $0.words.map {
                $0.text.lowercased()
            }
        })
        
        let wordObjects = lines.flatMap {
            $0.words.map {
                $0
            }
        }
        
        // Find store
        let føtexWords = Set(["fotex", "foetex", "føtex", "fctex", "fttex", "www.foetex.dk"])
        let nettoAlias = Set(["netto", "*etto", "netto.", "www.netto.dk", ".netto"])
        
        if !føtexWords.isDisjoint(with: words) {
            debugPrint("FOUND FØTEX")
            textView.text = textView.text + "\n Butik: Føtex"
        } else if !nettoAlias.isDisjoint(with: words) {
            debugPrint("FOUND NETTTO")

            textView.text = textView.text + "\n Butik: Netto"
        } else {
            debugPrint("Couldn't find store")
            debugPrint(words)
            textView.text = textView.text + "\n Butik: ingen :("
        }
        
        // Find total keyword
        let totalAlias = ["total","toi", "al", "votai", "tai", "vo"]
        
        let matchingWords = wordObjects.filter { word in
            totalAlias.contains(word.text.lowercased())
        }
        
        guard matchingWords.count != 0 else {
            debugPrint("Nothing matching total ")
            debugPrint(words)
            
            textView.text = textView.text + "\n Total: ingen :("

            return
        }
        
        let total = matchingWords.first!
        let deviation = 30
        let totalY = total.box.y
        
        // Find words within deviation (on the same line)
        let deviationWords = wordObjects.filter { word in
            abs(word.box.y - totalY) <= deviation
        }
        
        // Remove total aliases
        let totalValues = deviationWords.filter { word in
            !totalAlias.contains(word.text.lowercased())
        }
        
        if totalValues.count > 0 {

            textView.text = textView.text + "\n Total: \(totalValues.map {$0.text})".replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
        } else {
            textView.text = textView.text + "\n Total: ingen :("
        }
        
        
        debugPrint("deviationWords: \(deviationWords.map {$0.text})")
    }
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        try?    FIRAuth.auth()?.signOut()
    }
}

