--
-- Name    : MGD.d
-- Creator : lec
-- MGD.d 07/26/99
--

dmodule MGD is

rules:

--
-- INITIALLY
--
-- Call InitApplication
-- Initialize global variables
--

	INITIALLY does
	  global_application := "MGD";
	  global_version := "CVS 1.2";
	  send(InitApplication, 0);
	end does;

end dmodule;

