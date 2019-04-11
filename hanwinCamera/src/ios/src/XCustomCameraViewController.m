//
//  XCustomCameraViewController.m
//  iBooks
//
//  Created by PSY on 2019/3/26.
//  Copyright © 2019 XW. All rights reserved.
//

#import "XCustomCameraViewController.h"
#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMotion/CoreMotion.h>

@interface XCustomCameraViewController ()<AVCapturePhotoCaptureDelegate>
typedef enum {
    LEFT,
    RIGHT,
    UP,
    DOWN
} DeviceOrientation; // 设备方向

@property (weak, nonatomic) IBOutlet UIButton *flapBtn;
@property (weak, nonatomic) IBOutlet UIButton *flapAutoBtn;
@property (weak, nonatomic) IBOutlet UIButton *flapOpenBtn;
@property (weak, nonatomic) IBOutlet UIButton *flapCloseBtn;
@property (nonatomic, assign) BOOL isShowFlapOpt;

@property (weak, nonatomic) IBOutlet UIView *videoView;
@property (weak, nonatomic) IBOutlet UIImageView *photoImgView;

@property (weak, nonatomic) IBOutlet UIImageView *modelImgView;
@property (nonatomic, assign) BOOL isShowModelImage;

@property (weak, nonatomic) IBOutlet UIButton *takePhotoBtn;
@property (weak, nonatomic) IBOutlet UIButton *changeBtn;

//捕获设备，通常是前置摄像头，后置摄像头，麦克风（音频输入）
@property(nonatomic)AVCaptureDevice *device;
//AVCaptureDeviceInput 代表输入设备，他使用AVCaptureDevice 来初始化
@property(nonatomic)AVCaptureDeviceInput *input;
//当启动摄像头开始捕获输入
@property(nonatomic)AVCaptureMetadataOutput *output;
//照片输出流
@property (nonatomic, retain)AVCapturePhotoOutput *imageOutput;
@property (nonatomic, retain)AVCapturePhotoSettings *outputSettings;
@property (nonatomic, retain)CMMotionManager *motionManager;
@property (nonatomic, assign)DeviceOrientation deviceOrientation;
//session：由他把输入输出结合在一起，并开始启动捕获设备（摄像头）
@property(nonatomic)AVCaptureSession *session;
//图像预览层，实时显示捕获的图像
@property(nonatomic)AVCaptureVideoPreviewLayer *previewLayer;
@property (weak, nonatomic) IBOutlet UIView *chooseBgView;
@property (weak, nonatomic) IBOutlet UIImageView *chooseImageView;
@property (nonatomic, retain) NSData *chooseImgData;

@end

@implementation XCustomCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.chooseBgView setHidden:YES];
    self.takePhotoBtn.layer.cornerRadius = self.takePhotoBtn.bounds.size.height / 2;
    [self.flapAutoBtn setHidden:YES];
    [self.flapOpenBtn setHidden:YES];
    [self.flapCloseBtn setHidden:YES];
    [self.flapAutoBtn setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    
    
    if (![self checkCameraPrivate]) {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    if (self.imgUrl != nil && ![self.imgUrl isKindOfClass:[NSNull class]] && self.imgUrl.length != 0) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
           
            NSURL *url = [NSURL URLWithString:[self.imgUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet]];
            NSData *data = [NSData dataWithContentsOfURL:url];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.modelImgView setImage:[UIImage imageWithData:data]];
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showModelImgView)];
                [self.modelImgView setUserInteractionEnabled:YES];
                [self.modelImgView addGestureRecognizer:tap];
            });
        });
        
        
//        [self.modelImgView xsd_setImageWithURL:[NSURL URLWithString:[self.imgUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet]] completed:^(UIImage * _Nullable image, NSError * _Nullable error, NSURL * _Nullable imageURL) {
//            __strong typeof(self) sSelf = wSelf;
//            dispatch_async(dispatch_get_main_queue(), ^{
//                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:sSelf action:@selector(showModelImgView)];
//                [sSelf.modelImgView setUserInteractionEnabled:YES];
//                [sSelf.modelImgView addGestureRecognizer:tap];
//            });
//        }];
        
//        [self.modelImgView xsd_setImageWithURL:[NSURL URLWithString:[self.imgUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet]] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
//            __strong typeof(self) sSelf = wSelf;
//            dispatch_async(dispatch_get_main_queue(), ^{
//                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:sSelf action:@selector(showModelImgView)];
//                [sSelf.modelImgView setUserInteractionEnabled:YES];
//                [sSelf.modelImgView addGestureRecognizer:tap];
//            });
//        }];
    }
    
    self.deviceOrientation = UP;
    [self loadMotion];
    [self loadCamera];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self.previewLayer setFrame:CGRectMake(0, 0, self.videoView.frame.size.width, self.videoView.frame.size.height)];
}

- (void)showModelImgView
{
    self.isShowModelImage = !self.isShowModelImage;
    
    if (self.isShowModelImage) {
        [UIView animateWithDuration:0.3 animations:^{
            [self.modelImgView setFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        }];
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            [self.modelImgView setFrame:CGRectMake(8, [UIScreen mainScreen].bounds.size.height - 8 - 74, 74, 74)];
        }];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)loadMotion
{
    //创建CMMotionManager对象
    self.motionManager = [[CMMotionManager alloc] init];  // ①
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    //如果CMMotionManager的支持获取陀螺仪数据
    if (self.motionManager.gyroAvailable) {
        //使用代码块开始获取陀螺仪数据
        [self.motionManager startDeviceMotionUpdatesToQueue:queue withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
            NSString *labelText;
            // 如果发生了错误，error不为空
            if (error){
                // 停止获取陀螺仪数据
                [self.motionManager stopGyroUpdates];
                labelText = [NSString stringWithFormat:@"获取陀螺仪数据出现错误: %@", error];
            }else{
                // 分别获取设备绕X轴、Y轴、Z轴上的转速
                labelText = [NSString stringWithFormat: @"X轴: %.2f\nY轴: %.2f\nZ轴:%.2f",motion.gravity.x,motion.gravity.y,motion.gravity.z];
            }
            
            if (motion.gravity.x < -0.8 ) {
                self.deviceOrientation = LEFT;
            } else if (motion.gravity.x > 0.8 ){
                self.deviceOrientation = RIGHT;
            } else {
                self.deviceOrientation = UP;
            }
            
            // 在主线程中更新gyroLabel的文本，显示绕各轴的转速
           // NSLog(@"%@",labelText);
        }];
    }else{
        NSLog(@"该设备不支持获取陀螺仪数据！");
    }
}

- (BOOL)checkCameraPrivate{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusDenied) {
        UIAlertController *alt = [UIAlertController alertControllerWithTitle:@"打开照相机失败！" message:@"请前往设置中打开相机权限" preferredStyle:UIAlertControllerStyleAlert];
        [alt addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alt animated:YES completion:nil];
        if (self.resultCallBack) {
            self.resultCallBack(NO, nil, @"无法打开相机，请前往设置打开相关权限！");
        }
        return NO;
    }
    else{
        return YES;
    }
    return YES;
}

- (void)loadCamera
{
    self.session = [AVCaptureSession new];
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    
    NSArray *devices = [NSArray new];
    devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == AVCaptureDevicePositionBack) {
            _device = device;
            break;
        }
    }
    
    NSError *error;
    self.input = [[AVCaptureDeviceInput alloc] initWithDevice:self.device error:&error];
    if ([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    }
    
    self.imageOutput = [[AVCapturePhotoOutput alloc] init];
    NSDictionary *setDic = @{AVVideoCodecKey:AVVideoCodecJPEG};
    _outputSettings = [AVCapturePhotoSettings photoSettingsWithFormat:setDic];
    _outputSettings.flashMode = AVCaptureFlashModeAuto; // 闪光灯自动
    _outputSettings.autoStillImageStabilizationEnabled = YES;
    [self.imageOutput setPhotoSettingsForSceneMonitoring:_outputSettings];
    [self.session addOutput:self.imageOutput];
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [self.previewLayer setFrame:CGRectMake(0, 0, self.videoView.frame.size.width, self.videoView.frame.size.height)];
    [self.videoView.layer addSublayer:self.previewLayer];
    [self.session startRunning];
    NSLog(@"video=[%f,%f],view = [%f,%f]",self.previewLayer.frame.size.width,self.previewLayer.frame.size.height,self.videoView.frame.size.width,self.videoView.frame.size.height);
    
    //修改设备的属性，先加锁
    if ([self.device lockForConfiguration:nil]) {
        // 将曝光模式设置为自动曝光
        [self.device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        // 设置自动对焦
        if ([self.device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]){
            [self.device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        }
        //自动白平衡
        if ([self.device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
            [self.device setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
        }
        //解锁
        [self.device unlockForConfiguration];
    }
}


- (IBAction)flapOnTap:(id)sender {
    self.isShowFlapOpt = !self.isShowFlapOpt;
    
    [self.flapAutoBtn setHidden:!_isShowFlapOpt];
    [self.flapOpenBtn setHidden:!_isShowFlapOpt];
    [self.flapCloseBtn setHidden:!_isShowFlapOpt];
    
}

- (void)clearFlapColor
{
    [self.flapAutoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.flapOpenBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.flapCloseBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (IBAction)flapAutoOnTap:(id)sender {
    _outputSettings.flashMode = AVCaptureFlashModeAuto;
    [self.flapBtn setImage:[UIImage imageNamed:@"flash"] forState:UIControlStateNormal];
    [self clearFlapColor];
    [self.flapAutoBtn setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    [self flapOnTap:nil];
}
- (IBAction)flapOpenOnTap:(id)sender {
     _outputSettings.flashMode = AVCaptureFlashModeOn;
    [self.flapBtn setImage:[UIImage imageNamed:@"flash_open"] forState:UIControlStateNormal];
    [self clearFlapColor];
    [self.flapOpenBtn setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
     [self flapOnTap:nil];
}
- (IBAction)flapCloseOnTap:(id)sender {
    _outputSettings.flashMode = AVCaptureFlashModeOff;
    [self.flapBtn setImage:[UIImage imageNamed:@"flash_close"] forState:UIControlStateNormal];
    [self clearFlapColor];
    [self.flapCloseBtn setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
     [self flapOnTap:nil];
}

- (IBAction)exchangeOnTap:(id)sender {
    //获取摄像头的数量
    NSUInteger cameraCount = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
    //摄像头小于等于1的时候直接返回
    if (cameraCount <= 1) return;
    
    AVCaptureDevice *newCamera = nil;
    AVCaptureDeviceInput *newInput = nil;
    //获取当前相机的方向(前还是后)
    AVCaptureDevicePosition position = [[self.input device] position];
    
    //为摄像头的转换加转场动画
    CATransition *animation = [CATransition animation];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.duration = 0.5;
    animation.type = @"oglFlip";
    
    if (position == AVCaptureDevicePositionFront) {
        //获取后置摄像头
        newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
        animation.subtype = kCATransitionFromLeft;
    }else{
        //获取前置摄像头
        newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
        animation.subtype = kCATransitionFromRight;
    }
    
    [self.previewLayer addAnimation:animation forKey:nil];
    //输入流
    newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
    
    
    if (newInput != nil) {
        [self.session beginConfiguration];
        //先移除原来的input
        [self.session removeInput:self.input];
        
        if ([self.session canAddInput:newInput]) {
            [self.session addInput:newInput];
            self.input = newInput;
            
        } else {
            //如果不能加现在的input，就加原来的input
            [self.session addInput:self.input];
        }
        
        [self.session commitConfiguration];
        
    }
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for ( AVCaptureDevice *device in devices )
        if ( device.position == position ) return device;
    return nil;
}

- (IBAction)takePhotoOnTap:(id)sender {
    self.outputSettings = [AVCapturePhotoSettings photoSettingsFromPhotoSettings:self.outputSettings];
    [self.imageOutput capturePhotoWithSettings:self.outputSettings delegate:self];
}

- (void)captureOutput:(AVCapturePhotoOutput *)captureOutput didFinishProcessingPhotoSampleBuffer:(nullable CMSampleBufferRef)photoSampleBuffer previewPhotoSampleBuffer:(nullable CMSampleBufferRef)previewPhotoSampleBuffer resolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings bracketSettings:(nullable AVCaptureBracketedStillImageSettings *)bracketSettings error:(nullable NSError *)error {
    DeviceOrientation ort = self.deviceOrientation;
    
    NSData *data = [AVCapturePhotoOutput JPEGPhotoDataRepresentationForJPEGSampleBuffer:photoSampleBuffer previewPhotoSampleBuffer:previewPhotoSampleBuffer];
    self.chooseImgData = data;
    UIImage *image = [UIImage imageWithData:data];
    
    if (ort == RIGHT) {
        image = [UIImage imageWithCGImage:image.CGImage scale:1 orientation:UIImageOrientationDown];
    }
    if (ort == LEFT) {
        image = [UIImage imageWithCGImage:image.CGImage scale:1 orientation:UIImageOrientationUp];
    }
    
    [self.chooseImageView setImage:image];
    [self.chooseBgView setHidden:NO];
}


- (IBAction)againPhoto:(id)sender {
    [self.chooseBgView setHidden:YES];
}
- (IBAction)usePhoto:(id)sender {
    [self.session stopRunning];
    if (self.resultCallBack != nil) {
        self.resultCallBack(YES, self.chooseImgData, @"");
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)cancel:(id)sender {
    if (self.cancelCallBack) {
        self.cancelCallBack();
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
