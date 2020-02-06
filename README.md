# ZeladToon
荒野之息风格着色器  
  
参考文章 https://roystan.net/articles/toon-shader.html  
  
![林克](https://github.com/ssssssilver/ZeladToon/blob/master/ZeldaToon/preview/link.jpg)  
林克模型下载网址 https://sketchfab.com/3d-models/link-8f9337973edc4672bed0794b1c86319d  
由于下载的文件是glTF格式 unity不能直接识别 可以导入blender等三维引擎再导出为fbx 或者使用Unity插件Sketchfab for Unity进行转换  
插件下载地址：https://github.com/sketchfab/unity-plugin/releases/tag/1.1.1  
  
![林克](https://github.com/ssssssilver/ZeladToon/blob/master/ZeldaToon/preview/link.gif)    
着色器设置产生阴影，光暗交接部分用阴影衰减与漫反射乘积作为smoothstep函数的因子 让光暗部分分隔开且平滑过渡  
高光部分使用blin-phong光照模型 但在获取高光的pow()函数中让半角变量的点积与光照相乘作为因子，光泽gloss的平方作为指数  
并再次用smoothstep让高光部分控制在比较小的范围内  
内边缘高光部分用1-dot(viewdir,normal)求得 并且使用pow()函数让边缘高光范围变得更窄 最后再用smoothstep函数让交接处变得平滑过渡 
为了让着色器能产生阴影 需要在最后引用自带的pass Legacy Shaders/VertexLit/SHADOWCASTER 

接收阴影的面片创建自定义shadowreciver着色器 能控制阴影的透明度
