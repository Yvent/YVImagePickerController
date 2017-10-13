# YVImagePickerController
支持单选，多选，视频和图片，多图合成幻灯片

![image](https://github.com/Yvent/YVImagePickerController/blob/master/Resource/demo.png)

1.首先将 YVImagePickerController文件夹中的文件 拖入项目

2.在plist文件中加入

 ````
  <key>NSPhotoLibraryUsageDescription</key>
    <string>App需要您的同意,才能访问相册</string>
````
3.
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

实现代理方法 
````
 func yvimagePickerController(_ picker: YVImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) { }
    
 func yvimagePickerControllerDidCancel(_ picker: YVImagePickerController) {}
````
我的博客http://www.jianshu.com/p/ae85bcd5ec73
