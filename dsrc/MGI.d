--
-- Name    : MGI.d
-- Creator : lec
-- MGI.d 09/30/98
--

dmodule MGI is

rules:

--
-- INITIALLY
--
-- Call InitApplication
-- Initialize global variables
--

	INITIALLY does
	  global_application := "MGI";
	  global_version := "v1.0";
	  send(InitApplication, 0);
	end does;

end dmodule;

