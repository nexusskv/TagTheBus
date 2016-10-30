//
//  UIImage+Category.h
//  TagTheBus
//
//  Created by Rost on 28.10.16.
//  Copyright © 2016 Rost Gress. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface UIImage (Category)

+ (UIImage *)rotateImage:(UIImage *)source withOrientation:(UIImageOrientation)orientation;

+ (UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)size;

@end
