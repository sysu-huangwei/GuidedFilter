//
//  EffectEngine.hpp
//
//  Created by rayyy on 2021/11/9.
//

#ifndef EffectEngine_hpp
#define EffectEngine_hpp

#include "FilterChain.hpp"
#include "BaseDefine.h"

namespace effect {

/// 效果引擎接口
class EffectEngine : public FilterChain {
public:
    
    EffectEngine(std::string configFilePath);
    
    void setBGRASmallImageData(unsigned char *data, size_t width, size_t height, size_t bytesPerRow);
    
    /// 滤镜的类型
    std::string filterType() override { return "EffectEngine"; }
    
private:
    BaseFrameColorInfo frameColorInfo;
};

}

#endif /* EffectEngine_hpp */
