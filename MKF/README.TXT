cut.exe 	mkf解压档
用法：cut 待解.mkf 后缀名
示例: cut midi.mkf mid
得到midi0.mid,midi1.mid,……midi88.mid.

mak.exe		mkf压缩档
用法: mak 特征*.后缀名(这个*是必须的)
示例:(当前文件夹内有如上cut.exe解出档或如上命名(以"特征"开头)之文件)
      mak midi*.mid
联结成midi.mkf文件.

注意:
因为考虑到要跟仙剑dos的格式保持完全一致，所以保持了很多0字节文件，这也是跟BSPAL版不兼容的根本所在。（另一个原因……就是我不会写WINDOWS下的GUI程序了-_-)