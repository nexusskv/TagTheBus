//
//  UIImage+Category.m
//  TagTheBus
//
//  Created by Rost on 28.10.16.
//  Copyright © 2016 Rost Gress. All rights reserved.
//

#import "UIImage+Category.h"

static inline double radians (double degrees) {return degrees * M_PI/180;}


@implementation UIImage (Category)

#pragma mark - rotateImage:withOrientation:
+ (UIImage *)rotateImage:(UIImage *)source withOrientation:(UIImageOrientation)orientation {
    CGFloat radiansValue = 0.0f;
    
    if (orientation == UIImageOrientationRight) {
        radiansValue = radians(90);
    } else if (orientation == UIImageOrientationLeft) {
        radiansValue = radians(-90);
    } else if (orientation == UIImageOrientationDown) {
        // NOTHING
    } else if (orientation == UIImageOrientationUp) {
        radiansValue = radians(90);
    }
    
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0, source.size.height, source.size.width)];
    CGAffineTransform t = CGAffineTransformMakeRotation(radiansValue);
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    UIGraphicsBeginImageContextWithOptions(rotatedSize, NO, [[UIScreen mainScreen] scale]);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(bitmap, rotatedSize.width / 2, rotatedSize.height / 2);
    
    CGContextRotateCTM(bitmap, radiansValue);
    
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-source.size.width / 2, -source.size.height / 2 , source.size.width, source.size.height), source.CGImage );
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}
#pragma mark -


#pragma mark - resizeImage:toSize:
+ (UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
#pragma mark -

@end
