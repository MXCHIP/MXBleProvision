#
# Be sure to run `pod lib lint BLEProvisioning.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MXBleProvision'
  s.version          = '1.0.6'
  s.summary          = 'A short description of MXBleProvision.'

  s.description      = "mxchip ble provisioning sdk"

  s.homepage         = 'https://rd.mxchip.com/mx/mx_sdk_ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'MXBleProvision' => 'zhanghf@mxchip.com' }
  s.source           = { :git => "https://github.com/MXCHIP/MXBleProvision.git" }

  s.ios.deployment_target = '12.0'

  s.static_framework = true
  s.vendored_frameworks = 'MXBleProvision.framework'
  
  s.dependency 'CryptoSwift'
  
  
end
