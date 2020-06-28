# 打包工具 Packaging Utilities

## 背景知识 Background Knowledge

1. 仙剑的打包格式：最外层统一为mkf，封包多个子文件。第二层一般为smkf，封包同一动画多帧（RNG例外）；大多情况下第二层外面会有一层YJ_1(DOS)/YJ_2(Win95)压缩以减少空间占用。没有统一规则，每个文件的封包需要自己分析。\
 All MKFs that used in Pal has similar schema: outside is MKF, inner is sMKF/MKF(RNG only); in most cases sMKF was compressed by YJ1/YJ2. No universal rules exists, you'd analysis yourself.

2. 工具共通前提：编译好pallib。\*nix（包括win32 msys2）下直接在PalLibrary下`make`即可。需要官方版python执行的话，用VC自带的命令行快捷方式跑`PalLibrary/build-vc-dll.cmd`。\
 BEFORE USAGE: compile pallib as demoed above.
3. 注意`pip install -r requirements.txt`安装依赖。\
 BEFORE USAGE TOO: install requirements follow above instruments.
4. 导出的bmp/png建议用[Usenti](http://www.coranac.com/projects/usenti/)或任何类似的支持调色板图像的编辑器编辑。windows画图会重整(requantize)调色板，导致再导入时需要重整调色板（否则颜色显示会有问题），无法实现精确的色彩把控，不推荐。\
 It's not recommend to modify exported bmp/png with Windows Painter or any other app that don't supports saving with original palatte, unless you know what you doing. They'll requantize it and makes exactly color manipulating impossible. Use them only when no other choise. Recommend app: [Usenti](http://www.coranac.com/projects/usenti/).
5. 编辑时注意透明色由导出时的-d参数指定，默认为0xff。\
 When exporting, please notice the `-d` param, it will tell the exporter what index in palette it should uses for the transparent 'color'. When its not specified, 0xff will be picked as default.

------

### demkf

mkf解包工具

```usage
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

------

### enmkf

mkf压包工具

```usage
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

------

### desmkf/ensmkf

用法与demkf/enmkf基本完全一致，不赘。

------

### deyj1

yj1解压工具

```usage
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

------

### enyj1

yj1压缩工具

```usage
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

------

### deyj2/enyj2

用法与deyj1/enyj1基本完全一致，不赘。

------

### derle

rle解压带调色板的bmp/png工具

```usage
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

------

* enrle

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

`./enrle.py icon.png -o ABC330.rle -p PAT.MKF --quantize --dither`

------

* derng

解码rng为gif

```useage
usage: derng.py [-h] -o OUTPUT -p PALETTE [-i PALETTE_ID]
                [-d TRANSPARENT_PALETTE_INDEX] [-m MILLISECS_PER_FRAME]
                [--show] [--saveraw]
                rng

tool for converting RNG to GIF animation

positional arguments:
  rng                   rng file to decode

optional arguments:
  -h, --help            show this help message and exit
  -o OUTPUT, --output OUTPUT
                        resulting gif
  -p PALETTE, --palette PALETTE
                        PAT file
  -i PALETTE_ID, --palette_id PALETTE_ID
                        palette id
  -d TRANSPARENT_PALETTE_INDEX, --transparent_palette_index TRANSPARENT_PALETTE_INDEX
                        transparent index for color in palette; default 255
  -m MILLISECS_PER_FRAME, --millisecs_per_frame MILLISECS_PER_FRAME
                        milliseconds per frame; default 100
  --show                show decoded image
  --saveraw             save decoded raw png data
```

示例：
`./derng.py RNG6.rng -p PAT.MKF -i 3 -o rng6.gif`

------

* enrng

将gif编码为rng

```usage
usage: enrng.py [-h] -o OUTPUT -p PALETTE [-i PALETTE_ID]
                [-d TRANSPARENT_PALETTE_INDEX] [-m MILLISECS_PER_FRAME]
                [--quantize] [--dither] [--saveraw]
                gif

tool for converting GIF animation to RNG

positional arguments:
  gif                   gif file to encode

optional arguments:
  -h, --help            show this help message and exit
  -o OUTPUT, --output OUTPUT
                        resulting rng
  -p PALETTE, --palette PALETTE
                        PAT file
  -i PALETTE_ID, --palette_id PALETTE_ID
                        palette id
  -n, --night           use night palette
  --algorithm ALGORITHM, -a ALGORITHM
                        decompression algorithm
  -d TRANSPARENT_PALETTE_INDEX, --transparent_palette_index TRANSPARENT_PALETTE_INDEX
                        transparent index for color in palette; default 255
  --quantize            for images not with pal palette; notice: expensive!
  --dither              whether ditter color when quantizing
  --saveraw             save decoded raw png data
  --progress, -P        show progress bar
```

示例：(将一部外源bik动画转为RNG)

```usage
# calc palette and generate optimized gif with the palette
ffmpeg -i demo.bik -vf fps=25,scale=320:200:flags=lanczos,palettegen=max_colors=256:reserve_transparent=0:stats_mode=full -y palette.png
ffmpeg -i demo.bik -i palette.png -lavfi fps=25,scale=320:200:flags=lanczos[x];[x][1:v]paletteuse=new=0:dither=0:diff_mode=1 -y demo.gif
# replace system palette; for example, the trademark palette(#3)
./demkf.py PAT.MKF -p pat
./enpat.py palette.png -o PAT3.pat
./enmkf.py --prefix PAT --postfix pat
# no requantize, directly reuse ffmpeg-optimized palette, avoid introduce quality impacting
./enrng.py demo.gif -o rng6.rng -p PAT.MKF -i 3 -a yj1 -P
```
