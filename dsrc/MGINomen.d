--
-- Name    : MGINomen.d
-- Creator : lec
-- MGINomen.d 06/11/99
--

dmodule MGINomen is

rules:

--
-- INITIALLY
--
-- Call InitApplication
-- Initialize global variables
--

	INITIALLY does
	  global_application := "MGINomen";
	  global_version := "CVS 1.2.3";
	  send(InitApplication, 0);
	end does;

end dmodule;

