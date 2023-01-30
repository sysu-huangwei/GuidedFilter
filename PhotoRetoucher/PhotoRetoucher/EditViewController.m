//
//  EditViewController.m
//
//  Created by Ray on 2021/11/9.
//

#import "EditViewController.h"
#import "GPUImageEffectFilter.h"

@interface EditViewController ()

@property (nonatomic, strong) UIImage *originImage;
@property (strong, nonatomic) GPUImagePicture *originPicture;
@property (strong, nonatomic) GPUImageEffectFilter *effectFilter;

@property (assign, nonatomic) EffectType currentSelectedEffectType;
@property (strong, nonatomic) NSMutableDictionary<NSNumber *, NSNumber *> *effectAlpha;

@end

@implementation EditViewController

- (instancetype)initWithOriginImage:(UIImage *)originImage {
    if (self = [super init]) {
        _originImage = originImage;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:_showView.bounds];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [imageView setImage:_originImage];
    [_showView addSubview:imageView];
    
    _originPicture = [[GPUImagePicture alloc] initWithImage:_originImage];
    _effectFilter = [[GPUImageEffectFilter alloc] init];
    [_originPicture addTarget:_effectFilter];
    [_effectFilter addTarget:_showView];
    
    _effectAlpha = [NSMutableDictionary dictionaryWithDictionary: @{
        @(EffectType_EPS) : @(0.03),
        @(EffectType_Alpha) : @(1.0),
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_originPicture processImageUpToFilter:_effectFilter withCompletionHandler:^(UIImage *processedImage) {
        dispatch_async(dispatch_get_main_queue(), ^{
            for (UIView *view in self->_showView.subviews) {
                [view removeFromSuperview];
            }
        });
    }];
}

- (IBAction)clickSomeEffectButton:(UIButton *)button {
    if ([button isEqual:_currentSelectedButton]) {
        [button setBackgroundColor:UIColor.systemTealColor];
        _currentSelectedButton = nil;
        _effectSlider.hidden = YES;
    } else {
        if ([button.currentTitle isEqualToString:@"正则化参数"]) {
            _currentSelectedEffectType = EffectType_EPS;
            _effectSlider.maximumValue = 0.1;
            _effectSlider.minimumValue = 0.0;
            _effectSlider.value = [_effectAlpha[@(EffectType_EPS)] floatValue];
        } else if ([button.currentTitle isEqualToString:@"模糊程度"]) {
            _currentSelectedEffectType = EffectType_Alpha;
            _effectSlider.maximumValue = 1.0;
            _effectSlider.minimumValue = 0.0;
            _effectSlider.value = [_effectAlpha[@(EffectType_Alpha)] floatValue];
        }
        _effectSlider.hidden = NO;
        [_currentSelectedButton setBackgroundColor:UIColor.systemTealColor];
        [button  setBackgroundColor:UIColor.systemOrangeColor];
        _currentSelectedButton = button;
    }
}


- (IBAction)effectSliderChanged:(UISlider *)slider {
    _effectAlpha[@(_currentSelectedEffectType)] = @(slider.value);
    [_effectFilter setEffectAlpha:_currentSelectedEffectType alpha:slider.value];
    [_originPicture processImage];
}

@end
