--
-- Name    : MGIMenu.d
-- Creator : lec
--
-- This module processes a master MGI menu for accessing 
-- all MGI TeleUSE applications.
--

dmodule MGIMenu is

--#include <utilities.h>

devents:

	ForkIt :local [app : string;];
		-- app is the name of the "run" script which sets up
		-- the appropriate environment and runs the application.
		-- be sure to include the full pathname
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
	  subprocs := create list(nil);
	  top.show;
	end does;

	ForkIt does
	  cmd_str : string_list := create string_list();

	  cmd_str.insert(ForkIt.app, cmd_str.count + 1);
	  proc_id : opaque := tu_fork_process(cmd_str[1], cmd_str, nil, ForkEnd);
	  subprocs.append(proc_id);
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

