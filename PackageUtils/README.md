打包工具
======
背景知识：
1. 仙剑的打包格式：最外层统一为mkf，封包多个子文件。第二层一般为smkf，封包同一动画多帧（RNG例外）；大多情况下第二层外面会有一层YJ_1(DOS)/YJ_2(Win95)压缩以减少空间占用。没有统一规则，每个文件的封包需要自己分析。
2. 工具共通前提：编译好pallib。\*nix（包括win32 msys2）下直接在PalLibrary下`make`即可。需要官方版python执行的话，用VC自带的命令行快捷方式跑`PalLibrary/build-vc-dll.cmd`。
3. 注意`pip install -r requirements.txt`安装依赖。
4. 导出的bmp/png建议用[Usenti](http://www.coranac.com/projects/usenti/)或任何类似的支持调色板图像的编辑器编辑。windows画图会重整(requantize)调色板，导致再导入时需要重整调色板（否则颜色显示会有问题），无法实现精确的色彩把控，不推荐。
5. 编辑时注意透明色由导出时的-d参数指定，默认为0xff。

* demkf
-------
mkf解包工具
```
usage: demkf.py [-h] -p POSTFIX MKF

MKF unpack util

positional arguments:
  MKF                   MKF file to unpack

optional arguments:
  -h, --help            show this help message and exit
  -p POSTFIX, --postfix POSTFIX
                        postfix for unpacked files
```
示例：

`./demkf.py MIDI.mkf -p mid`

`./demkf.py ABC.mkf -p yj1`

* enmkf
-------
mkf压包工具
```
usage: enmkf.py [-h] --prefix PREFIX --postfix POSTFIX

MKF pack util

optional arguments:
  -h, --help         show this help message and exit
  --prefix PREFIX    prefix for files to pack
  --postfix POSTFIX  postfix for files to pack
```
示例：（以上例中解包后的文件夹为例）

`./enmkf.py --prefix MIDI --postfix mid`

`./enmkf.py --prefix ABC --postfix yj1`


* desmkf/ensmkf
---
用法与demkf/enmkf基本完全一致，不赘。

* deyj1
-------
yj1解压工具
```
usage: deyj1.py [-h] [-l LIB] -o OUTPUT YJ1

YJ1 extraction util

positional arguments:
  YJ1                   YJ1 file for extracting

optional arguments:
  -h, --help            show this help message and exit
  -l LIB, --lib LIB     path for pallib
  -o OUTPUT, --output OUTPUT
                        filename for unpacked file
```
示例：

`./deyj1.py ABC33.yj1 -o ABC33.smkf`

* enyj1
-------
yj1压缩工具
```
usage: enyj1.py [-h] [-l LIB] -o OUTPUT file

YJ1 compacting util

positional arguments:
  file                  file to compact

optional arguments:
  -h, --help            show this help message and exit
  -l LIB, --lib LIB     path for pallib
  -o OUTPUT, --output OUTPUT
                        filename for packed file
```
示例：（以上例中解压后的文件夹为例）

`./enyj1.py ABC33.smkf -o ABC33.yj1`

* deyj2/enyj2
---
用法与deyj1/enyj1基本完全一致，不赘。

* derle
---
rle解压带调色板的bmp/png工具
```useage
usage: derle.py [-h] [-o OUTPUT] -p PALETTE [-i PALETTE_ID]
                [-d TRANSPARENT_PALETTE_INDEX] [--show] [--saveraw]
                rle

tool for converting RLE to palette BMP/PNG

positional arguments:
  rle                   rle file to decode

optional arguments:
  -h, --help            show this help message and exit
  -o OUTPUT, --output OUTPUT
                        resulting bmp
  -p PALETTE, --palette PALETTE
                        PAT file
  -i PALETTE_ID, --palette_id PALETTE_ID
                        palette id
  -d TRANSPARENT_PALETTE_INDEX, --transparent_palette_index TRANSPARENT_PALETTE_INDEX
                        transparent index for color in palette; default 255
  --show                show decoded image
  --saveraw             save decoded raw data
```
示例：
`./derle.py ABC330.rle -o ABC330.bmp -p PAT.MKF`

* enrle
---
bmp/png压缩rle工具
```usage
usage: enrle.py [-h] -o OUTPUT [-d TRANSPARENT_PALETTE_INDEX] [--quantize]
                [-p PALETTE] [-i PALETTE_ID] [--dither] [--save_quantized_png]
                [--show]
                image

tool for converting BMP/PNG to RLE

positional arguments:
  image                 image file to encode

optional arguments:
  -h, --help            show this help message and exit
  -o OUTPUT, --output OUTPUT
                        resulting rle
  -d TRANSPARENT_PALETTE_INDEX, --transparent_palette_index TRANSPARENT_PALETTE_INDEX
                        transparent index for color in palette; default 255
  --quantize            for images not with pal palette; notice: expensive!
  -p PALETTE, --palette PALETTE
                        PAT file for quantize
  -i PALETTE_ID, --palette_id PALETTE_ID
                        palette id
  --dither              whether ditter color when quantizing
  --save_quantized_png  save quantized png
  --show                show quantized png
```

示例：

`./enrle.py ABC330.bmp -o ABC330.rle`
b
`./enrle.py icon.png -o ABC330.rle -p PAT.MKF --quantize --dither`
