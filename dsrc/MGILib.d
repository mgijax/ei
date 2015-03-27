--
-- Name    : MGILib.d
-- Creator : lec
-- MGILib.d 04/05/99
--
-- D Events are declared in MGILib.de
--
-- History
--
-- 03/07/2011 lec
--	- SetPermissions; add Utilities
--
-- 02/01/2011 lec
--	- CVS_TAG added
--
-- 05/19/2010 lec
--	- revised LoginServer/LoginDB to use Configuration file
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
#include <dblib.h>
#include <mgisql.h>

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

	  global_version := getenv("CVS_TAG");

	  SetTitle.source_widget := top;
	  send(SetTitle, 0);

	  top->LoginServer->text.value := getenv("MGD_DBSERVER");
	  top->LoginDB->text.value := getenv("MGD_DBNAME");

	  -- If Server is a Development server, then do not allow selection
	  -- of Production or Public server

	  (void) mgi_tblSetReasonValues();

	  top.show;

	  envList := create list("string");
	  envList.append("EIAPP");
	  envList.append("MGD_DBSERVER");
	  envList.append("SYBASE");
	  envList.append("MGD_DBNAME");
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
	  i : integer := 1;

	  (void) mgi_writeLog("\n" + get_time() + "Logging in to Application...\n");

	  -- Set Global variables

	  global_server := top->LoginServer->text.value;
	  global_database := top->LoginDB->text.value;

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
	    title := global_server + ":" + global_database;
	    mgi := top;

	    global_loginKey := mgi_sql1(mgilib_user(global_login));

            if (global_loginKey.length = 0) then
	      StatusReport.source_widget := top;
	      StatusReport.message := "\nERROR:  Login " + global_login + " is not defined in the MGI User Table.";
	      send(StatusReport, 0);
	      (void) reset_cursor(top);
	      return;
	    end if;

	    -- Create top menu

	    top := create widget(global_application, nil, nil);
	    top.title := title;
	    top.realized := true;

	    -- Initializations

	    destroy mgi;
	    top.show;
	    (void) mgi_writeLog("server : " + global_server + "\n");
	    (void) mgi_writeLog("database : " + global_database + "\n");
	    (void) mgi_writeLog("user : " + global_login + "\n");
	    (void) mgi_writeLog("db-type : " + GLOBAL_DBTYPE + "\n");
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
	   permOK : integer := 1;

	   cmd := exec_mgi_checkUserRole(mgi_DBprstr(top.name), mgi_DBprstr(global_login));
		
	   permOK := (integer) mgi_sp(cmd);

	   if (permOK = 0) then

	      if (top->Control->Add != nil) then
	        top->Control->Add.sensitive := false;
	      end if;

	      top->Control->Modify.sensitive := false;
	      top->Control->Delete.sensitive := false;
	      top->CommandsPulldown->Add.sensitive := false;
	      top->CommandsPulldown->Modify.sensitive := false;
	      top->CommandsPulldown->Delete.sensitive := false;

	      top->MainMenu->Utilities.managed := false;

	      --do not need this right now...but may in the future...
	      --if (top->MainMenu->NLM != nil) then
	      --  top->MainMenu->NLM.managed := false;
	      --end if;

	   end if;

	   -- only certain users have permission to turn 'Delete' on in this module
	   if (top.name = "MarkerModule" and 
	      	    global_login != "mgd_dbo" and global_login != "dbo" and
	       	    global_login != "mmh" and global_login != "djr") then
	       top->Control->Delete.sensitive := false;
	   end if;

        end does;
 
--
-- SetServer
--
--      Set Database Information for Form banner
--
 
        SetServer does
          SetServer.source_widget.dbInfo := "   (" + global_login +
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
 
          SetTitle.source_widget.title := global_application + " " + 
                                          SetTitle.source_widget.title + "   " +
					  global_version;
 
          if (root != nil) then
            SetTitle.source_widget.title := SetTitle.source_widget.title + root.dbInfo;
          end if;
        end does;

end dmodule;
