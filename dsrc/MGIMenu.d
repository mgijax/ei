--
-- Name    : MGIMenu.d
-- Creator : lec
--
-- This module processes a master MGI menu for accessing 
-- all MGI TeleUSE applications.
--
-- 05/19/2010 lec
--      - revised top.title/iconName to use Configuration file


dmodule MGIMenu is

#include <utilities.h>

devents:

	ForkIt :local [app : string;];
		-- app is the name and arguments of the script to run
	ForkEnd :local [];
	Exit :local [];

locals:

	top : widget;

	subprocs : list;	-- a list of proc ids for each subprocess

rules:

--
-- INITIALLY
--

	INITIALLY does
	  top := create widget("MGIMenu", nil, nil);
	  top.title := getenv("MGD_DBSERVER") + ":" + getenv("MGD_DBNAME");
	  top.iconName := "MGIMenu:" + getenv("MGD_DBNAME");
	  subprocs := create list(nil);
	  top.show;
	end does;

	ForkIt does
	  cmd_str : string_list;
	  path : string := getenv("EIBUILDDIR");
	  cmd_str := mgi_splitfields(ForkIt.app, " ");
	  (void) mgi_writeLog(path + "/" + cmd_str[1] + " " + cmd_str[2] + "\n");
	  proc_id : opaque := tu_fork_process(path + "/" + cmd_str[1], cmd_str, nil, ForkEnd);
	  subprocs.append(proc_id);
	  tu_fork_close_io(proc_id);
	  tu_fork_free(proc_id);
	end does;

	ForkEnd does
	end does;

	Exit does

	  -- Kill all subprocesses created by ForkIt
	  subprocs.open;
	  while (subprocs.more) do
		tu_fork_kill(subprocs.next);
	  end while;

	  tu_exit(0);           -- Clean up
	  destroy top;		-- Kill Application
	end does;

end dmodule;

