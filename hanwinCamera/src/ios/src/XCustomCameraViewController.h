//
//  XCustomCameraViewController.h
//  iBooks
//
//  Created by PSY on 2019/3/26.
//  Copyright © 2019 XW. All rights reserved.
//

#import <UIKit/UIKit.h>



NS_ASSUME_NONNULL_BEGIN

@interface XCustomCameraViewController : UIViewController

@property (nonatomic, copy)NSString *imgUrl;

@property (nonatomic, copy)void (^resultCallBack)(BOOL success, NSData *imgData, NSString *error);
@property (nonatomic, copy)void (^cancelCallBack)(void);

@end

NS_ASSUME_NONNULL_END
