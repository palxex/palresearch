仙剑原版各文件解析进度
===

当前目标综述：移植已完成，编辑器仍待努力

较详细的一个介绍及JAVA实现，参见[仙剑Java研究](https://web.archive.org/web/20110427035233/http://www.ismyway.com/pal/index.htm)

一个未完成的C++实现[palx](https://github.com/palxex/palx)

当前应用最广泛的C主体实现[sdlpal](https://github.com/sdlpal/sdlpal)


|文件名|功能推测|YJ_X压缩|子文件/空文件数|结构概要|
|-----|------|-----|------|------|
|SETUP.DAT|install设定|||参见[Setup.txt](Setup.txt)(引自[仙痴的网络U盘](http://softwide.ys168.com)),内附SuperMouse兄以C给出的结构|
|WOR16.FON|字体.图形|||682h的[文件头](#fon)(作用为简化描点的计算),其后文字如码表序,16*15(感谢SuperMouse)|
|WOR16.ASC|字体.码表|||2字节一个字,big5
|M.MSG|全部对话/提示|||同上
|WORD.DAT|所有文字|||同上
|*.rpg|存档|||参见[SAVE.TXT](SAVE.TXT)
|MIDI.[mkf](#mkf)|midi档|否|88.2|标准MIDI0
|MUS.[mkf](#mkf)|FM档|否|88.2|参见[DERIX.C](rix/DERIX.C)(BSPAL的杰作),感谢Pei Chengtong的[先驱工作](rix/playrix_final.asm),中华大圣补译的[ADLIB资料](rix/adlib/ProgrammingTheAdLibSoundBlasterFMMusicChips.htm)及[补遗](rix/adlib/补充.htm)
|VOC.[mkf](#mkf)|音效档|否|275.65|标准voc|
|GOP.[mkf](#mkf)|图元集|否|226.3|226个图元包,包内为类似MKF的打包结构(每指针2字节，偏移/2)，其内每个图元均为[RLE](#rle),形状是菱形
|MAP.[mkf](#mkf)|地图档|是|226.3|见[map原理](#map)
|RNG.[mkf](#mkf)|过场动画|否|12.0|见[rng原理](#rng)|
|DATA.[mkf](#mkf)|设定档|个别有|15.0|各子包不同,参见[data.htm](data.htm)
|SSS.[mkf](#mkf)|脚本集|否|5.0|各子包不同,参见夜烟的[SSS.txt](SSS.txt),[SSS.2.TXT](SSS.2.TXT),外塞之雾的[sssplusA.txt](sssplusA.txt),[sssplusB.txt](sssplusB.txt)
|PAT.[mkf](#mkf)|调色板|否|9.-2|RGB次序,每色1字节,256色调色板.-2是玩笑，有两个调色板有日夜分野所以粘在一起了,分别是日常和回忆.|
|BALL.[mkf](#mkf)|物品图片档|否|231.0|[RLE](#rle)|
|RGM.[mkf](#mkf)|人物头像档|否|91.2|[RLE](#rle)|
|FBP.[mkf](#mkf)|背景图|是|72.0|解压后320*200索引位图|
|F.[mkf](#mkf)|我战斗形象|是|19.0|子包解开YJ_1后，同GOP子包结构|
|FIRE.[mkf](#mkf)|法术效果图|是|55.0|同上|
|ABC.[mkf](#mkf)|敌战斗形象|是|153.0|同上|
|MGO.[mkf](#mkf)|地图对象形象|是|637.1|同上

<a name="mkf"></a>mkf打包原理:头部索引,指向内部偏移,每索引对应一个文件或空文件,最末一个索引除外.[压缩/解压脚本](PackageUtils)

<a name="yj1"></a>YJ_1/YJ_2压缩原理:均为经典的熵编码+字符串压缩，具体算法选择不同。参见[PalLibrary](https://github.com/palxex/palresearch/tree/master/PalLibrary)

<a name="rle"></a>rle压缩原理(仙剑):四字节(版本号?),两字节宽度,两字节长度.其后:0x80以上表示有多少透明像素,以下表示之后有多少个字节为显示像素(256色调色板索引),直到结束.[图片查看程序](https://github.com/palxex/palresearch/tree/master/DJGPPProgs)

<a name="map"></a>
map原理：解YJ_1后，每0x200字节为一行。每行中，每邻接四字节为一图元索引，每邻接两图元索引为左上/右下邻接,每隔接图元索引水平。每图元索引中，低二字节为底层图元索引，高二字节为覆盖图元索引。上两种基本图元索引中，低字节和高字节第五位联合，指定图元在对应的GOP组中的索引。基本图元索引高字节第6位指定该索引所代表的位置是否阻隔。高字节1、2、3、4位表层级高度，7、8位意义待查。参加[Baldur兄的地图编辑器](https://github.com/palxex/palresearch/tree/master/MapEditor)

<a name="rng">rng原理：每个子文件为一动画，又成一MKF结构，解之为每帧数据。每帧以YJ_1/2压缩，内容均为对上一帧的变动（具体算法为不同于上述的另一种定制版rle），故除第一帧外均为非关键帧。播放速度由播放脚本临时设定。

<a name="fon"></a>wor16.fon文件头格式:最前0x202字节为索引，每字形之任一字节取得后在此取索引，即可得其透明-覆盖-反复的列表（若开头一个为0x8x则为覆盖-透明-反复），这样就不必作位的运算。因对所有形态完备，故增加字这里也无必要修改。

最后，让我们感谢[所有直接和间接的贡献者](AUTHORS.txt)!
