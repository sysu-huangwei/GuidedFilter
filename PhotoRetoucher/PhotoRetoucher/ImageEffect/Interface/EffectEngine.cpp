//
//  EffectEngine.cpp
//
//  Created by rayyy on 2021/11/9.
//

#include "EffectEngine.hpp"
#include "BaseGLUtils.hpp"
#include "EffectConfigParser.hpp"
#include "BaseDefine.h"

namespace effect {

EffectEngine::EffectEngine(std::string configFilePath) {
    unsigned long dataSise;
    char *json = BaseGLUtils::loadFileToMemory(configFilePath.c_str(), dataSise);
    nodeDescriptions = EffectConfigParser::parseJsonToDescription(std::string(json));
    SAFE_DELETE_ARRAY(json);
};

}
