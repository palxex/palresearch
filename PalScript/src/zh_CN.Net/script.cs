// script.cs: format pal script into readable text
// Author: ylmson, 2005

using System;
using System.IO;
using System.Reflection;
using System.Diagnostics;
using System.Text;
using System.Text.RegularExpressions;
using System.Collections;
using Pal.SSS;

public class ScriptTest
{
    // for debugging output
    public static TraceSwitch traceSwitch = new TraceSwitch("General", "Entire Application");
    public static TextWriterTraceListener traceWriter = new TextWriterTraceListener(System.Console.Out);

    // global variables
    public static Script script;
    public static Message message;
    public static Word word;

    public static Hashtable ReferredScript = new Hashtable();

    public static int scriptIndex = -1;
    public static bool printAll = true;

    public static void Usage()
    {
        AssemblyName an = Assembly.GetExecutingAssembly().GetName();
        Console.WriteLine("Usage: {0} [OPTION]", an.Name);
        Console.WriteLine("OPTION can be specified as one or more of the following:");
        Console.WriteLine("  -v <n>, --verbose <n>:\tset output verbosity level to n");
        Console.WriteLine("  -i <n>, --index <n>:\t\tuse script index n");
        Console.WriteLine("  -I <x>, --hex-index <x>:\tuse script index x (in hexadecimal)");
    }

    public static void ParseArguments(string[] args)
    {
        traceSwitch.Level = TraceLevel.Verbose;
        for (int i = 0; i < args.Length; i++)
        {
            switch (args[i])
            {
                case "-v":
                case "--verbose":
                    try
                    {
                        traceSwitch.Level = (TraceLevel)int.Parse(args[++i]);
                    }
                    catch { throw; }
                    break;
                case "-i":
                case "--index":
                    try
                    {
                        scriptIndex = int.Parse(args[++i]);
                    }
                    catch { throw; }
                    break;
                case "-I":
                case "--hex-index":
                    try
                    {
                        scriptIndex = Convert.ToInt32(args[++i], 16);
                    }
                    catch { throw; }
                    break;
                default:
                    throw new Exception("Invalid command line switches.");
            }
        }
        Trace.Listeners.Add(traceWriter);
    }

    public static void WriteDebugLine(bool flag)
    {
        if (flag) Console.WriteLine();
    }

    public static void WriteDebugLine(bool flag, string format, params object[] arg)
    {
        if (flag) Console.WriteLine(format, arg);
    }

    public static void WriteDebug(bool flag, string format, params object[] arg)
    {
        if (flag) Console.Write(format, arg);
    }

    //WARNING: returned string will be prefixed by seperator
    public static string ArgToString(ushort arg, string type)
    {
        string s = type.Equals("Null") ? "" : " ";
        string strReplace = "";

        // special formatting
        switch (type)
        {
            case "WordID":
                if (arg == 0) return "Null";
                else if (arg == 1) return "Empty";
                else if (arg > word.Count) goto default;
                else
                {
                    strReplace = word.Read(arg).Trim();
                }
                break;
            case "MessageID":
                string msg = message.Read(arg);
                strReplace = String.Format("`{0}`", msg);
                break;
            case "ScriptID":
                if (!printAll && !ReferredScript.ContainsKey((int)arg))
                {
                    ReferredScript.Add((int)arg, false);
                }
                goto default;
            default:
                // variable-to-file expansion
                strReplace = ScriptEntryDescription.FormatArg(type, arg);
                break;
        }
        s += strReplace;

        return s;
    }

    // Print the script at index until End (00) or Jump commands (02, 03) is reached.
    // return The index to the next line of script after the last one printed, or -1 if end of the script file is reached.
    public static int PrintScript(int index)
    {
        ScriptEntry entry;
        try
        {
            do
            {
                entry = script.Read(index);
                if (entry == null) throw new EndOfStreamException();
                WriteDebug(traceSwitch.TraceInfo, "{0:x4}: ", index);
                index++;

                // display raw data
                WriteDebug(traceSwitch.TraceVerbose, "{0:x4} {1:x4} {2:x4} {3:x4}",
                    entry.command, entry.arg[0], entry.arg[1], entry.arg[2]);
                WriteDebug(traceSwitch.TraceVerbose, " ;");

                ScriptEntryDescription entryDesc = (ScriptEntryDescription)ScriptEntryDescription.SCRIPT_COMMAND[entry.command];
                if (entryDesc != null)
                {
                    string s = String.Format("{0}{1}{2}{3}",
                            entryDesc.commandName,
                            ArgToString(entry.arg[0], entryDesc.argType[0]),
                            ArgToString(entry.arg[1], entryDesc.argType[1]),
                            ArgToString(entry.arg[2], entryDesc.argType[2]));
                    Console.WriteLine(s);
                }
                else
                {
                    Console.WriteLine(entry);
                }
            } while (entry.command != 0 && (entry.command < 2 || entry.command > 3));
        }
        catch (EndOfStreamException)
        {
            return -1;
        }

        return index;
    }

    public static void Main(string[] args)
    {
        try
        {
            script = new Script("sss4.bin");
            message = new Message("sss3.bin", "m.msg");
            word = new Word("word.dat");
        }
        catch (FileNotFoundException e)
        {
            Console.WriteLine("ÎÄ¼þÎ´ÕÒµ½!{0}", e.FileName);
            return;
        }
        try
        {
            ParseArguments(args);
        }
        catch (Exception e)
        {
            Usage();
            Console.WriteLine();
            Console.WriteLine(e.Message);
            return;
        }

        try
        {
            if (scriptIndex >= 0)
            {
                printAll = false;
                ReferredScript.Add(scriptIndex, false);
                do
                {
                    if (PrintScript(scriptIndex) == -1) throw new EndOfStreamException();
                    else ReferredScript[scriptIndex] = true;
                    scriptIndex = -1;
                    foreach (int i in ReferredScript.Keys)
                    {
                        if ((bool)ReferredScript[i] == false)
                        {
                            scriptIndex = i; break;
                        }
                    }
                    if (scriptIndex != -1) Console.WriteLine();
                } while (scriptIndex != -1);
            }
            else
            {
                scriptIndex = 0;
                while ((scriptIndex = PrintScript(scriptIndex)) != -1)
                {
                    Console.WriteLine();
                };
            }
        }
        catch (EndOfStreamException e)
        {
            Console.WriteLine("End of script file reached.");
        }
    }
}
