--
-- Name    : MGIAdmin.d
-- Creator : lec
-- MGIAdmin.d 06/11/99
--

dmodule MGIAdmin is

rules:

--
-- INITIALLY
--
-- Call InitApplication
-- Initialize global variables
--

	INITIALLY does
	  global_application := "MGIAdmin";
	  global_version := "CVS 1.2";
	  send(InitApplication, 0);
	end does;

end dmodule;

