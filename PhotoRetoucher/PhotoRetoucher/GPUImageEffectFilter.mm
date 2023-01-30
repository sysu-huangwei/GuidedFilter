//
//  GPUImageEffectFilter.mm
//
//  Created by rayyy on 2021/11/16.
//

#import "GPUImageEffectFilter.h"
#include "EffectEngine.hpp"

std::shared_ptr<effect::FrameBuffer> getCPPFrameBufferFromGPUImageFrameBuffer(GPUImageFramebuffer *frameBuffer) {
    effect::TextureOptions textureOptions;
    textureOptions.minFilter = frameBuffer.textureOptions.minFilter;
    textureOptions.magFilter = frameBuffer.textureOptions.magFilter;
    textureOptions.wrapS = frameBuffer.textureOptions.wrapS;
    textureOptions.wrapT = frameBuffer.textureOptions.wrapT;
    textureOptions.internalFormat = frameBuffer.textureOptions.internalFormat;
    textureOptions.format = frameBuffer.textureOptions.format;
    textureOptions.type = frameBuffer.textureOptions.type;
    std::shared_ptr<effect::FrameBuffer> frameBufferCPP = std::make_shared<effect::FrameBuffer>();
    frameBufferCPP->init(frameBuffer.size.width, frameBuffer.size.height, frameBuffer.missingFramebuffer, textureOptions, frameBuffer.texture, frameBuffer.framebuffer);
    return frameBufferCPP;
}

@interface GPUImageEffectFilter()
{
    effect::EffectEngine *effectEngine;
}
@end

@implementation GPUImageEffectFilter

- (instancetype)init {
    if (self = [super init]) {
        runSynchronouslyOnVideoProcessingQueue(^{
            [GPUImageContext useImageProcessingContext];
            NSString *configFilePath = [NSBundle.mainBundle.bundlePath stringByAppendingPathComponent:@"ImageEffect.bundle/descriptions/GuidedFilter.json"];
            self->effectEngine = new effect::EffectEngine(configFilePath.UTF8String);
            self->effectEngine->init();
        });
    }
    return self;
}

- (void)dealloc {
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageContext useImageProcessingContext];
        self->effectEngine->release();
        delete self->effectEngine;
    });
}

- (void)setupFilterForSize:(CGSize)filterFrameSize;
{
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageContext useImageProcessingContext];
        self->effectEngine->setOutputSize(filterFrameSize.width, filterFrameSize.height);
    });
}

- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates;
{
    if (self.preventRendering)
    {
        [firstInputFramebuffer unlock];
        return;
    }
    
    outputFramebuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:[self sizeOfFBO] textureOptions:self.outputTextureOptions onlyTexture:NO];
    [outputFramebuffer activateFramebuffer];
    if (usingNextFrameForImageCapture)
    {
        [outputFramebuffer lock];
    }
    
    std::shared_ptr<effect::FrameBuffer> inputFrameBuffer = getCPPFrameBufferFromGPUImageFrameBuffer(firstInputFramebuffer);
    std::shared_ptr<effect::FrameBuffer> outputFrameBuffer = getCPPFrameBufferFromGPUImageFrameBuffer(outputFramebuffer);
    
    self->effectEngine->setInputFrameBufferAtIndex(inputFrameBuffer);
    
    self->effectEngine->renderToFrameBuffer(outputFrameBuffer);
    
    [firstInputFramebuffer unlock];
    
    if (usingNextFrameForImageCapture)
    {
        dispatch_semaphore_signal(imageCaptureSemaphore);
    }
}

- (void)setEffectAlpha:(EffectType)type alpha:(float)alpha {
    std::map<std::string, std::string> params;
    switch (type) {
        case EffectType_EPS:
            params = {
                { FilterParam_Guided_EPS, std::to_string(alpha) }
            };
            break;
        case EffectType_Alpha:
            params = {
                { FilterParam_Guided_Alpha, std::to_string(alpha) }
            };
            break;
        default:
            break;
    }
    effectEngine->setParams(params);
}

@end
