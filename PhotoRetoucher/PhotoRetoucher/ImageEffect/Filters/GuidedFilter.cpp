//
//  GuidedFilter.cpp
//
//  Created by rayyy on 2022/4/2.
//

#include "GuidedFilter.hpp"

namespace effect {

GuidedFilter::GuidedFilter() {
    FilterNodeDescription begin = defaultBeginNodeDescription;
    begin.nextIDs.push_back("guided1");
    begin.nextIDs.push_back("guided2");
    
    FilterNodeDescription guided1;
    guided1.id = "guided1";
    guided1.nextIDs.push_back("guided2");
    guided1.nextTextureIndices.push_back(1);
    guided1.filterDesc.type = FilterType_GuidedSubFilter1;
    
    FilterNodeDescription guided2;
    guided2.id = "guided2";
    guided2.filterDesc.type = FilterType_GuidedSubFilter2;
    
    nodeDescriptions.push_back(begin);
    nodeDescriptions.push_back(guided1);
    nodeDescriptions.push_back(guided2);
}

}
