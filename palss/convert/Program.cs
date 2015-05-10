using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Net;
using System.Text;

namespace convert
{
    class Program
    {

        static void Main(string[] args)
        {
/*
            FileStream fs = new FileStream(@"h:\rng.av", FileMode.Open, FileAccess.Read, FileShare.Read);
            BinaryReader br = new BinaryReader(fs);
            for (int i = 0; i < 44; i++)
            {
                fs.Seek(i << 1, SeekOrigin.Begin);
                int offset = (int)IPAddress.NetworkToHostOrder(br.ReadInt16()) * 0x800;
                fs.Seek(offset + 4, SeekOrigin.Begin);
                int off1 = IPAddress.NetworkToHostOrder(br.ReadInt32());
                if (off1 > 0)
                    Console.WriteLine(i);
            }
            br.Close();
*/
            for (int i = 0; i < 111; i++)
            {
                CreateGif(@"f:\pal\bmp", @"f:\pal\gif", i);
                Console.WriteLine("Processed {0}.", i);
            }
        }

        static void CreateGif(string path, string outpath, int index)
        {
            string name = Path.Combine(path, index.ToString("000"));
            string outname = Path.Combine(outpath, index.ToString("000"));
            if (!File.Exists(name + "-000.bmp"))
                return;
            Bitmap bm = new Bitmap(name + "-000.bmp");
            FileStream fs = new FileStream(outname + ".gif", FileMode.Create, FileAccess.Write, FileShare.Read);
            MemoryStream temp = new MemoryStream();
            bm.Save(temp, ImageFormat.Gif);
            byte[] gif = temp.ToArray();
            temp.Close();
            fs.Write(gif, 0, 781);
            fs.Write(new byte[]{0x21, 0xFF, 0x0B, 0x4E, 0x45, 0x54, 0x53, 0x43, 0x41, 0x50, 0x45,
                0x32, 0x2E, 0x30, 0x03, 0x01, 0x00, 0x00, 0x00}, 0, 19);
            byte[] ctrl;
            //if (index == 8 || index == 9 || index == 11 || (index >= 16 && index <= 23) || index == 25 || index == 27 || index == 32 || index == 33)
            ctrl = new byte[] { 0x21, 0xF9, 0x04, 0x09, 0x0A, 0x00, 0xFF, 0x00 };
            //else
            //    ctrl = new byte[] { 0x21, 0xF9, 0x04, 0x04, 0x0A, 0x00, 0x00, 0x00 };
            fs.Write(ctrl, 0, 8);
            fs.Write(gif, 781, gif.Length - 783);
            for (int i = 1; File.Exists(name + "-" + i.ToString("000") + ".bmp"); i++)
            {
                bm = new Bitmap(name + "-" + i.ToString("000") + ".bmp");
                temp = new MemoryStream();
                bm.Save(temp, ImageFormat.Gif);
                gif = temp.ToArray();
                temp.Close();
                fs.Write(ctrl, 0, 8);
                fs.Write(gif, 781, gif.Length - 783);
            }
            fs.WriteByte(0x00);
            fs.WriteByte(0x3B);
            fs.Close();
        }
    }
}
