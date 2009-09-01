--
-- Name    : MGILib.d
-- Creator : lec
-- MGILib.d 04/05/99
--
-- D Events are declared in MGILib.de
--
-- History
--
-- 01/27/2006 lec
--	- remove StatusReportFront
--
-- 02/19/2004 lec
--	- TR 5567; launch MP Annotations
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
#include <syblib.h>

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
	  launchedFrom : widget;
	  launchTop : widget;
	  
	  launchedFrom := CreateMGIModule.source_widget;

	  -- this must be set to the root for the parent and child to function properly
	  launchTop := launchedFrom.root;

	  -- if the parent is set properly, then when the parent dies, the child will die
	  (void) create dmodule(CreateMGIModule.name, launchTop, launchedFrom);
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

--	  global_version := "CVS ei-TAG_NUMBER";
	  global_version := "CVS ei-4-3-0-32";

	  SetTitle.source_widget := top;
	  send(SetTitle, 0);

	  SetOption.source_widget := top->LoginServer;
	  SetOption.value := getenv("MGD_DBSERVER");
	  send(SetOption, 0);

	  SetOption.source_widget := top->LoginDB;
	  SetOption.value := getenv("MGD_DBNAME");
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
	  envList.append("MGD_DBSERVER");
	  envList.append("SYBASE");
	  envList.append("MGD_DBNAME");
	  envList.append("EIDEBUG");
	  envList.append("RADAR_DBNAME");

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
	  title : string;
	  jobStream : string;
	  i : integer := 1;

	  (void) mgi_writeLog("\n" + get_time() + "Logging in to Application...\n");

	  -- Set Global variables

	  global_server := top->LoginServer.menuHistory.defaultValue;
	  global_database := top->LoginDB.menuHistory.defaultValue;

	  if (global_database = nil) then
		global_database := getenv("MGD_DBNAME");
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

	  global_radar := getenv("RADAR_DBNAME");

	  (void) busy_cursor(top);

	  -- Login to Server; Set MGD_DBSERVER and MGD_DBNAME env variables
	  -- If successful, destroy Login window and create main menu window

	  if (mgi_dbinit(global_login, global_passwd) = 1) then
	    title := top->LoginServer.menuHistory.name;
	    mgi := top;

	    global_loginKey := 
		mgi_sql1("select _User_key from MGI_User_Active_View where login = '" + global_login + "'");

            if (global_loginKey.length = 0) then
	      StatusReport.source_widget := top;
	      StatusReport.message := "\nERROR:  Login " + global_login + " is not defined in the MGI User Table.";
	      send(StatusReport, 0);
	      (void) reset_cursor(top);
	      return;
	    end if;

	    -- If a Job Stream has not finished, then disallow Login
	    -- If debugging is on, then allow the Login

	    jobStream := mgi_sql1("exec " + global_radar + "..APP_EIcheck");
	    if ((getenv("EIDEBUG") = "0") and ((integer) jobStream > 0)) then
	      StatusReport.source_widget := top;
	      StatusReport.message := "\nERROR:  EI is unavailable.  A data load job is running.";
	      send(StatusReport, 0);
	      (void) reset_cursor(top);
	      return;
	    end if;

	    -- Create top menu

	    top := create widget(global_application, nil, nil);
	    top.title := title;
	    top.realized := true;

	    -- Initializations

--	    dialog : widget;
--	    if (getenv("EIDEBUG") = "0") then
--	      XmUpdateDisplay(mgi);
--	      mgi->WorkingDialog.managed := true;
--	      XmUpdateDisplay(mgi->WorkingDialog);
--
--	      while (i <= top.initDialog.count) do
--	        dialog := top->(top.initDialog[i]);
--	        LoadList.list := dialog->ItemList;
--	        send(LoadList, 0);
--	        i := i + 1;
--	      end while;
--
--	      mgi->WorkingDialog.managed := false;
--	    end if;

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
-- SetPermissions
--
--      Set Add/Modify/Delete button permissions based on EI module
--
 
        SetPermissions does
	   top := SetPermissions.source_widget;
	   cmd : string;
	   permOK : integer;

	   cmd := "exec MGI_checkUserRole " + mgi_DBprstr(top.name) + "," + mgi_DBprstr(global_login);
		
	   permOK := (integer) mgi_sql1(cmd);

	   if (permOK = 0) then

	      if (top->Control->Add != nil) then
	        top->Control->Add.sensitive := false;
	      end if;

	      top->Control->Modify.sensitive := false;
	      top->Control->Delete.sensitive := false;
	      top->CommandsPulldown->Add.sensitive := false;
	      top->CommandsPulldown->Modify.sensitive := false;
	      top->CommandsPulldown->Delete.sensitive := false;
	   end if;

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
	  elsif (StatusReport.appendMessage = true) then
            status->StatusDialog.managed := false;
            status->StatusDialog.messageString := 
	    	status->StatusDialog.messageString + "\n\n" + StatusReport.message;
            status->StatusDialog.managed := true;
	  end if;

          status->StatusDialog.top.front;
        end does;

--
-- StatusReportOK
--
-- Special callback for upper level Status Report dialog
-- After unmanaging dialog, place Menu shell in back of stacking order
--

        StatusReportOK does
--	  if (StatusReportOK.source_widget = top->StatusDialog and
--	      top.name != "Login") then
--	    top.back;
--	  end if;

	  StatusReportOK.source_widget.managed := false;
          StatusReportOK.source_widget.messageString := "";
	end does;

end dmodule;
