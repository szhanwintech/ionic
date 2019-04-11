/********* hanwinCamera.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>
#import "XCustomCameraViewController.h"

@interface hanwinCamera : CDVPlugin {
  // Member variables go here.
}

- (void)coolMethod:(CDVInvokedUrlCommand*)command;
- (void)getCamera:(CDVInvokedUrlCommand *)command;
@end

@implementation hanwinCamera

- (void)coolMethod:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSString* echo = [command.arguments objectAtIndex:0];

    if (echo != nil && [echo length] > 0) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:echo];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)getCamera:(CDVInvokedUrlCommand *)command
{
    
    NSString *url = [command.arguments objectAtIndex:0];
    
    XCustomCameraViewController *camera = [[XCustomCameraViewController alloc]initWithNibName:@"XCustomCameraViewController" bundle:nil];
    camera.resultCallBack = ^(BOOL success, NSData * _Nonnull imgData, NSString * _Nonnull error) {
        CDVPluginResult* pluginResult = nil;
        if (success) {
            NSLog(@"获取到数据：%@",imgData);
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArrayBuffer:imgData];
        } else {
            NSLog(@"未获取到数据!%@",error);
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error];
        }
        
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

    };
    camera.cancelCallBack = ^{
        NSLog(@"你取消了拍照");
    };
    camera.imgUrl = url;
    [self.viewController presentViewController:camera animated:YES completion:nil];
}

@end
