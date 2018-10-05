# EFDownloader

一个普通的下载器，目前支持以下站点视频的批量下载：

- [x] [快手](https://live.kuaishou.com/)

## 环境

- iOS 9.0+
- Swift 4.0+
- Xcode 9.4.1
- CocoaPods 1.5.3

## 构建

- 安装 [XCode](https://developer.apple.com/xcode/) / [CocoaPods](https://github.com/CocoaPods/CocoaPods)；   
- 执行以下命令：

```
git clone git@github.com:EyreFree/EFDownloader.git; 
cd EFDownloader; 
pod install;
open EFDownloader.xcworkspace; 
```

## 使用

1. 获取你需要下载的用户的 ID，以快手为例，用户个人主页地址末尾的这段字符串就是了，如图所示：

![](https://github.com/EyreFree/EFDownloader/blob/master/Assets/1.jpg)

2. 修改 `AppDelegate.swift` 中的 `idList` 为你需要下载的用户 ID，比如工程中默认已经有三个用户 ID 了：

```swift
let idList = [
    "wenyou666",
    "3x3k7ay3dw638ue",
    "Lm_921206"
]
```

3. 点击 Xcode 左上角小三角，Run 即可，下载过程可查看控制台日志输出，某个视频下载失败时会自动重试 3 次（可修改 retryCount 值实现自定义）；

![](https://github.com/EyreFree/EFDownloader/blob/master/Assets/2.jpg)

4. 默认下载视频会放置于工程根目录下的 `Download` 文件夹内，祝愉快。

![](https://github.com/EyreFree/EFDownloader/blob/master/Assets/3.jpg)

## 作者

EyreFree，eyrefree@eyrefree.org

## 协议

<img src='https://www.gnu.org/graphics/gplv3-127x51.png' width='127' height='51'/>

EFDownloader 基于 GPLv3 协议进行分发和使用，更多信息参见[协议文件](/LICENSE)。
