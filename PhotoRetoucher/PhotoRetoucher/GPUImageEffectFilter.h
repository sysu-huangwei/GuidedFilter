//
//  GPUImageEffectFilter.h
//
//  Created by rayyy on 2021/11/16.
//

#import <GPUImage/GPUImage.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, EffectType) {
    EffectType_EPS = 1,
    EffectType_Alpha = 2,
};

@interface GPUImageEffectFilter : GPUImageFilter

- (void)setEffectAlpha:(EffectType)type alpha:(float)alpha;

@end

NS_ASSUME_NONNULL_END
