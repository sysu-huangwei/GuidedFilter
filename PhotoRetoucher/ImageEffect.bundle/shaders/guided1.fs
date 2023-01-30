precision highp float;

uniform sampler2D u_origin; // 原图
varying vec2 texcoordOut;

uniform vec2 offset;  // 单个像素步长
uniform float alpha;   // 模糊程度
uniform float eps;   // 正则化参数e

// 均值模糊，5*5
vec3 meanBlur(vec3 colors[25]) {
    highp vec3 sum = vec3(0.0);
    for (int i = 0; i < 25; i++) {
        sum += colors[i];
    }
    return sum * 0.04;
}

void main()
{
    // 因为这个shader最终画到一个 2*w, h 尺寸的一个FBO上，左边是导向滤波的a结果，右边是导向滤波的b结果，所以这里需要计算在原始纹理上真实的采样坐标
    highp vec2 originTexcoord;
    if (texcoordOut.x < 0.5) {
        originTexcoord = vec2(texcoordOut.x * 2.0, texcoordOut.y);
    } else {
        originTexcoord = vec2((texcoordOut.x - 0.5) * 2.0, texcoordOut.y);
    }
    
    // 采样原图 I 的 5*5 个点
    highp vec3 origin[25];
    
    origin[0] = texture2D(u_origin, originTexcoord).rgb;
    
    origin[1] = texture2D(u_origin, originTexcoord + vec2(offset.x, 0.0)).rgb;
    origin[2] = texture2D(u_origin, originTexcoord + vec2(-offset.x, 0.0)).rgb;
    origin[3] = texture2D(u_origin, originTexcoord + vec2(0.0, offset.y)).rgb;
    origin[4] = texture2D(u_origin, originTexcoord + vec2(0.0, -offset.y)).rgb;
    
    origin[5] = texture2D(u_origin, originTexcoord + vec2(offset.x, offset.y)).rgb;
    origin[6] = texture2D(u_origin, originTexcoord + vec2(offset.x, -offset.y)).rgb;
    origin[7] = texture2D(u_origin, originTexcoord + vec2(-offset.x, offset.y)).rgb;
    origin[8] = texture2D(u_origin, originTexcoord + vec2(-offset.x, -offset.y)).rgb;
    
    origin[9] = texture2D(u_origin, originTexcoord + vec2(2.0 * offset.x, 0)).rgb;
    origin[10] = texture2D(u_origin, originTexcoord + vec2(-2.0 * offset.x, 0)).rgb;
    origin[11] = texture2D(u_origin, originTexcoord + vec2(0, 2.0 * offset.y)).rgb;
    origin[12] = texture2D(u_origin, originTexcoord + vec2(0, -2.0 * offset.y)).rgb;
    
    origin[13] = texture2D(u_origin, originTexcoord + vec2(2.0 * offset.x, 2.0 * offset.y)).rgb;
    origin[14] = texture2D(u_origin, originTexcoord + vec2(2.0 * offset.x, -2.0 * offset.y)).rgb;
    origin[15] = texture2D(u_origin, originTexcoord + vec2(-2.0 * offset.x, 2.0 * offset.y)).rgb;
    origin[16] = texture2D(u_origin, originTexcoord + vec2(-2.0 * offset.x, -2.0 * offset.y)).rgb;
    
    origin[17] = texture2D(u_origin, originTexcoord + vec2(2.0 * offset.x, offset.y)).rgb;
    origin[18] = texture2D(u_origin, originTexcoord + vec2(-2.0 * offset.x, offset.y)).rgb;
    origin[19] = texture2D(u_origin, originTexcoord + vec2(offset.x, 2.0 * offset.y)).rgb;
    origin[20] = texture2D(u_origin, originTexcoord + vec2(-offset.x, 2.0 * offset.y)).rgb;
    
    origin[21] = texture2D(u_origin, originTexcoord + vec2(2.0 * offset.x, -offset.y)).rgb;
    origin[22] = texture2D(u_origin, originTexcoord + vec2(-2.0 * offset.x, -offset.y)).rgb;
    origin[23] = texture2D(u_origin, originTexcoord + vec2(offset.x, -2.0 * offset.y)).rgb;
    origin[24] = texture2D(u_origin, originTexcoord + vec2(-offset.x, -2.0 * offset.y)).rgb;
    
    // 计算原图的平方 I*I
    highp vec3 origin2[25];
    for (int i = 0; i < 25; i++) {
        origin2[i] = origin[i] * origin[i];
    }
    
    // 原图 I 的均值模糊
    highp vec3 originMean = meanBlur(origin);
    // 原图平方 I*I 的均值模糊
    highp vec3 origin2Mean = meanBlur(origin2);
    
    originMean = mix(origin[0], originMean, alpha);
    origin2Mean = mix(origin2[0], origin2Mean, alpha);
    
    // 原图模糊的平方
    highp vec3 originMean2 = originMean * originMean;
    
    // 计算方差（对于磨皮来说引导图和原图是同一个图，方差和协方差是同一个）
    highp vec3 variance = origin2Mean - originMean2;
    
    // 计算导向滤波的AB结果
    highp vec3 A = variance / (variance + eps);
    highp vec3 B = originMean - A * originMean;
    
    // 把AB分别写到图像的左半部分和右半部分
    if (texcoordOut.x < 0.5) {
        gl_FragColor = vec4((A + 1.0) * 0.5, 1.0);
    } else {
        gl_FragColor = vec4((B + 1.0) * 0.5, 1.0);
    }
    
}
