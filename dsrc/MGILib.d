--
-- Name    : MGILib.d
-- Creator : lec
-- MGILib.d 04/05/99
--
-- D Events are declared in MGILib.d.de
--
-- History
--
-- 07/11/2001 lec
--	- APP changed to EIAPP
--
-- 12/29/98 lec
--	- InitApplication; modify check for development server
--
-- 11/13/98 lec
--	- added StatusReportOK
--
-- 11/12/98 lec
--	- added StatusReportFront; called from EditForm/SubEditForm focusCallback
--
-- 11/09/98 lec
--	- StatusReport; always push Status dialog to the front
--
-- 09/29/98 lec
--	- renamed to MGILib
--
-- 08/17/98 lec
--	- created MGI.d to localize Login/Exit procedures
--	- Devents are defined in MGI.de
--
--

dmodule MGILib is

#include <mgilib.h>

locals:
	top : widget;
	passwd : string;

rules:

--
-- CreateMGIModule
--
-- Create and initialize a D module instance
-- The INITIALLY event of the D module instance will be queued and executed
-- after this rule has finished.
--
-- The "top" widget is a parameter to the INITIALLY rule in the D module instance.
-- The "launchedFrom" widget is a parameter to the INITIALLY rule in the D module instance.
--

	CreateMGIModule does
	  launchedFrom : widget := CreateMGIModule.source_widget;
	  (void) create dmodule(CreateMGIModule.name, top, launchedFrom);
	end does;

--
-- InitApplication
--
-- Create/Display Login window
-- Construct Server and Database option menus
-- Initialize Table reason values
--

	InitApplication does
	  envList : list;
	  env : string;

	  top := create widget("Login", nil, nil);

	  global_version := "CVS 7-0-30";

	  SetTitle.source_widget := top;
	  send(SetTitle, 0);

	  SetOption.source_widget := top->LoginServer;
	  SetOption.value := getenv("DSQUERY");
	  send(SetOption, 0);

	  SetOption.source_widget := top->LoginDB;
	  SetOption.value := getenv("MGD");
	  send(SetOption, 0);

	  -- If Server is a Development server, then don't allow selection
	  -- of Production or Public server

	  if (top->LoginServer.menuHistory.development) then
	    top->LoginServerPulldown->Production.sensitive := false;
	    top->LoginServerPulldown->Public.sensitive := false;
	  end if;

	  (void) mgi_tblSetReasonValues();

	  top.show;

	  envList := create list("string");
	  envList.append("EIAPP");
	  envList.append("DSQUERY");
	  envList.append("SYBASE");
	  envList.append("MGD");
	  envList.append("NOMEN");
	  envList.append("EIDEBUG");

	  envList.open;
	  while envList.more do;
	    env := envList.next;
	    if (getenv(env) = nil) then
	      StatusReport.source_widget := top;
	      StatusReport.message := "\nWARNING:  Environment Variable " + env + " is not defined.";
	      send(StatusReport, 0);
	    end if;
	  end while;
	  envList.close;
	end does;

--
-- Login
--
-- Default is 'mgd_public'
--

	Login does
	  mgi : widget;
	  dialog : widget;
	  title : string;
	  i : integer := 1;

	  (void) mgi_writeLog("\n" + get_time() + "Logging in to Application...\n");

	  -- Set Global variables

	  global_server := top->LoginServer.menuHistory.defaultValue;
	  global_database := top->LoginDB.menuHistory.defaultValue;

	  if (global_database = nil) then
		global_database := getenv("MGD");
	  end if;

	  global_passwd := passwd;

	  if (top->User->text.value.length = 0) then
	    global_login := "mgd_public";
	  else
	    global_login := top->User->text.value;
	  end if;

	  if (global_passwd.length = 0) then
	    global_passwd := "mgdpub";
	  end if;

	  (void) busy_cursor(top);

	  -- Login to Server; Set DSQUERY and MGD env variables
	  -- If successful, destroy Login window and create main menu window

	  if (mgi_dbinit(global_login, global_passwd) = 1) then
	    title := top->LoginServer.menuHistory.name;
	    mgi := top;

	    -- Create top menu

	    top := create widget(global_application, nil, nil);
	    top.title := title;
	    top.realized := true;

	    -- Initializations

	    if (getenv("EIDEBUG") = "0") then
	      XmUpdateDisplay(mgi);
	      mgi->WorkingDialog.managed := true;
	      XmUpdateDisplay(mgi->WorkingDialog);

	      while (i <= top.initDialog.count) do
	        dialog := top->(top.initDialog[i]);
	        LoadList.list := dialog->ItemList;
	        send(LoadList, 0);
	        i := i + 1;
	      end while;

	      mgi->WorkingDialog.managed := false;
	    end if;

	    destroy mgi;
	    top.show;
	    (void) mgi_writeLog(get_time() + "Logged in to Application.\n\n");
	  end if;

	  (void) reset_cursor(top);
	end does;

--
-- HidePassword
--

	HidePassword does
	  passwd := mgi_hide_passwd(HidePassword.callback_struct, passwd);
	end does;

--
-- ExitApplication
--
-- Clean up and exit
--
-- tu_exit will call all of the FINALLY events in any DModules which are still
-- active, so let this cleanup first.
--
-- The last thing to do is to close the database.
--

	ExitApplication does
	  tu_exit(0);		-- Clean up
	  destroy top;		-- Kill application
	  (void) mgi_dbexit();	-- Close the database
	end does;

--
-- SetServer
--
--      Set Database Information for Form banner
--
 
        SetServer does
          SetServer.source_widget.dbInfo := "  (" + global_login +
                                            ", " + global_server + 
                                            ", " + global_database + ")";
        end does;
 
--
-- SetTitle
--
--      Set Title Information for Form banner
--
 
        SetTitle does
          root : widget := SetTitle.source_widget.find_ancestor(global_application);
 
          SetTitle.source_widget.title := global_application + " " + global_version +
                                          "  Form:  " + SetTitle.source_widget.title;
 
          if (root != nil) then
            SetTitle.source_widget.title := SetTitle.source_widget.title + root.dbInfo;
          end if;
        end does;

--
-- StatusReport
--
-- Display Status Report to user
--

        StatusReport does
	  status : widget;

	  if (StatusReport.source_widget != nil) then
	    status := StatusReport.source_widget;
	  else
	    status := top;
	  end if;

	  -- Don't overwrite Status Dialog if already managed

          if (status->StatusDialog = nil) then
	    (void) mgi_writeLog(get_time() + "ERROR: Could not get StatusDialog for " + status.name + "\n");
	    return;
	  end if;

          if (not status->StatusDialog.managed) then
            status->StatusDialog.messageString := StatusReport.message;
            status->StatusDialog.managed := true;
	    XmUpdateDisplay(status->StatusDialog);
	  elsif (StatusReport.appendMessage = 1) then
            status->StatusDialog.managed := false;
            status->StatusDialog.messageString := 
	    	status->StatusDialog.messageString + "\n\n" + StatusReport.message;
            status->StatusDialog.managed := true;
	  end if;

          status->StatusDialog.top.front;
        end does;

--
-- StatusReportFront
--
-- Set Status Report to front of stacking order
-- Called from EditForm/SubEditForm focusCallback
--

        StatusReportFront does
	  status : widget := StatusReportFront.source_widget.top;

	  if (status->StatusDialog != nil) then
            if (status->StatusDialog.managed) then
              status->StatusDialog.top.front;
	    end if;
	  end if;

	  status := top;

	  if (status->StatusDialog != nil) then
            if (status->StatusDialog.managed) then
              status->StatusDialog.top.front;
	    end if;
	  end if;

        end does;

--
-- StatusReportOK
--
-- Special callback for upper level Status Report dialog
-- After unmanaging dialog, place Menu shell in back of stacking order
--

        StatusReportOK does
	  if (StatusReportOK.source_widget = top->StatusDialog and
	      top.name != "Login") then
	    top.back;
	  end if;

	  StatusReportOK.source_widget.managed := false;
          StatusReportOK.source_widget.messageString := "";
	end does;

end dmodule;
