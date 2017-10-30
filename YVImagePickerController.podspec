#
#  Be sure to run `pod spec lint YVImagePickerController.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  s.name         = "YVImagePickerController"
  s.version      = "1.0.8"
  s.summary      = "Instead of UIImagePickerController."

  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  s.description  = "Instead of UIImagePickerController. multi-select photos"

  s.homepage     = "https://github.com/Yvent/YVImagePickerController"



  s.license      = "MIT"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }



  s.author             = { "Yvent" => "Yvente@163.com" }



  s.source       = { :git => "https://github.com/Yvent/YVImagePickerController.git", :tag => "1.0.8"}



  s.source_files  = "YVImagePickerController/*"


  s.platform     = :ios, "9.0"

  s.ios.deployment_target = "9.0"

  s.resources          = "YVImagePickerController/YVImagePickerController.bundle"

end
