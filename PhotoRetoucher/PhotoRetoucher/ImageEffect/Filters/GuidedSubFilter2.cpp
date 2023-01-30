//
//  GuidedSubFilter2.cpp
//
//  Created by rayyy on 2022/4/2.
//

#include "GuidedSubFilter2.hpp"

namespace effect {

void GuidedSubFilter2::init() {
    BaseFilter::initWithVertexStringAndFragmentString("simple", "guided2");
}

void GuidedSubFilter2::setInputFrameBufferAtIndex(std::shared_ptr<FrameBuffer> inputFrameBuffer, int index) {
    BaseFilter::setInputFrameBufferAtIndex(inputFrameBuffer, index);
    if (inputFrameBuffer) {
        widthOffset = 1.0f / inputFrameBuffer->getWidth();
        heightOffset = 1.0f / inputFrameBuffer->getHeight();
    }
    setOutputSize(firstInputWidth * 0.5, firstInputHeight);
}

void GuidedSubFilter2::renderToFrameBuffer(std::shared_ptr<FrameBuffer> outputFrameBuffer) {
    if (isNeedRender() && outputFrameBuffer) {
        outputFrameBuffer->activeFrameBuffer();
        
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        glClearColor(0.0f,0.0f,0.0f,1.0f);
        
        program->use();
        
        program->setVertexAttribPointer("a_position", imageVertices);
        program->setVertexAttribPointer("a_texCoord", textureCoordinates);
        
        program->setTextureAtIndex("u_origin", inputFrameBuffers[0]->getTextureID(), 2 + inputFrameBufferIndices[0]);
        program->setTextureAtIndex("u_AB", inputFrameBuffers[1]->getTextureID(), 2 + inputFrameBufferIndices[1]);
        
        program->setUniform2f("offset", widthOffset, heightOffset);
        program->setUniform1f("alpha", alpha);
        
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        
        glBindFramebuffer(GL_FRAMEBUFFER, GL_NONE);
    }
    
    unlockAndClearAllInputFrameBuffers();
}

bool GuidedSubFilter2::isAllInputReady() {
    return inputFrameBuffers.size() == 2;
}

void GuidedSubFilter2::setParams(const std::map<std::string, std::string> &param) {
    if (param.find(FilterParam_Guided_Alpha) != param.end()) {
        alpha = std::stof(param.at(FilterParam_Guided_Alpha));
    }
}

}
