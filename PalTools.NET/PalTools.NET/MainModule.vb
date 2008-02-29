Module MainModule

    Public PalPath As String
    Public PalMkfName() As String = { _
    "ABC.MKF", "BALL.MKF", "DATA.MKF", "F.MKF", _
    "FBP.MKF", "FIRE.MKF", "GOP.MKF", "MAP.MKF", _
    "MGO.MKF", "MIDI.MKF", "MUS.MKF", "PAT.MKF", _
    "RGM.MKF", "RNG.MKF", "SOUNDS.MKF", "SSS.MKF", _
    "VOC.MKF"}
    Public PalWordName As String = "WORD.DAT"
    Public PalMsgName As String = "M.MSG"
    Public PalMkfs(16) As PalTools.PalMkf
    Public PalPat As PalTools.PalPalette
    Public PalItems As PalTools.PalItem

    Public Structure TreeNodeValue
        Dim Level As Integer
        Dim Mkf As MkfFile

        Sub New(ByVal l As Integer, ByVal m As MkfFile)
            Level = l
            Mkf = m
        End Sub
    End Structure

    Public Structure ListNodeItemValue
        Dim Index As Integer
        Dim Description As Integer

        Sub New(ByVal i As Integer, ByVal d As Integer)
            Index = i
            Description = d
        End Sub
    End Structure

End Module
