--
-- Name: PythonLib.d
--
-- 04/04/2006	lec
--	- TR 7607; HomologyCache
--
-- 07/19/2005	lec
--	- events for executing Python from with the EI
--
--

dmodule PythonLib is

#include <syblib.h>
#include <mgilib.h>
#include <teleuse/tu_file.h>

rules:

--
-- PythonMarkerOMIMCache
--
-- Activated from:  Genotype module, Allele module, Marker module
-- after an update or Marker withdrawal
--

	PythonMarkerOMIMCache does
	  pythonevent : string := PythonMarkerOMIMCache.pythonevent;
	  objectKey : string := PythonMarkerOMIMCache.objectKey;
	  cmds : string_list := create string_list();
	  buf : string;

	  if (pythonevent = EVENT_OMIM_BYALLELE) then
	    cmds.insert(getenv("OMIMCACHE") + "/mrkomimByAllele.py", cmds.count + 1);
	  elsif (pythonevent = EVENT_OMIM_BYMARKER) then
	    cmds.insert(getenv("OMIMCACHE") + "/mrkomimByMarker.py", cmds.count + 1);
	  elsif (pythonevent = EVENT_OMIM_BYGENOTYPE) then
	    cmds.insert(getenv("OMIMCACHE") + "/mrkomimByGenotype.py", cmds.count + 1);
	  end if;

	  cmds.insert("-S" + getenv("DSQUERY"), cmds.count + 1);
	  cmds.insert("-D" + getenv("MGD"), cmds.count + 1);
	  cmds.insert("-U" + global_login, cmds.count + 1);
	  cmds.insert("-P" + global_passwd_file, cmds.count + 1);
	  cmds.insert("-K" + objectKey, cmds.count + 1);

	  -- Write cmds to user log
	  buf := "";
	  cmds.rewind;
	  while (cmds.more) do
	    buf := buf + cmds.next + " ";
	  end while;
	  buf := buf + "\n\n";
	  (void) mgi_writeLog(buf);

	  -- Execute
          proc_id : opaque := tu_fork_process(cmds[1], cmds, nil, PythonMarkerOMIMCacheEnd);
	  tu_fork_free(proc_id);

	end does;

--
-- PythonAlleleCombination
--
-- Activated from:  Genotype module, Allele module, Marker module
-- after an update or Marker withdrawal
--

	PythonAlleleCombination does
	  pythonevent : string := PythonAlleleCombination.pythonevent;
	  objectKey : string := PythonAlleleCombination.objectKey;
	  cmds : string_list := create string_list();
	  buf : string;

	  if (pythonevent = EVENT_ALLELECOMB_BYALLELE) then
	    cmds.insert(getenv("ALLELECACHE") + "/allelecombinationByAllele.py", cmds.count + 1);
	  elsif (pythonevent = EVENT_ALLELECOMB_BYMARKER) then
	    cmds.insert(getenv("ALLELECACHE") + "/allelecombinationByMarker.py", cmds.count + 1);
	  elsif (pythonevent = EVENT_ALLELECOMB_BYGENOTYPE) then
	    cmds.insert(getenv("ALLELECACHE") + "/allelecombinationByGenotype.py", cmds.count + 1);
	  end if;

	  cmds.insert("-S" + getenv("DSQUERY"), cmds.count + 1);
	  cmds.insert("-D" + getenv("MGD"), cmds.count + 1);
	  cmds.insert("-U" + global_login, cmds.count + 1);
	  cmds.insert("-P" + global_passwd_file, cmds.count + 1);
	  cmds.insert("-K" + objectKey, cmds.count + 1);

	  -- Write cmds to user log
	  buf := "";
	  cmds.rewind;
	  while (cmds.more) do
	    buf := buf + cmds.next + " ";
	  end while;
	  buf := buf + "\n\n";
	  (void) mgi_writeLog(buf);

	  -- Execute
          proc_id : opaque := tu_fork_process(cmds[1], cmds, nil, PythonAlleleCombinationEnd);
	  tu_fork_free(proc_id);

	end does;

--
-- PythonMarkerHomologyCache
--
-- Activated from:  Orthology module
-- after an update 
--

	PythonMarkerHomologyCache does
	  objectKey : string := PythonMarkerHomologyCache.objectKey;
	  cmds : string_list := create string_list();
	  buf : string;

	  cmds.insert(getenv("HOMOLOGYCACHE") + "/mrkHomologyByClass.py", cmds.count + 1);

	  cmds.insert("-S" + getenv("DSQUERY"), cmds.count + 1);
	  cmds.insert("-D" + getenv("MGD"), cmds.count + 1);
	  cmds.insert("-U" + global_login, cmds.count + 1);
	  cmds.insert("-P" + global_passwd_file, cmds.count + 1);
	  cmds.insert("-K" + objectKey, cmds.count + 1);

	  -- Write cmds to user log
	  buf := "";
	  cmds.rewind;
	  while (cmds.more) do
	    buf := buf + cmds.next + " ";
	  end while;
	  buf := buf + "\n\n";
	  (void) mgi_writeLog(buf);

	  -- Execute
          proc_id : opaque := tu_fork_process(cmds[1], cmds, nil, PythonMarkerHomologyCacheEnd);
	  tu_fork_free(proc_id);

	end does;

--
-- PythonMarkerOMIMCacheEnd
--

	PythonMarkerOMIMCacheEnd does
	end does;

--
-- PythonAlleleCombinationEnd
--

	PythonAlleleCombinationEnd does
	end does;

--
-- PythonMarkerHomologyCacheEnd
--

	PythonMarkerHomologyCacheEnd does
	end does;

end dmodule;
