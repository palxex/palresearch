// sss processor library for Pal
// Author: ylmson, 2005

// TODO rename all classes to "???Reader" and inherit them from BinaryReader, or add IDisposable interface to each
// TODO distinguish hex output value with prefix/suffix
// TODO finish MKF processing code, let the classes ultilize it

using System;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;
using System.Collections;

namespace Pal
{
	public class MKF
	{
		int count=0;
		FileStream stream;
		public int Count
		{
			get
			{
				return count;
			}
		}

		public int GetRecordPosition(int index)
		{
			return 0;
		}

		public MKF(string fileName)
		{
            OpenFile(fileName);
		}

		public void OpenFile(string fileName)
		{
			FileStream fs = File.Open(fileName, FileMode.Open);
			this.stream = fs;
			BinaryReader reader = new BinaryReader(fs);
		}
	}
}

namespace Pal.SSS
{
	public class SSSTest {
		public static void Main(string[] args)
		{
			Script script = new Script("sss4.bin");
			for(int index = 0; index < 20; index++)
			{
				ScriptEntry entry = script.Read(0x966e + index);
				ScriptEntryDescription entryDesc = (ScriptEntryDescription) ScriptEntryDescription.SCRIPT_COMMAND[entry.command];
				if(entryDesc == null) Console.WriteLine(entry);
				else
				{
					Console.WriteLine(entryDesc);
					string s = String.Format("{0}", entryDesc.commandName);
					for(int i = 0; i < entry.arg.Length; i++)
					{
						s += " " + ScriptEntryDescription.FormatArg(entryDesc.argType[i], entry.arg[i]);
					}
					Console.WriteLine(s);
				}
			}
		}
	}

	public class ScriptEntryDescription {
		public static Hashtable ARGUMENT_SUBSTITUTION = new Hashtable();
		public static Hashtable SCRIPT_COMMAND = ReadScriptCommandDescription("scr_desc.txt");

		public static Hashtable ReadKeyValues(string fileName)
		{
			Hashtable ht = new Hashtable();
			string s="";
			try
			{
				using(StreamReader reader = new StreamReader(File.Open(fileName, FileMode.Open)))
				{
					Regex r = new Regex("^@(\\S+):\\s*(.*\\S)\\s*$");
					while((s = reader.ReadLine()) != null)
					{
						if(!s.Trim().StartsWith("@")) continue;
						GroupCollection gc = r.Matches(s)[0].Groups;
						string key = gc[1].ToString();
						string val = gc[2].ToString();

						// WARNING: always using the last value definition
						if(ht.ContainsKey(key)) ht.Remove(key);
						ht.Add(key, val);
					}
				}
			}
			catch (FileNotFoundException)
			{
				ht = null;
			}
			catch (ArgumentOutOfRangeException)
			{
				throw new ArgumentOutOfRangeException(String.Format("Error when parsing line: {0}\nIn the type definition file: {1}", s, fileName));
			}
			return ht;
		}

		public static Hashtable ReadScriptCommandDescription(string descFileName)
		{
			Hashtable ht = new Hashtable(200);
			StreamReader reader = new StreamReader(File.Open(descFileName, FileMode.Open));
			//TODO catch IOException

			Regex r = new Regex("^@(\\S+):(\\s*(\\S+))+");
			Regex rComment = new Regex(";.*$");
			string s;
			while((s = reader.ReadLine()) != null)
			{
				if(!s.Trim().StartsWith("@")) continue;
				s = rComment.Replace(s, "");

				MatchCollection mc = r.Matches(s);
				foreach(Match m in mc)
				{
					GroupCollection gc = m.Groups;
					if(gc.Count < 4) throw new Exception(String.Format("Error when parsing line: {0}", s));
					ushort cmd = Convert.ToUInt16(gc[1].ToString(), 16);

					// WARNING: later definitions overrides the prior, may change behavior to exception throwing
					if(ht.ContainsKey(cmd)) ht.Remove(cmd);

					CaptureCollection cc = gc[3].Captures;
					ScriptEntryDescription entryDesc = new ScriptEntryDescription();
					// TODO: catch FormatException
                    entryDesc.commandName = cc[0].ToString();
                    for (int i = 1; i < 4; i++)
                    {
                        if (i >= cc.Count) entryDesc.argType[i - 1] = "Null";
                        else
                        {
                            string argType = cc[i].ToString();
                            entryDesc.argType[i - 1] = argType;
                        }
                    }
                    ht.Add(cmd, entryDesc);
                }
            }
            reader.Close();

            return ht;
        }

        public string commandName;
        public string[] argType = new string[3];

        public static string FormatArg(string type, ushort val)
        {
            if (type == null) return "";

            string s;
            switch (type)
            {
                case "UInt16": s = String.Format("{0}", val); break;
                case "Int16": s = String.Format("{0}", (short)val); break;
                case "UInt16H": s = String.Format("{0:x4}", val); break;
                case "Binary": s = String.Format("{0}", Convert.ToString(val, 2)); break;
                case "Boolean": s = (val == 0) ? "False" : "True"; break;
                case "Null": s = ""; break;

                default:
                    s = String.Format("{0:x4}", val);

                    // perform value file expansion for unknown type
                    // check if type.txt exists, if so, attempt to read value substitution strings from it
                    Hashtable htVals;
                    if (!ARGUMENT_SUBSTITUTION.ContainsKey(type))
                    {
                        string typeFileName = String.Format("{0}.txt", type);
                        htVals = ReadKeyValues(typeFileName);
                        if (htVals == null) htVals = new Hashtable();
                        ARGUMENT_SUBSTITUTION.Add(type, htVals);
                    }
                    else
                    {
                        htVals = (Hashtable)ARGUMENT_SUBSTITUTION[type];
                    }
                    if (htVals.ContainsKey(s)) s = (string)htVals[s];

                    break;
            }
            return s;
        }

        public override string ToString()
        {
            string s = String.Format("{0}", commandName);
            for (int i = 0; i < 3; i++)
            {
                s += String.Format(" {0}", argType[i]);
            }
            return s;
        }
    }

    public class ScriptEntry
    {
        public ushort command;
        public ushort[] arg;

        public override string ToString()
        {
            string s;
            s = String.Format("{0:x4} {1:x4} {2:x4} {3:x4}",
                    command, arg[0], arg[1], arg[2]);
            return s;
        }
    }

    public class Script
    {
        private BinaryReader readerScript;
        private long count;
        const int ENTRY_SIZE = 8;

        public BinaryReader Reader
        {
            get
            {
                return readerScript;
            }
        }

        public long Count
        {
            get
            {
                return count;
            }
        }

        public Script(string fileName)
        {
            OpenFiles(fileName);
        }

        public void OpenFiles(string fileName)
        {
            readerScript = new BinaryReader(File.Open(fileName, FileMode.Open));
            long fileLength = readerScript.BaseStream.Length;
            if (fileLength % ENTRY_SIZE != 0) throw new Exception("Index file corrupted.");
            count = fileLength / ENTRY_SIZE;
        }

        // Return a line of script at the location specified by index.
        public ScriptEntry Read(int index)
        {
            // TODO check possible corruption of files
            if (index >= count) return null;
            readerScript.BaseStream.Seek(index * ENTRY_SIZE, 0);

            ScriptEntry entry = new ScriptEntry();
            entry.command = readerScript.ReadUInt16();
            entry.arg = new ushort[3];	// WARNING: fixing # args = 3
            entry.arg[0] = readerScript.ReadUInt16();
            entry.arg[1] = readerScript.ReadUInt16();
            entry.arg[2] = readerScript.ReadUInt16();

            return entry;
        }
    }

    public class ObjectEntry
    {
        public ushort id;
        public ushort attribute;
        public ushort script0;
        public ushort script1;
        public ushort script2;
        public ushort flags;
    }

    public class Object : IDisposable
    {
        const int ENTRY_SIZE = 12;

        private BinaryReader readerObject;
        private long count;

        public BinaryReader Reader
        {
            get
            {
                return readerObject;
            }
        }

        public long Count
        {
            get
            {
                return count;
            }
        }

        private void OpenFiles(string fileName)
        {
            readerObject = new BinaryReader(File.Open(fileName, FileMode.Open));
            long fileLength = readerObject.BaseStream.Length;
            // TODO create a FileCorruptedException class
            if (fileLength % ENTRY_SIZE != 0) throw new Exception("File corrupted.");
            count = fileLength / ENTRY_SIZE;
        }

        public void Dispose()
        {
            readerObject.Close();
        }

        public Object(string fileName)
        {
            OpenFiles(fileName);
        }

        public ObjectEntry Read(int index)
        {
            if (index >= count) return null;
            readerObject.BaseStream.Seek(index * ENTRY_SIZE, 0);

            ObjectEntry entry = new ObjectEntry();
            entry.id = readerObject.ReadUInt16();
            entry.attribute = readerObject.ReadUInt16();
            entry.script0 = readerObject.ReadUInt16();
            entry.script1 = readerObject.ReadUInt16();
            entry.script2 = readerObject.ReadUInt16();
            entry.flags = readerObject.ReadUInt16();

            return entry;
        }
    }

    public class Word : IDisposable
    {
        const int ENTRY_SIZE = 10;
        private BinaryReader readerWord;
        private long count;

        public BinaryReader Reader
        {
            get
            {
                return readerWord;
            }
        }

        public long Count
        {
            get
            {
                return count;
            }
        }

        private void OpenFiles(string fileName)
        {
            readerWord = new BinaryReader(File.Open(fileName, FileMode.Open));
            long fileLength = readerWord.BaseStream.Length;
            // TODO create a FileCorruptedException class
            if (fileLength % ENTRY_SIZE != 0) throw new Exception("File corrupted.");
            count = fileLength / ENTRY_SIZE;
        }

        public void Dispose()
        {
            readerWord.Close();
        }

        public Word(string fileName)
        {
            OpenFiles(fileName);
        }

        public string Read(int index)
        {
            if (index >= count) return null;
            readerWord.BaseStream.Seek(index * ENTRY_SIZE, 0);

            byte[] word = new byte[ENTRY_SIZE];
            readerWord.Read(word, 0, ENTRY_SIZE);

            Encoding gb2312 = Encoding.GetEncoding("gb2312");
            string s = gb2312.GetString(word);
            return s;
        }
    }

    public class Message : IDisposable
    {
        private BinaryReader readerIndex, readerMessage;
        private long count;

        // max message length in chars
        public const int MAX_MSGLENGTH = 1000, ENTRY_SIZE_INDEX = 4;
        public Encoding outputEncoding = Encoding.UTF8;

        public BinaryReader ReaderIndex
        {
            get
            {
                return readerIndex;
            }
        }

        public BinaryReader ReaderMessage
        {
            get
            {
                return readerMessage;
            }
        }

        public long Count
        {
            get
            {
                return count;
            }
        }

        public Encoding OutputEncoding
        {
            get
            {
                return outputEncoding;
            }
            set
            {
                outputEncoding = value;
            }
        }

        public Message(string indexFileName, string msgFileName)
        {
            OpenFiles(indexFileName, msgFileName);
        }

        public void Dispose()
        {
            readerIndex.Close();
            readerMessage.Close();
        }

        private void OpenFiles(string indexFileName, string msgFileName)
        {
            readerIndex = new BinaryReader(File.Open(indexFileName, FileMode.Open));
            readerMessage = new BinaryReader(File.Open(msgFileName, FileMode.Open));
            count = readerIndex.BaseStream.Length / ENTRY_SIZE_INDEX;
            // TODO create a FileCorruptedException class
            long fileLength = readerIndex.BaseStream.Length;
            if (fileLength % ENTRY_SIZE_INDEX != 0) throw new Exception("Index file corrupted.");
            count = fileLength / ENTRY_SIZE_INDEX;
        }

        // read the index'th message
        public string Read(int index)
        {
            if (index >= count) return null;
            readerIndex.BaseStream.Seek(index * 4, 0);
            int begin, end, numBytesRead;
            begin = readerIndex.ReadInt32();
            end = (index == count) ? begin + MAX_MSGLENGTH : readerIndex.ReadInt32();
            byte[] buffer = new byte[MAX_MSGLENGTH];
            readerMessage.BaseStream.Seek(begin, 0);
            numBytesRead = readerMessage.Read(buffer, 0, end - begin);

            Encoding gb2312 = Encoding.GetEncoding("gb2312");
            buffer = Encoding.Convert(gb2312, outputEncoding, buffer, 0, numBytesRead);
            string s = outputEncoding.GetString(buffer);
            return s;
        }
    }

    public class SceneEntry
    {
        public ushort mapID;
        public ushort scriptEnter;
        public ushort scriptLeave;

        // ID of the first event in this scene (for locating in 0.sss)
        public ushort firstEventID;
    }

    public class Scene
    {
        const int ENTRY_SIZE = 8;

        private BinaryReader readerScene;
        private long count;

        public BinaryReader Reader
        {
            get
            {
                return readerScene;
            }
        }

        public long Count
        {
            get
            {
                return count;
            }
        }

        private void OpenFiles(string fileName)
        {
            readerScene = new BinaryReader(File.Open(fileName, FileMode.Open));
            long fileLength = readerScene.BaseStream.Length;
            // TODO create a FileCorruptedException class
            if (fileLength % ENTRY_SIZE != 0) throw new Exception("File corrupted.");
            count = fileLength / ENTRY_SIZE;

        }

        public Scene(string fileName)
        {
            OpenFiles(fileName);
        }

        public SceneEntry Read(int index)
        {
            // TODO check possible corruption of files
            if (index >= count) return null;
            SceneEntry entry = new SceneEntry();
            readerScene.BaseStream.Seek(index * ENTRY_SIZE, 0);

            entry.mapID = readerScene.ReadUInt16();
            entry.scriptEnter = readerScene.ReadUInt16();
            entry.scriptLeave = readerScene.ReadUInt16();
            entry.firstEventID = readerScene.ReadUInt16();

            return entry;
        }
    }
}
