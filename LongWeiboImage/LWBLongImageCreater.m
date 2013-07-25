//
//  LWBLongImageCreater.m
//  LongWeiboImage
//
//  Created by uistrong on 13-7-24.
//  Copyright (c) 2013年 uistrong. All rights reserved.
//

#import "LWBLongImageCreater.h"

@implementation LWBLongImageCreater

- (id) init{
    self = [super init];
    if (self) {
        _arrElement = [[NSMutableArray alloc]initWithCapacity:0];
        _width = kLongWeiboImageMaxWidth;
        _height = -1;
        _wbTitle = @"分享";
        _logoText = @"Where's your logo!";
    }
    return self;
}

- (void) addElement:(NSDictionary*) element{
    [_arrElement addObject:element];
}


- (UIImage*) build{
    
    // 构建一个大的内存BMP
    UIGraphicsBeginImageContext(CGSizeMake(kLongWeiboImageMaxWidth, 8000));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, kLongWeiboImageMaxWidth, 8000));
    
    NSUInteger drawY = 0;
    // draw title
    CGRect rtTitle = CGRectMake(0, drawY, kLongWeiboImageMaxWidth, kLongWeiboTitleAreaHeigth);
    CGContextSetRGBFillColor(context, 1.0, 1.0, 0, 1.0); // yellow
    CGContextFillRect(context, rtTitle);
    CGContextSetRGBFillColor(context, 0, 0, 0, 1.0); // black
    UIFont *ftTitle = [UIFont systemFontOfSize:kLogoFontSize];
    [self.wbTitle drawInRect:rtTitle withFont:ftTitle lineBreakMode:UILineBreakModeWordWrap alignment:NSTextAlignmentCenter];
    drawY += rtTitle.size.height;
    
    UIImage *retImg = nil;
    for (NSDictionary *dic in _arrElement) {
        id objImg = [dic objectForKey:kLongWeiboImage];
        NSString *brief = [dic objectForKey:kLongWeiboImageBrief];
        if ([objImg isKindOfClass:[NSString class]]) {
            UIImage *img = [[UIImage alloc]initWithContentsOfFile:(NSString*)objImg];
            UIImage *dstImg = [LWBLongImageCreater scaleImageWithImage:img]; // 缩放
        
            NSUInteger w = dstImg.size.width;   // 缩放后图片宽高
            NSUInteger h =  dstImg.size.height;
        
            [dstImg drawInRect:CGRectMake(0, drawY, w, h)]; // draw dest image
            drawY += h; // update Y Postion
            
            UIColor *clr = [UIColor colorWithWhite:0 alpha:1];
            CGContextSetFillColorWithColor(context, [clr CGColor]);
            
            UIFont *ft = [UIFont systemFontOfSize:kFontSize];
            NSUInteger rtWidth = kLongWeiboImageMaxWidth-kFirstFontMarginLeft-kFirstFontMarginLeft;
            NSUInteger rtHeight = 0;
            
            // 实现换行
            NSMutableArray *arrStr = [[brief componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]] mutableCopy];
            for (NSString * lineStr in arrStr) {
                CGSize lineSize = [lineStr sizeWithFont:ft];    // one line chars size
                NSUInteger singleCharHeight = lineSize.height;  // one char height
                if (lineSize.width > rtWidth) {
                    NSUInteger rowCount = lineSize.width/rtWidth + (((NSUInteger)lineSize.width)%rtWidth?1:0);
                    lineSize.height += (singleCharHeight)*(rowCount-1);
                }
                rtHeight += (lineSize.height);
            }
            drawY += kFirstFontMarginTop; // update Y Postion
            CGRect ftRect = CGRectMake(kFirstFontMarginLeft, drawY, rtWidth, rtHeight);
            [brief drawInRect:ftRect withFont:ft lineBreakMode:UILineBreakModeWordWrap alignment:NSTextAlignmentLeft];
            drawY += (rtHeight+kLastFontMarginBottom); // update Y Postion
        }else if([objImg isKindOfClass:[NSData class]]){
            
        }else if([objImg isKindOfClass:[UIImage class]]){
            
        }
    }
    // draw logo
    CGRect rtLogo = CGRectMake(0, drawY, kLongWeiboImageMaxWidth, kLongWeiboLogoAreaHeigth);
    CGContextSetRGBFillColor(context, 1.0, 1.0, 0, 1.0); // yellow
    CGContextFillRect(context, rtLogo);
    
    CGContextSetRGBFillColor(context, 0, 0, 0, 1.0); // black
    UIFont *ftLogo = [UIFont systemFontOfSize:kLogoFontSize];
    [self.logoText drawInRect:rtLogo withFont:ftLogo lineBreakMode:UILineBreakModeWordWrap alignment:NSTextAlignmentCenter];
    drawY += rtLogo.size.height;
    
    // clip image
    CGRect clipRect = CGRectMake(0, 0, kLongWeiboImageMaxWidth, drawY);
    CGImageRef imgRefOri =  CGBitmapContextCreateImage(context);
    CGImageRef imgRef = CGImageCreateWithImageInRect(imgRefOri, clipRect);
    retImg = [UIImage imageWithCGImage:imgRef];
    UIGraphicsEndImageContext();
    
    return retImg;
}

// 缩放图片到指定大小
+ (UIImage*)scaleImageWithImage:(UIImage*)image
{
    // 已宽度为准，铺满款，等比缩
    NSUInteger w = image.size.width;
    NSUInteger h =  image.size.height;
    if (w > kLongWeiboImageMaxWidth) {
        h = h * kLongWeiboImageMaxWidth/w;
        w = kLongWeiboImageMaxWidth;
    }

    CGSize newSize = CGSizeMake(w, h);
    // 保持长宽比
    if (!CGSizeEqualToSize(image.size, newSize)) {
        CGFloat widthFactor = newSize.width / image.size.width;
        CGFloat heightFactor = newSize.height / image.size.height;
        
        CGFloat scaleFactor = 0.0;
        if (widthFactor < heightFactor)
            scaleFactor = widthFactor;
        else
            scaleFactor = heightFactor;
        
        CGFloat scaledWidth  = image.size.width * scaleFactor;
        CGFloat scaledHeight = image.size.height * scaleFactor;
        
        CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
        if (widthFactor < heightFactor) {
            thumbnailPoint.y = (newSize.height - scaledHeight) * 0.5;
        } else if (widthFactor > heightFactor) {
            thumbnailPoint.x = (newSize.width - scaledWidth) * 0.5;
        }
        
        UIGraphicsBeginImageContext(newSize);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [[UIColor blackColor] CGColor]);
        CGContextFillRect(context, CGRectMake(0, 0, newSize.width, newSize.height));
        
        CGRect thumbnailRect = CGRectZero;
        thumbnailRect.origin = thumbnailPoint;
        thumbnailRect.size.width  = scaledWidth;
        thumbnailRect.size.height = scaledHeight;
        
        [image drawInRect:thumbnailRect];
        UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        return newImage;
    }else{
        return image;
    }
}

@end
