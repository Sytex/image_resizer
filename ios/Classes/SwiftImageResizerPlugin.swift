import Flutter
import UIKit

public class SwiftImageResizerPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "io.siteplan.image_resizer", binaryMessenger: registrar.messenger())
    let instance = SwiftImageResizerPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if(call.method == "resize") {
      let args = call.arguments as? [String: Any?]
      let filePath = args!["imagePath"] as? String
      let targetPath = args!["targetPath"] as? String
      let maxSize = args!["maxSize"] as? CGFloat
      self.resize(filePath!, targetPath: targetPath!, maxSize: maxSize!, result: result)
    } else {
      result(FlutterMethodNotImplemented)
    }
  }

  private func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
    let size = image.size

    let widthRatio  = targetSize.width  / size.width
    let heightRatio = targetSize.height / size.height

    // Figure out what our orientation is, and use that to form the rectangle
    var newSize: CGSize
    if(widthRatio > heightRatio) {
        newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
    } else {
        newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
    }

    // This is the rect that we've calculated out and this is what is actually used below
    let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

    // Actually do the resizing to the rect using the ImageContext stuff
    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
    image.draw(in: rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return newImage!
  }

  func saveImageToDocumentDirectory(_ chosenImage: UIImage, targetPath: String) -> String {

    let fileManager = FileManager.default
    
    do {
      let imageData = chosenImage.jpegData(compressionQuality: 1)
      try fileManager.createFile(atPath: targetPath, contents: imageData, attributes: nil)
      return targetPath
    } catch {
      print(error)
      print("file cant not be save at path \(targetPath), with error : \(error)");
      return targetPath
    }
  }


  private func resize(_ filePath: String, targetPath: String, maxSize: CGFloat, result: @escaping FlutterResult) {
    let image = UIImage(contentsOfFile: filePath)
    let resizedImage = self.resizeImage(image: image!, targetSize: CGSize(width: maxSize, height: maxSize))
    self.saveImageToDocumentDirectory(resizedImage, targetPath: targetPath)
    result(nil)
  }
}
