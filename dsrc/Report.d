--
-- Name: Report.d
-- Report.d 06/11/99
--
-- lec   04/09/1999
--   - ReportInit; set default printer value based on env variable PRINTER
--   - ReportInit; set default printer as first item in printer list
--
-- lec   11/16/98
--   - use global_reportdir to initialize FileSelection.directory
--
-- lec   06/29/98
--   - JnumText s/b Jnum->text
--

dmodule Report is

#include <syblib.h>
#include <teleuse/tu_file.h>

devents:

   ReportGenerate [nlmMode : integer := 0;];
   ReportEnd [dialog : widget;];
   ReportInit [];
   ReportSelect [];

rules:

--
-- ReportGenerate
--
-- Constructs report call based on report selected
-- Forks process to execute report
-- 

   ReportGenerate does
     top : widget := ReportGenerate.source_widget.root;
     dialog : widget := ReportGenerate.source_widget.top;
     select : string := dialog.child(1).select; -- top = <widget#ReportDialog_popup:XmDialogShell>

     if (dialog->ReportList->List.selectedItemCount = 0) then
        StatusReport.source_widget := top;
        StatusReport.message := "No Report Selected";
        send(StatusReport);
        return;
     end if;

     (void) busy_cursor(dialog.top);

     -- Retrieve program and parameters for selected Report

     commands : string_list;
     commands := mgi_splitfields(dialog->ReportList->List.keys[dialog->ReportList->List.row], " ");
     program : string := commands[1];
     basename, bfilename : string; 

     -- If program is the Broadcast, then send User login and Password file

     if (program = "broadcast.py") then      -- Broadcast (user dependent)
         commands.insert("-U" + global_login, commands.count + 1);
         commands.insert("-P" + global_passwd_file, commands.count + 1);
         commands.insert(dialog->FileSelection.textString, commands.count + 1);
         bfilename := dialog->FileSelection.textString;
         basename := tu_base_name(bfilename);
         if (bfilename.length = 0 or basename.length = 0) then
              (void) reset_cursor(dialog.top);
            StatusReport.source_widget := top;
            StatusReport.message := "Invalid broadcast file";
            send(StatusReport);
            return;
         end if;

     elsif (program = "nlm.py") then      -- NLM program

            -- NLM Mode = 1 is the NLM Update
            -- NLM Mode = 2 is the Current Contents Update
            -- NLM Mode = 3 is an NLM or CC Add and requires a starting J#

               if (ReportGenerate.nlmMode = 3 and
                  (dialog->Jnum->text.value.length = 0 or
                  (integer) dialog->Jnum->text.value <= (integer) top->NextJnum->text.value)) then
                 StatusReport.source_widget := top;
                 StatusReport.message := "Invalid J#";
                 send(StatusReport);
                 return;
               end if;
 
            commands.insert("-U" + global_login, commands.count + 1);
            commands.insert("-P" + global_passwd_file, commands.count + 1);
 
            if (ReportGenerate.nlmMode = 3) then
              commands.insert("-a", commands.count + 1);
            elsif (ReportGenerate.nlmMode = 2) then
              commands.insert("-c", commands.count + 1);
            elsif (ReportGenerate.nlmMode = 1) then
              commands.insert("-u", commands.count + 1);
            end if;
 
            if (ReportGenerate.nlmMode = 3) then
              commands.insert("-j" + dialog->Jnum->text.value, commands.count + 1);
            end if;
 
            commands.insert(dialog->FileSelection.textString, commands.count + 1);

            if (ReportGenerate.nlmMode = 3) then
              dialog->Output.value := "NLM/CURRENT CONTENTS ADD\n";
            elsif (ReportGenerate.nlmMode = 2) then
              dialog->Output.value := "CURRENT CONTENTS UPDATE\n";
            elsif (ReportGenerate.nlmMode = 1) then
              dialog->Output.value := "NLM UPDATE\n";
            end if;
 
     -- Other Python scripts are not user-dependent and can execute using the public login
     -- These programs rely on the last search the User performed from within the form

     elsif (strstr(program, ".py") != nil) then
            if (dialog->ReportList->List.row = 1 and select.length = 0) then
               StatusReport.source_widget := top;
               StatusReport.message := "Must Return to Form and Perform A Search";
               send(StatusReport);
               (void) reset_cursor(dialog.top);
               return;
            else
               commands.insert(select, commands.count + 1);
            end if;

     -- SQL commands also execute using the DSQUERY and MGD env variables
     -- SQL reports should use the public login

     elsif (strstr(program, ".sql") != nil) then
            commands.insert(getenv("DSQUERY"), commands.count + 1);
            commands.insert(getenv("MGD"), commands.count + 1);
     end if;
 
     -- Print some diagnostics for the User

     dialog->Output.value := dialog->Output.value + "PROCESSING...\n[";
     commands.rewind;
     while (commands.more) do
       dialog->Output.value := dialog->Output.value + commands.next + " ";
     end while;
     dialog->Output.value := dialog->Output.value + "]\n";

     -- Manage the Working dialog so User knows something is happening

     top->WorkingDialog.messageString := "Processing...";
     top->WorkingDialog.managed := true;

     -- Fork and execute the report

     ReportEnd.dialog := dialog;

     -- I replaced fork_process2 with fork_process, since stderr and stdout
     -- were being merged anyway -gld
     proc_p : opaque := tu_fork_process(program, commands, dialog->Output, ReportEnd);
     -- check to see if we could exec the script 
     if (tu_fork_status(proc_p) = 2) then 
        StatusReport.source_widget := top;
        StatusReport.message := "Couldn't get script status";
        send(StatusReport);
     end if;      

     -- free the allocated proc_p pointer
      tu_fork_free(proc_p);
   end does;

--
-- ReportEnd
--

   ReportEnd does
     top : widget := ReportEnd.dialog.root;
     dialog : widget := ReportEnd.dialog;

     -- Re-set base directory so that dir list is refreshed

     dialog->FileSelection.directory := dialog->FileSelection.directory;

     -- Print some diagnostics for the User and to the User log

     dialog->Output.value := dialog->Output.value + "PROCESSING COMPLETED\n";
     (void) mgi_writeLog(dialog->Output.value + "\n");

     -- Make sure bottom of Output is visible

     (void) XmTextShowPosition(dialog->Output, XmTextGetLastPosition(dialog->Output));

     -- Unmanage the Working dialog so User knows that processing has completed

     top->WorkingDialog.messageString := "";
     top->WorkingDialog.managed := false;

     (void) reset_cursor(dialog.top);
        end does;

--
-- ReportInit
--

   ReportInit does
     dialog : widget := ReportInit.source_widget;
     top : widget := ReportInit.source_widget.root;
     printer : string := "";

     (void) busy_cursor(dialog.root);

     -- Init base directory

     if (dialog.useReportDir) then
            dialog->FileSelection.directory := global_reportdir;
     else
            dialog->FileSelection.directory := getenv("HOME");
     end if;

          dialog->Output.value := "";                  -- Reset Status Area

     printer := getenv("PRINTER");
     if (printer.length > 0) then
       (void) XmListSelectItem(dialog->PrinterList->List, xm_xmstring(printer), true);
       (void) XmListSetItem(dialog->PrinterList->List, xm_xmstring(printer));
     else
       (void)XmListSelectPos(dialog->PrinterList->List, 1, true);      -- Default Printer to First in List
     end if;

     (void)XmListSelectPos(dialog->ReportList->List, 1, true);      -- Default Report to First in List

     if (dialog.name = "NLMDialog") then
       NextJnum.source_widget := dialog.top;
       send(NextJnum, 0);
       dialog->Jnum->text.value := (string)((integer) top->NextJnum->text.value + 1);
     end if;

     (void) reset_cursor(dialog.root);
        end does;

--
-- ReportSelect
--

   ReportSelect does
          ReportSelect.source_widget.row := ReportSelect.item_position;
   end does;

end dmodule;
