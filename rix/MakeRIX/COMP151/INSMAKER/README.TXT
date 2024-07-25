
Adlib Inc, February 1989

Instrument Maker, Version 1.5
-----------------------------

Instrument Maker V1.5 offers three new features over earlier versions:

1 - Bank file for instrument sounds

     The new instrument bank file stores many intrument sounds together in
one file.  The many .INS files are now bundled together in one .BNK file.
This results in a significant saving of disk space and makes backing up much
easier.  If you have other Ad Lib products which are earlier than verson
1.5, you may need to convert between the old and new formats.  To convert
between the old and new formats, we have provided a conversion program
which is explained in the file BANKMNG.TXT.  In BANKMNG.TXT you will so
find information on ordering updates.
     By default, Instrument Maker V1.5 uses the bank file STANDARD.BNK.  
You may change the bank file by using the Open, Save or Save As commands
(as explained below in the Manual Errata section).

2 - Wave form option

     This new version of Instrument Maker offers control over an
additional parameter: it enables you to select among four different
wave forms.  You will find the wave form parameter at the bottom of the
parameter control panel on the screen.  It is a slide control with four
possible positions.  As you move the slide control, a graphic symbol to
the right of the control will indicate which wave form is in use.

3 - New Open, Save and Save As dialogs

     These dialogs have changed to allow you to change directories while
in the dialog.  (The Change Directory command in pre-1.5 versions is no
longer necessary and has been removed.)  How to use these new dialogs is 
explained below in the Manual Errata section.     



Instrument Maker, Version 1.5 - Compatibility
---------------------------------------------

     The new versions of Juke Box, Pop-Tunes, Visual Composer, and
Visual Composer/MIDI Supplement, to be released in the first quarter of
1989, will also support instrument bank files and the wave form parameter.
     In order to facilitate identification of the instrument bank and
wave form support, all of these titles will have a version number of 1.5
or higher.

    The wave form option is ignored when used with one of the earlier
versions of Ad Lib products. Consequently, sounds using the additional 
wave forms will not sound as they do in Instrument Maker if you are using 
them with any Ad Lib software earlier than version 1.5.  
     Also note that pre-V1.5 products will work with the latest version of 
the sound driver, SOUND.COM, but the new V1.5 products will not work properly
with older versions of the sound driver.  To avoid any problems, copy the 
most recent version of SOUND.COM to wherever you have older copies.  



Instrument Maker, Version 1.5 - Manual Errata
---------------------------------------------

Changing Directories and Drives:
     The dialogs described in this section has changed since going to
press.  The following explanation replaces the one in the manual.

     When in the Open, Save or Save As dialogs, you may change directories
or drives by pressing F1 (labelled "Bank File").  This activates the Bank
File dialog which is a scroll box containing a list of bank files and
sub-directories for the current directory.  The symbol <DIR> indicates a
directory.  Names which are not followed by this symbol are names of bank
files.  ".." indicates the directory which is above the current directory
in the hierarchy.

    To change the directory, use the up and down cursor keys to highlight
the target directory and press F1 (now labelled "Ch. Dir").  The list in
the scroll box will now show the list of sub-directories and bank files in
the new directory.  You may repeat this sequence to move anywhere in your
directory structure.

     To change the drive, press F2 (labelled "Drive") until the drive you
wish to use is displayed just above the scroll box.  When pressing F2, the
program will loop between drives A, B, C and D, depending on which drives
are available on your system.

     To select a bank file, use the up and down cursor keys to select the
target bank file name and press return.  You will then be returned to the
previous dialog and the selected bank file will be the active bank file.
The scroll box will display the list of instruments available in the newly
chosen bank file.

     The Bank File dialog in the Save and Save As commands gives you the
option of creating a new bank file.  This is done by pressing F3 (labelled
"Create").  A new dialog will appear to prompt you to enter the name of
the file to be created.  Enter the new name and press return.  (It is not
necessary to type in the file extension.)



----------------------------------------------------------------------



Ad Lib Septembre 1987
     Because of compatibility problems between Compaq's Deskpro 86
     and Hercules graphics card, our software cannot make use of a 
     mouse unless you upgrade Compaq's BIOS to a newer version.


