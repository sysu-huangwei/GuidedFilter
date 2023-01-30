//
//  GuidedFilter.hpp
//
//  Created by rayyy on 2022/4/2.
//

#ifndef GuidedFilter_hpp
#define GuidedFilter_hpp

#include "FilterChain.hpp"

namespace effect {

/// 导向滤波
class GuidedFilter : public FilterChain {
public:
    
    GuidedFilter();
    
    /// 滤镜的类型
    std::string filterType() override { return FilterType_GuidedFilter; }
    
protected:
    
    /// 在最终渲染之前判断是否需要渲染
    virtual bool isNeedRender() override { return true; }
};

}

#endif /* GuidedFilter_hpp */
