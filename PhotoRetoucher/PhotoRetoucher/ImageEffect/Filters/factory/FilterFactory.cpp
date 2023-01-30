//
//  FilterFactory.cpp
//
//  Created by rayyy on 2021/9/23.
//

#include "FilterFactory.hpp"

#include "BaseLog.h"

#include "GuidedSubFilter1.hpp"
#include "GuidedSubFilter2.hpp"
#include "GuidedFilter.hpp"

namespace effect {
    
std::shared_ptr<BaseFilter> FilterFactory::createFilter(const FilterDescription &filterDesc) {
    std::shared_ptr<BaseFilter> filter = nullptr;
    
    if (filterDesc.type == FilterType_GuidedSubFilter1) {
        filter = std::make_shared<GuidedSubFilter1>();
    } else if (filterDesc.type == FilterType_GuidedSubFilter2) {
        filter = std::make_shared<GuidedSubFilter2>();
    } else if (filterDesc.type == FilterType_GuidedFilter) {
        filter = std::make_shared<GuidedFilter>();
    } else {
        LOGE("Error: FilterFactory::createFilter: invalid filter type = %s", filterDesc.type.c_str());
        assert(false);
    }
    
    filter->setEnableRender(filterDesc.enable);
    filter->setOutputSize(filterDesc.outputWidth, filterDesc.outputHeight);
    filter->setParams(filterDesc.params);
    
    return filter;
}

}
