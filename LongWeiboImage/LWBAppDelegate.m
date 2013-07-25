//
//  LWBAppDelegate.m
//  LongWeiboImage
//
//  Created by uistrong on 13-7-24.
//  Copyright (c) 2013年 uistrong. All rights reserved.
//

#import "LWBAppDelegate.h"
#import "LWBLongImageCreater.h"
#import "LWBViewController.h"
#import "GUCustomerPhotoViewController.h"

@implementation LWBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    

#if 0
    self.viewController = [[LWBViewController alloc] initWithNibName:@"LWBViewController" bundle:nil];
#else
    
    
    LWBLongImageCreater *creater = [[LWBLongImageCreater alloc] init];
    
    NSString *path1 = [[NSBundle mainBundle] pathForResource:@"test.jpg" ofType:nil];
    NSString *path2 = [[NSBundle mainBundle] pathForResource:@"test.jpg" ofType:nil];
    NSString *path3 = [[NSBundle mainBundle] pathForResource:@"test.jpg" ofType:nil];
    NSString *path4 = [[NSBundle mainBundle] pathForResource:@"test.jpg" ofType:nil];
    NSString *path5 = [[NSBundle mainBundle] pathForResource:@"test.jpg" ofType:nil];
    
    NSDictionary *dic1 = [NSDictionary dictionaryWithObjectsAndKeys:path1,kLongWeiboImage,@"I have a UILabel that displays some chars. Like \"x\", \"y\" or \"rpm\". How can I calculate the width of the text in the label (it does not ues the whole available space)? This is for automatic layouting, where another view will have a bigger frame rectangle if that UILabel has a smaller text inside. \n Are there methods to calculate that width of the text when a UIFont and font size is specified? There's also no line-break and just one single line.", kLongWeiboImageBrief,nil];
    NSDictionary *dic2 = [NSDictionary dictionaryWithObjectsAndKeys:path2,kLongWeiboImage,@"关于UIFont\n和计算字\n符串的高度\n和宽度",kLongWeiboImageBrief,nil];
    NSDictionary *dic3 = [NSDictionary dictionaryWithObjectsAndKeys:path3,kLongWeiboImage,@"关于UIFont\n和计算字符\n串的\n高度和宽度",kLongWeiboImageBrief,nil];
    NSDictionary *dic4 = [NSDictionary dictionaryWithObjectsAndKeys:path4,kLongWeiboImage,@"关于UIFont和计算\n字符串的高\n度和宽度",kLongWeiboImageBrief,nil];
    NSDictionary *dic5 = [NSDictionary dictionaryWithObjectsAndKeys:path5,kLongWeiboImage,@"关于UIFont\n和计算字符串的高度\n和宽度",kLongWeiboImageBrief,nil];
    NSDictionary *dic6 = [NSDictionary dictionaryWithObjectsAndKeys:path1,kLongWeiboImage,@"关于",kLongWeiboImageBrief,nil];
    
    [creater addElement:dic1];
    [creater addElement:dic2];
    [creater addElement:dic3];
    [creater addElement:dic4];
    [creater addElement:dic5];
    [creater addElement:dic6];
    
    UIImage *img = [creater build];
    
    
    // 将图片写入文件
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    NSString *uuidStr = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, uuid);
    NSString *photoName = [uuidStr stringByAppendingPathExtension:@"jpg"];
    CFRelease(uuid);
    
#define kDocuments [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
    
    NSString *photoPath =  [kDocuments stringByAppendingPathComponent:photoName];
    NSData *imgData = UIImageJPEGRepresentation(img, 0.1);
    if (imgData != nil && imgData.length >0) {
        [imgData writeToFile:photoPath atomically:YES];
    }
    imgData = nil;

    
    GUCustomerPhotoViewController *VC = [[GUCustomerPhotoViewController alloc] init];
    VC.realUrlarr = [NSArray arrayWithObject:photoPath];
    VC.currentIndex = 0;
    self.viewController = VC;
    
    
#endif
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
