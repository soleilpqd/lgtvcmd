#
# Be sure to run `pod lib lint ConnectSDK-Mac.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ConnectSDK-Mac'
  s.version          = '1.6.0'
  s.summary          = 'Connect SDK is an open source framework that connects your mobile apps with multiple TV platforms.'
  s.description      = <<-DESC
                    Connect SDK is an open source framework that connects your mobile apps with multiple TV platforms. Because most TV platforms support a variety of protocols, Connect SDK integrates and abstracts the discovery and connectivity between all supported protocols.
                    To discover supported platforms and protocols, Connect SDK uses SSDP to discover services such as DIAL, DLNA, UDAP, and Roku's External Control Guide (ECG). Connect SDK also supports ZeroConf to discover devices such as Chromecast and Apple TV. Even while supporting multiple discovery protocols, Connect SDK is able to generate one unified list of discovered devices from the same network.
                    To communicate with discovered devices, Connect SDK integrates support for protocols such as DLNA, DIAL, SSAP, ECG, AirPlay, Chromecast, UDAP, and webOS second screen protocol. Connect SDK intelligently picks which protocol to use depending on the feature being used.
                    For example, when connecting to a 2013 LG Smart TV, Connect SDK uses DLNA for media playback, DIAL for YouTube launching, and UDAP for system controls. On Roku, media playback and system controls are made available through ECG, and YouTube launching through DIAL. On Chromecast, media playback occurs through the Cast protocol and YouTube is launched via DIAL.
                    To support the aforementioned use case without Connect SDK, a developer would need to implement DIAL, ECG, Chromecast, and DLNA in their app. With Connect SDK, discovering the three devices is handled for you. Furthermore, the method calls between each protocol is abstracted. That means you can use one method call to beam a video to Roku, 3 generations of LG Smart TVs, Apple TV, and Chromecast.
                   DESC

  s.homepage         = 'http://www.connectsdk.com/'
  s.license          = { :type => "Apache License, Version 2.0", :file => "LICENSE" }
  s.author           = { "Connect SDK" => "support@connectsdk.com" }
  s.source           = { :git => "https://github.com/ConnectSDK/Connect-SDK-iOS.git", :tag => s.version.to_s }
  s.prefix_header_contents = <<-PREFIX
                                  //
                                  //  Prefix header
                                  //
                                  //  The contents of this file are implicitly included at the beginning of every source file.
                                  //
                                  //  Copyright (c) 2015 LG Electronics.
                                  //
                                  //  Licensed under the Apache License, Version 2.0 (the "License");
                                  //  you may not use this file except in compliance with the License.
                                  //  You may obtain a copy of the License at
                                  //
                                  //      http://www.apache.org/licenses/LICENSE-2.0
                                  //
                                  //  Unless required by applicable law or agreed to in writing, software
                                  //  distributed under the License is distributed on an "AS IS" BASIS,
                                  //  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
                                  //  See the License for the specific language governing permissions and
                                  //  limitations under the License.
                                  //
                                  #define CONNECT_SDK_VERSION @"#{s.version}"
                                  // Uncomment this line to enable SDK logging
                                  //#define CONNECT_SDK_ENABLE_LOG
                                  #ifndef kConnectSDKWirelessSSIDChanged
                                  #define kConnectSDKWirelessSSIDChanged @"Connect_SDK_Wireless_SSID_Changed"
                                  #endif
                                  #ifdef CONNECT_SDK_ENABLE_LOG
                                      // credit: http://stackoverflow.com/a/969291/2715
                                      #ifdef DEBUG
                                      #   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
                                      #else
                                      #   define DLog(...)
                                      #endif
                                  #else
                                      #   define DLog(...)
                                  #endif
                               PREFIX

  s.platform     = :osx, "10.12"

  s.source_files = 'Classes/**/*'
  s.libraries = "z", "icucore"
  
  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
