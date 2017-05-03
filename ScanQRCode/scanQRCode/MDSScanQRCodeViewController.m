//
//  MDSSweepYardViewController.m
//  FamilyDoctor
//
//  Created by yao on 15/11/11.
//  Copyright © 2015年 yao. All rights reserved.
//

#import "MDSScanQRCodeViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "LBXScanVideoZoomView.h"
#import "StyleDIY.h"
#import "UIColor+NotRGB.h"

@interface MDSScanQRCodeViewController ()
/**
 @brief  扫码区域上方提示文字
 */
@property (nonatomic, strong) UILabel *topTitle;
@property (nonatomic, strong) UILabel *topSecondTitle;
@property (nonatomic, strong) LBXScanVideoZoomView *zoomView;
@property (nonatomic, strong) ScanQRCode qrcode;
@property (nonatomic, strong) ScanQRCodeRightButtonAction rightButton;
@end

@implementation MDSScanQRCodeViewController
- (id)init
{
    if (self == [super init]) {
        
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)scanQRCode:(ScanQRCode)code{
    self.qrcode = code;
}

- (void)rightButtonAction:(ScanQRCodeRightButtonAction)rightButton{
    self.rightButton = rightButton;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self.view.backgroundColor = [UIColor blackColor];
    
    //设置扫码后需要扫码图像
    self.isNeedScanImage = YES;
    [self setRightButton];
}

- (void)setRightButton{
    self.style = [StyleDIY qqStyle];
    if (self.parameterDict) {
        self.titleName = self.parameterDict[@"qrcodeTitle"];
        self.topString = [self.parameterDict[@"module"] firstObject][@"text"];
        self.topSecondString = self.parameterDict[@"tips"];
        self.buttonText = [self.parameterDict[@"right"] firstObject][@"buttonText"];
        self.router = [self.parameterDict[@"right"] firstObject][@"router"];
        self.title = self.titleName;
    }
    
    
    
    
    
    UIBarButtonItem *rightBarBtn = [[UIBarButtonItem alloc]initWithTitle:self.buttonText style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonClicked)];
    [rightBarBtn setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:16.f],NSFontAttributeName, nil] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = rightBarBtn;
    
    if (self.parameterDict) {
        NSString *hexColor = [self.parameterDict[@"right"] firstObject][@"buttonTextColor"];
        if (hexColor.length > 6) {
            UIColor * buttonColor = [UIColor colorWithHexString:hexColor];
            [self.navigationItem.rightBarButtonItem setTintColor:buttonColor];

        }
    }
}

- (void)rightButtonClicked{
    self.rightButton(self.router);
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    
    [self drawBottomItems];
    [self drawTitle];
    [self.view bringSubviewToFront:_topTitle];
    
    
}

- (float)getContentHeightWithcontentString:(NSString *)content{
    CGSize size = [content boundingRectWithSize:CGSizeMake(CGRectGetWidth(self.view.frame) - 28, 60) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil].size;
    NSLog(@"%f", size.width);
    return size.width;
}

//绘制扫描区域
- (void)drawTitle
{
    if (!_topTitle)
    {
        self.topTitle = [[UILabel alloc]init];
        _topTitle.bounds = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 60);
        _topTitle.center = CGPointMake(CGRectGetWidth(self.view.frame)/2, 50);
        _topTitle.font = [UIFont systemFontOfSize:18];
        if (self.parameterDict) {
            NSString *hexColor = [self.parameterDict[@"module"] firstObject][@"color"];
            if (hexColor.length > 6) {
                _topTitle.textColor = [UIColor colorWithHexString:hexColor];
            }
        }
        
        
        
        _topTitle.textAlignment = NSTextAlignmentCenter;
        _topTitle.numberOfLines = 1;
        _topTitle.text = self.topString;
        _topTitle.textColor = [UIColor whiteColor];
        [self.view addSubview:_topTitle];
    }
    if (!_topSecondTitle)
    {
        CGFloat width = [self getContentHeightWithcontentString:self.topSecondString];
       NSLog(@"%f", width);
        self.topSecondTitle = [[UILabel alloc]init];
        _topSecondTitle.bounds = CGRectMake(0, 0, width + 20, 40);
        _topSecondTitle.center = CGPointMake(CGRectGetWidth(self.view.frame)/2, 100);
        _topSecondTitle.font = [UIFont systemFontOfSize:14];
        _topSecondTitle.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
        _topSecondTitle.textAlignment = NSTextAlignmentCenter;
        _topSecondTitle.numberOfLines = 1;
        _topSecondTitle.text = self.topSecondString;
        _topSecondTitle.textColor = [UIColor whiteColor];
        _topSecondTitle.layer.cornerRadius = 5;
        _topSecondTitle.layer.masksToBounds = YES;
        [self.view addSubview:_topSecondTitle];
    }
}

- (void)cameraInitOver
{
    if (self.isVideoZoom) {
        [self zoomView];
    }
}

- (LBXScanVideoZoomView*)zoomView
{
    if (!_zoomView)
    {
        
        CGRect frame = self.view.frame;
        
        int XRetangleLeft = self.style.xScanRetangleOffset;
        
        CGSize sizeRetangle = CGSizeMake(frame.size.width - XRetangleLeft*2, frame.size.width - XRetangleLeft*2);
        
        if (self.style.whRatio != 1)
        {
            CGFloat w = sizeRetangle.width;
            CGFloat h = w / self.style.whRatio;
            
            NSInteger hInt = (NSInteger)h;
            h  = hInt;
            
            sizeRetangle = CGSizeMake(w, h);
        }
        
        CGFloat videoMaxScale = [self.scanObj getVideoMaxScale];
        
        //扫码区域Y轴最小坐标
        CGFloat YMinRetangle = frame.size.height / 2.0 - sizeRetangle.height/2.0 - self.style.centerUpOffset;
        CGFloat YMaxRetangle = YMinRetangle + sizeRetangle.height;
        
        CGFloat zoomw = sizeRetangle.width + 40;
        _zoomView = [[LBXScanVideoZoomView alloc]initWithFrame:CGRectMake((CGRectGetWidth(self.view.frame)-zoomw)/2, YMaxRetangle + 40, zoomw, 18)];
        
        [_zoomView setMaximunValue:videoMaxScale/4];
        
        
        __weak __typeof(self) weakSelf = self;
        _zoomView.block= ^(float value)
        {
            [weakSelf.scanObj setVideoScale:value];
        };
        [self.view addSubview:_zoomView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap)];
        [self.view addGestureRecognizer:tap];
    }
    _zoomView.hidden = YES;
    return _zoomView;
    
}

- (void)tap
{
//    _zoomView.hidden = !_zoomView.hidden;
}

- (void)drawBottomItems
{
    if (_bottomItemsView) {
        
        return;
    }
    self.bottomItemsView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMinY(self.zoomView.frame) + 10,
                                                                   CGRectGetWidth(self.view.frame), 100)];
    _bottomItemsView.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:_bottomItemsView];
    
    CGSize size = CGSizeMake(65, 87);
    self.btnFlash = [[UIButton alloc]init];
    _btnFlash.bounds = CGRectMake(0, 0, size.width, size.height);
    _btnFlash.center = CGPointMake(CGRectGetWidth(_bottomItemsView.frame)/2, CGRectGetHeight(_bottomItemsView.frame)/2);
    [_btnFlash setImage:[UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_btn_flash_nor"] forState:UIControlStateNormal];
    [_btnFlash addTarget:self action:@selector(openOrCloseFlash) forControlEvents:UIControlEventTouchUpInside];
    
   
    
    [_bottomItemsView addSubview:_btnFlash];
 
    
}


- (void)scanResultWithArray:(NSArray<LBXScanResult*>*)array
{
    if (array.count < 1)
    {
        
        return;
    }
    
    //经测试，可以同时识别2个二维码，不能同时识别二维码和条形码
    for (LBXScanResult *result in array) {
        
        NSLog(@"scanResult:%@",result.strScanned);
    }
    
    LBXScanResult *scanResult = array[0];
    
    NSString*strResult = scanResult.strScanned;
    
    self.scanImage = scanResult.imgScanned;
    
    
    
    //震动提醒
    // [LBXScanWrapper systemVibrate];
    //声音提醒
    //[LBXScanWrapper systemSound];
    
    NSLog(@"扫码成功：%@", strResult);
    self.qrcode(strResult, YES);
    [self.navigationController popViewControllerAnimated:YES];
}





//开关闪光灯
- (void)openOrCloseFlash
{
    
    [super openOrCloseFlash];
    
    
    if (self.isOpenFlash)
    {
        [_btnFlash setImage:[UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_btn_flash_down"] forState:UIControlStateNormal];
    }
    else
        [_btnFlash setImage:[UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_btn_flash_nor"] forState:UIControlStateNormal];
}



@end
