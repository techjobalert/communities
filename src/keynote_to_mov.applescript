on run argv
        if (count argv) is 0 then
                set KeynoteFilePath to POSIX file "/Users/administrator/video_storage/p_source/"
                set MoveFileName to "keynote" as string
                set KeynoteFileName to MoveFileName & ".key" as string
                set KeynoteFile to KeynoteFilePath & KeynoteFileName as string
                set MovieFileStoragePath to "/Users/administrator/video_storage/p_video/" as string
        else
                set KeynoteFilePath to (item 1 of argv) as string
                set MoveFileName to (item 2 of argv) as string
                set MovieFileStoragePath to (item 3 of argv) as string
                set KeynoteFileName to MoveFileName & ".key" as string
                set KeynoteFile to KeynoteFilePath & MoveFileName & ".key" as string
        end if
        set CloseTimeOut to 5

        tell application "System Events"
                tell application "Keynote"
                        open KeynoteFile
                        activate
                end tell

                tell process "Keynote"
                        tell application "Keynote" to delay CloseTimeOut * 2

                        click menu item "ExportÉ" of menu of menu bar item "File" of menu bar 1

                        tell sheet 1 of window KeynoteFileName
                                tell button 1 of tool bar 1 to click
                                tell button "NextÉ" to click

                                select (static text of row 2 of outline 1 of scroll area 1 of splitter group 1 of group 1)

                                tell text field 1 to keystroke "a" using {command down}
                                tell text field 1 to keystroke " "
                                tell text field 1 to keystroke MoveFileName
                                tell button "Export" to click
                        end tell

                        tell application "Keynote" to delay CloseTimeOut * 10
                        set windowExportRef to (a reference to window "Export to QuickTime")
                        repeat while exists windowExportRef
                                --say "Window is still exist"
                                delay CloseTimeOut
                        end repeat
                end tell
                --say "Window doesn't exist"
                tell process "Keynote" to activate
                tell application "Keynote" to quit
        end tell
end run
