--
-- Name    : GXD.d
-- Creator : lec
-- GXD.d 07/01/99
--

dmodule GXD is

rules:

--
-- INITIALLY
--
-- Call InitApplication
-- Initialize global variables
--

	INITIALLY does
	  global_application := "GXD";
	  global_version := "CVS 1.3.7";
	  send(InitApplication, 0);
	end does;

end dmodule;

