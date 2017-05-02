//
//  MDSSweepYardViewController.h
//  FamilyDoctor
//
//  Created by yao on 15/11/11.
//  Copyright © 2015年 yao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LBXScanViewController.h"

@class MDSScanQRCodeViewController;
typedef void (^ScanQRCode)(NSString * code, BOOL success);
typedef void (^ScanQRCodeRightButtonAction)(NSString * router);

@interface MDSScanQRCodeViewController : LBXScanViewController

@property (nonatomic, strong) NSString *topString;
@property (nonatomic, strong) NSString *topSecondString;
//title
@property (nonatomic, strong) NSString *titleName;
@property (nonatomic, strong) NSString *buttonText;
@property (nonatomic, strong) NSString *router;
#pragma mark --增加拉近/远视频界面
@property (nonatomic, assign) BOOL isVideoZoom;

#pragma mark - 底部几个功能：开启闪光灯、相册、我的二维码
//底部显示的功能项
@property (nonatomic, strong) UIView *bottomItemsView;
//闪光灯
@property (nonatomic, strong) UIButton *btnFlash;

- (void)scanQRCode:(ScanQRCode)code;
- (void)rightButtonAction:(ScanQRCodeRightButtonAction)rightButton;
@end
