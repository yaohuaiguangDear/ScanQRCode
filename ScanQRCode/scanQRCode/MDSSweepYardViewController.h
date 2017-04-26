//
//  MDSSweepYardViewController.h
//  FamilyDoctor
//
//  Created by yao on 15/11/11.
//  Copyright © 2015年 yao. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ScanQRCode)(NSString * code, BOOL success);

@interface MDSSweepYardViewController : UIViewController

- (void)scanQRCode:(ScanQRCode)code;

@end
