script.exe：命令行程序，格式化仙剑中的脚本为可读格式，可在scr_desc.txt中自由定义格式扩展。
开发环境Vim+Mono，在Debian Sarge (Linux)和Windows XP下测试通过。

运行时目录中需要文件：
sss3.bin sss4.bin word.dat m.msg scr_desc.txt

sss3.bin和sss4.bin可以用CUT.exe分解sss.mkf得到。使用命令行：

	CUT.exe sss.mkf bin

以下命令行可将所有格式化后的脚本写入scripts.txt
	script.exe > scripts.txt

以下命令行显示开场的脚本及其所引用到的任何其它脚本
	script.exe -I 1f10

scr_desc.txt是脚本指令定义文件，见附带的样本。因为是可读纯文本格式，基本上写完注释后可以直接作文档发布。
注：所附*ID.txt资料均提取自外塞之雾制作的DOS仙剑梦幻2.0版，仅有SpriteID.txt和SceneID.txt由以前整理的旧资料转换而得。

由于程序是.NET，有了库做界面会很容易。MKF、DATA等的处理待日后更新，可能会先用现有程序制成脚本编译器。

ylmson