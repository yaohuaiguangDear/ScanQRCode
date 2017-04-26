//
//  MDSSweepYardViewController.m
//  FamilyDoctor
//
//  Created by yao on 15/11/11.
//  Copyright © 2015年 yao. All rights reserved.
//

#import "MDSSweepYardViewController.h"
#import <AVFoundation/AVFoundation.h>

#import "MDSDoctorDetailViewController.h"
#import "MDSHybridWebViewController.h"

@interface MDSSweepYardViewController ()<AVCaptureMetadataOutputObjectsDelegate>
{
    int num;
    BOOL upOrdown;
    NSTimer * timer;
}
@property (strong,nonatomic)AVCaptureDevice * device;
@property (strong,nonatomic)AVCaptureDeviceInput * input;
@property (strong,nonatomic)AVCaptureMetadataOutput * output;
@property (strong,nonatomic)AVCaptureSession * session;
@property (strong,nonatomic)AVCaptureVideoPreviewLayer * preview;
@property (nonatomic, retain) UIImageView * line;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, assign) BOOL isDis;
@property (nonatomic, strong) ScanQRCode qrcode;
@end

@implementation MDSSweepYardViewController
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
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake((ScreenWidth - 300) / 2,(ScreenHeight - 64 - 300) / 2,300,300)];
    
    imageView.image = [UIImage imageNamed:@"doc_saoma_corner"];
    [self.view addSubview:imageView];
    
    upOrdown = NO;
    num =0;
    _line = [[UIImageView alloc] initWithFrame:CGRectMake((ScreenWidth - 300) / 2, (ScreenHeight - 64 - 300) / 2, 300, 2)];
    _line.image = [UIImage imageNamed:@"doc_saoma_horiz"];
    [self.view addSubview:_line];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(animation1) userInfo:nil repeats:YES];
    

    // Do any additional setup after loading the view from its nib.
}
-(void)animation1
{
    if (upOrdown == NO) {
        num ++;
        _line.frame = CGRectMake((ScreenWidth - 300) / 2, (ScreenHeight - 64 - 300) / 2+2*num, 300, 2);
        if (2*num == 300) {
            upOrdown = YES;
        }
    }
    else {
        num --;
        _line.frame = CGRectMake((ScreenWidth - 300) / 2, (ScreenHeight - 64 - 300) / 2+2*num, 300, 2);
        if (num == 0) {
            upOrdown = NO;
        }
    }
    
}
-(void)backAction
{
    
    [self dismissViewControllerAnimated:YES completion:^{
        [timer invalidate];
    }];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"MDSSweepYardViewController"];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
     [MobClick beginLogPageView:@"MDSSweepYardViewController"];
    self.title = @"扫描医生二维码";
    [self setupCamera];
    if (self.isDis) {
        [self.navigationController popViewControllerAnimated:NO];
    }
}
- (void)setupCamera
{
    // Device
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Input
    _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    // Output
    _output = [[AVCaptureMetadataOutput alloc]init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // Session
    _session = [[AVCaptureSession alloc]init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([_session canAddInput:self.input])
    {
        [_session addInput:self.input];
    }
    
    if ([_session canAddOutput:self.output])
    {
        [_session addOutput:self.output];
    }
    
    // 条码类型 AVMetadataObjectTypeQRCode
    @try{
       _output.metadataObjectTypes =@[AVMetadataObjectTypeQRCode]; 
    }
    @catch(NSException *exception) {
        NSLog(@"exception:%@", exception);
    }
    @finally {
        
    }
    
    
    // Preview
    _preview =[AVCaptureVideoPreviewLayer layerWithSession:self.session];
    _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _preview.frame =CGRectMake((ScreenWidth - 300) / 2,(ScreenHeight - 64 - 300) / 2,300,300);
    [self.view.layer insertSublayer:self.preview atIndex:0];
    
    
    
    // Start
    [_session startRunning];
}
#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    
    NSString *stringValue;
    
    if ([metadataObjects count] >0)
    {
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = metadataObject.stringValue;
    }
    
    self.qrcode(stringValue, YES);
//    return;
//    if([stringValue rangeOfString:@"router://hybridWebView"].location !=NSNotFound){
//        [WMRouter openingPath:stringValue];
//    } else {
//        [_session stopRunning];
//        MDSHybridWebViewController *webview = [[MDSHybridWebViewController alloc] init];
//        webview.url = stringValue;
//        [self.navigationController pushViewController:webview animated:YES];
//        [timer invalidate];
//        timer = nil;
//        
//        self.isDis = YES;
//        return;
//    }
    [_session stopRunning];
    NSLog(@"%@",stringValue);
//    NSArray *dataArr = [stringValue componentsSeparatedByString:@"/"];
//    NSString *doctorId = dataArr[dataArr.count-1];
//    MDSDoctorDetailViewController *detail = [[MDSDoctorDetailViewController alloc] init];
//    detail.doctorId = doctorId;
//    self.title = @"";
//    
//    [detail setHidesBottomBarWhenPushed:YES];
//    [self.navigationController pushViewController:detail animated:YES];
    self.isDis = YES;
   
    [timer invalidate];
         
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
