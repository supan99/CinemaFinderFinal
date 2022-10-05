//
//  AddMovieViewController.swift
//  CinemaFinder


import UIKit
import Photos

class AddMovieViewController: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var textFieldName: UITextField!
    @IBOutlet weak var textFieldCast: UITextField!
    @IBOutlet weak var textFieldDirectorName: UITextField!
    @IBOutlet weak var btnAdd: UIButton!
    
    var data: MovieModel!
    var imgPicker = UIImagePickerController()
    var imgPicker1 = OpalImagePickerController()
    var isImageSelected : Bool = false
    var isImageChange : Bool = false
    var imageURL = ""
    var img = UIImage()
    
    
    @IBAction func btnClick(_ sender: UIButton) {
        let error = self.validation(name: self.textFieldName.text ?? "", cast: self.textFieldCast.text ?? "", dName: self.textFieldDirectorName.text ?? "")
        
        if error.isEmpty {
            
            self.uploadImagePic(img1: self.img, name: self.textFieldName.text?.trim() ?? "", cast: self.textFieldCast.text?.trim() ?? "", dName: self.textFieldDirectorName.text?.trim() ?? "",isUpdate: data != nil)
        }else{
            Alert.shared.showAlert(message: error, completion: nil)
        }
    }
    
    @IBAction func btnClickLogout(_ sender: UIButton) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        UIApplication.shared.setStart()
    }
    
    private func validation(name: String, cast: String, dName: String) -> String {
        if !isImageSelected {
            return "Please select image"
        }else if name.isEmpty {
            return STRING.errorEnterMovieName
        } else if cast.isEmpty {
            return STRING.errorEnterCast
        } else if dName.isEmpty {
            return STRING.errorEnterDName
        }else {
            return ""
        }
    }
    
    func openCameraOptions(){
        
        let actionSheet = UIAlertController(title: nil, message: "Select Image", preferredStyle: .actionSheet)
        
        let cameraPhoto = UIAlertAction(title: "Camera", style: .default, handler: {
            (alert: UIAlertAction) -> Void in
            guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                return Alert.shared.showAlert(message: "Camera not Found", completion: nil)
            }
            GFunction.shared.isGiveCameraPermissionAlert(self) { (isGiven) in
                if isGiven {
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.imgPicker.mediaTypes = ["public.image"]
                        self.imgPicker.sourceType = .camera
                        self.imgPicker.cameraDevice = .rear
                        self.imgPicker.allowsEditing = true
                        self.imgPicker.delegate = self
                        self.present(self.imgPicker, animated: true)
                    }
                }
            }
        })
        
        let PhotoLibrary = UIAlertAction(title: "Gallary", style: .default, handler:
                                            { [self]
            (alert: UIAlertAction) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
                let photos = PHPhotoLibrary.authorizationStatus()
                if photos == .denied || photos == .notDetermined {
                    PHPhotoLibrary.requestAuthorization({status in
                        if status == .authorized {
                            DispatchQueue.main.async {
                                self.imgPicker1 = OpalImagePickerController()
                                self.imgPicker1.imagePickerDelegate = self
                                self.imgPicker1.isEditing = true
                                present(self.imgPicker1, animated: true, completion: nil)
                            }
                        }
                    })
                }else if photos == .authorized {
                    DispatchQueue.main.async {
                        self.imgPicker1 = OpalImagePickerController()
                        self.imgPicker1.imagePickerDelegate = self
                        self.imgPicker1.isEditing = true
                        present(self.imgPicker1, animated: true, completion: nil)
                    }
                    
                }
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction) -> Void in
            
        })
        
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        actionSheet.addAction(cameraPhoto)
        actionSheet.addAction(PhotoLibrary)
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.btnAdd.layer.cornerRadius = 10.0
        
        if self.data != nil {
            self.textFieldName.text = self.data.name
            self.textFieldCast.text = self.data.starCast
            self.textFieldDirectorName.text = self.data.dName
            self.imgProfile.setImgWebUrl(url: self.data.imageurl, isIndicator: true)
            self.isImageSelected = true
        }
        self.imgProfile.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer()
        tap.addAction {
            self.openCameraOptions()
        }
        self.imgProfile.addGestureRecognizer(tap)
    }
    
    func addMovieData(name:String,cast: String,dName: String) {
        var ref : DocumentReference? = nil
        ref = Firestore.firestore().collection(cMovie).addDocument(data:
                                                                    [
                                                                        cMID: "",
                                                                        cMName : name,
                                                                        cMCast: cast,
                                                                        cMDName: dName,
                                                                        cImageURL: self.imageURL
                                                                    ])
        {  err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
                self.update(dataID: ref!.documentID,name: name,cast: cast,dName: dName)
            }
        }
    }
    
    func update(dataID: String,name:String,cast: String,dName: String) {
        let ref = Firestore.firestore().collection(cMovie).document(dataID)
        ref.updateData([
            cMID: dataID,
            cMName : name,
            cMCast: cast,
            cMDName: dName,
            cImageURL: self.imageURL
        ]){ err in
            if let err = err {
                print("Error updating document: \(err)")
                self.navigationController?.popViewController(animated: true)
            } else {
                Alert.shared.showAlert(message: self.data != nil ? "Your Movie has been updated successfully !!!" : "Your Movie has been added successfully !!!") { (true) in
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
}


//MARK:- UIImagePickerController Delegate Methods
@available(iOS 15.0.0, *)
extension AddMovieViewController: UIImagePickerControllerDelegate, OpalImagePickerControllerDelegate {
    func uploadImagePic(img1 :UIImage, name:String,cast: String,dName: String,isUpdate: Bool){
        if self.isImageChange {
            let data = img1.jpegData(compressionQuality: 0.8)! as NSData
            // set upload path
            let imagePath = GFunction.shared.UTCToDate(date: Date())
            let filePath = "movies/\(imagePath)" // path where you wanted to store img in storage
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpg"
            
            let storageRef = Storage.storage().reference(withPath: filePath)
            storageRef.putData(data as Data, metadata: metaData) { (metaData, error) in
                if let error = error {
                    return
                }
                storageRef.downloadURL(completion: { (url: URL?, error: Error?) in
                    self.isImageSelected = true
                    self.imageURL = url?.absoluteString ?? ""
                    print(url?.absoluteString) // <- Download URL
                    
                    isUpdate ? self.update(dataID: self.data.docID, name: name, cast: cast, dName: dName) : self.addMovieData(name: name, cast: cast, dName: dName)
                    
                })
            }
        }else{
            self.imageURL = self.data.imageurl
            self.update(dataID: self.data.docID, name: name, cast: cast, dName: dName)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        defer {
            picker.dismiss(animated: true)
        }
        if let image = info[.editedImage] as? UIImage {
            self.img = image
            self.imgProfile.image = image
            self.isImageSelected = true
            self.isImageChange = true
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        do { picker.dismiss(animated: true) }
    }
    
    func imagePicker(_ picker: OpalImagePickerController, didFinishPickingAssets assets: [PHAsset]){
        for image in assets {
            if let image = getAssetThumbnail(asset: image) as? UIImage {
                self.img = image
                self.imgProfile.image = image
                self.isImageSelected = true
                self.isImageChange = true
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    func getAssetThumbnail(asset: PHAsset) -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        option.isSynchronous = true
        manager.requestImage(for: asset, targetSize: CGSize(width: (asset.pixelWidth), height: ( asset.pixelHeight)), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
            thumbnail = result!
        })
        return thumbnail
    }
    
    func imagePickerDidCancel(_ picker: OpalImagePickerController){
        dismiss(animated: true, completion: nil)
    }
}
