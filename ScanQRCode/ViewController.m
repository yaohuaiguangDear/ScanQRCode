//
//  ViewController.m
//  ScanQRCode
//
//  Created by yao on 2017/4/26.
//  Copyright © 2017年 yao. All rights reserved.
//

#import "ViewController.h"
#import "MDSScanQRCodeViewController.h"
#import "StyleDIY.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)buttonAction:(id)sender {
    
    MDSScanQRCodeViewController *acan = [[MDSScanQRCodeViewController alloc] init];
    acan.style = [StyleDIY qqStyle];
    acan.titleName = @"扫码签到";
    acan.topString = @"杨浦区卫计委 在线学习系统";
    acan.topSecondString = @"将二维码放入框内，即可自动扫描";
    acan.buttonText = @"签到记录";
    //镜头拉远拉近功能
    acan.isVideoZoom = YES;
    [self.navigationController pushViewController:acan animated:YES];
    [acan scanQRCode:^(NSString *code, BOOL success) {
        NSLog(@"%@", code);
    }];
    [acan rightButtonAction:^(NSString *router) {
        NSLog(@"%@", router);
    }];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
