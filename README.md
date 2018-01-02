# YVImagePickerController
iOS -  支持单选，多选，视频和图片，多图合成幻灯片，视频剪辑

![image](https://github.com/Yvent/YVImagePickerController/blob/master/Resource/YVImagePickerController.gif)


Requirements
 ````
iOS 9.0+ 
Xcode 8.0+
Swift 3.0+
 ````


Step1
````
pod 'YVImagePickerController' ,'~> 1.1.1'
````
Step2
在plist文件中加入

 ````
  <key>NSPhotoLibraryUsageDescription</key>
    <string>App需要您的同意,才能访问相册</string>
````
Step3
````
 import Photos
````
遵守协议 YVImagePickerControllerDelegate
初始化
````
let pickerVC = YVImagePickerController()
self.present(pickerVC, animated: true, completion: nil)
````
配置

  | yvmaxSelected | 多选时最大张数 |
| --- | --- |
| yvcolumns | 每行列数 |
| topViewColor | 导航栏背景色 |
| yvmediaType  | 媒体类型：照片或视频  |
| yvIsMultiselect | 是否多选，默认单选  |
| selectedBtn_nimage | 多选时，未选中image(可选)  |
| selectedBtn_simage | 多选时，选中image(可选)  |


实现代理方法 
````
 func yvimagePickerController(_ picker: YVImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) { }
    
 func yvimagePickerControllerDidCancel(_ picker: YVImagePickerController) {}
````

问题

发现bug或好的建议欢迎 [issues](https://github.com/Yvent/YVImagePickerController/issues) or Email Yvente@163.com

