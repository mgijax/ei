--
-- Name    : Fantom.d
-- Creator : lec
--

dmodule FANTOM is

rules:

--
-- INITIALLY
--
-- Call InitApplication
-- Initialize global variables
--

	INITIALLY does
	  global_application := "FANTOM";
	  send(InitApplication, 0);
	end does;

end dmodule;

