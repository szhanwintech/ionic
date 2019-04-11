/********* WGCA.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>
#import "SignetManager.h"
#define DEMO_APP_ID @"APP_5BB849339B4A4FBBB6200312740CEEBE"

@interface WGCA : CDVPlugin <SignetManagerDelegate>{
  // Member variables go here.
}

@property (nonatomic, retain) SignetManager * mySignet;
@property (nonatomic, retain) CDVInvokedUrlCommand *command;

- (void)coolMethod:(CDVInvokedUrlCommand*)command;
-(void)isProcessFinished:(NSDictionary*)backParam;

@end

@implementation WGCA

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

- (void)findBackUserBySignet:(CDVInvokedUrlCommand *)command
{
    self.mySignet =  [ SignetManager initManager:self.viewController delegate:self];
    self.mySignet.delegate = self;
    self.command = command;

    if(nil == self.mySignet){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"不能使用空指针初始化" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:okAction];
        [self.viewController presentViewController:alertController animated:YES completion:nil];
    }
    
    NSError *error = [ self.mySignet findbackUserBySignet:DEMO_APP_ID];
    if ( error != nil ) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:[error localizedDescription]preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:okAction];
        [self.viewController presentViewController:alertController animated:YES completion:nil];
    } else {
        NSLog(@"没有错误信息");
    }
}

- (void)getUserList:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult* pluginResult = nil;
    @try {
        NSDictionary *dict = [SignetManager getUserList];
        NSLog(@"获取到用户列表信息：\n%@",dict);
         pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dict];
    } @catch (NSException *exception) {
        NSLog(@"catch：%@",exception);
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.userInfo.description];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)userLogin:(CDVInvokedUrlCommand *)command
{

    NSString* msspID = [command.arguments objectAtIndex:0];
    NSString* signJobID = [command.arguments objectAtIndex:1];

    self.mySignet =  [ SignetManager initManager:self.viewController delegate:self];
    self.mySignet.delegate = self;
    self.command = command;

    if(nil == self.mySignet){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"不能使用空指针初始化" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:okAction];
        [self.viewController presentViewController:alertController animated:YES completion:nil];
    }
   NSError *error = [self.mySignet userLogin:DEMO_APP_ID MSSPID:msspID LogInJobID:signJobID];
    if ( error != nil ) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:[error localizedDescription]preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:okAction];
        [self.viewController presentViewController:alertController animated:YES completion:nil];
    } else {
        NSLog(@"没有错误信息");
    }
}


-(void)isProcessFinished:(NSDictionary*)backParam
{
    NSString *success = backParam[@"errorCode"];
    NSString *errorDescript = [backParam objectForKey:@"errorDescript"];
    NSString *businessType = [backParam objectForKey:@"businessType"];
    NSObject *backData = [backParam objectForKey:@"backData"];
     CDVPluginResult* pluginResult = nil;
    
    if ([businessType isEqualToString:@"2"]) {
        if ([success isEqualToString:@"0x00000000"]) {
            NSLog(@"找回成功：%@",backData);
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:(NSString *)backData];
        }else {
            NSLog(@"找回失败！原因：%@",errorDescript);
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:errorDescript];
        }

        
    } else if ([businessType isEqualToString:@"1"]) {
        if ([success isEqualToString:@"0x00000000"]) {
            NSLog(@"登陆成功：%@",backData);
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:(NSDictionary *)backData];
        }else {
            NSLog(@"登陆失败！原因：%@",errorDescript);
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:errorDescript];
        }
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.command.callbackId];
}

@end
