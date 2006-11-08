--
-- Name: PythonLib.d
--
-- 08/30/2006	lec
--	- TR 7867; added tu_fork_ok loop
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
	    cmds.insert(getenv("MRKCACHELOAD") + "/mrkomimByAllele.py", cmds.count + 1);
	  elsif (pythonevent = EVENT_OMIM_BYMARKER) then
	    cmds.insert(getenv("MRKCACHELOAD") + "/mrkomimByMarker.py", cmds.count + 1);
	  elsif (pythonevent = EVENT_OMIM_BYGENOTYPE) then
	    cmds.insert(getenv("MRKCACHELOAD") + "/mrkomimByGenotype.py", cmds.count + 1);
	  end if;

	  cmds.insert(getenv("PYTHON_PARAMS"), cmds.count + 1);
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

	  while (tu_fork_ok(proc_id)) do
	    (void) keep_busy();
	  end while;

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
	    cmds.insert(getenv("ALLCACHELOAD") + "/allelecombinationByAllele.py", cmds.count + 1);
	  elsif (pythonevent = EVENT_ALLELECOMB_BYMARKER) then
	    cmds.insert(getenv("ALLCACHELOAD") + "/allelecombinationByMarker.py", cmds.count + 1);
	  elsif (pythonevent = EVENT_ALLELECOMB_BYGENOTYPE) then
	    cmds.insert(getenv("ALLCACHELOAD") + "/allelecombinationByGenotype.py", cmds.count + 1);
	  end if;

	  cmds.insert(getenv("PYTHON_PARAMS"), cmds.count + 1);
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

	  while (tu_fork_ok(proc_id)) do
	    (void) keep_busy();
	  end while;

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

	  cmds.insert(getenv("HOMOLOGYCACHE") + "/mrkhomologyByClass.py", cmds.count + 1);

	  cmds.insert(getenv("PYTHON_PARAMS"), cmds.count + 1);
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

	  while (tu_fork_ok(proc_id)) do
	    (void) keep_busy();
	  end while;

	  tu_fork_free(proc_id);

	end does;

--
-- PythonReferenceCache
--
-- Activated from:  Reference module
-- after an insert, update or delete
--

	PythonReferenceCache does
	  objectKey : string := PythonReferenceCache.objectKey;
	  cmds : string_list := create string_list();
	  buf : string;

	  cmds.insert(getenv("MGICACHELOAD") + "/bibcitation.py", cmds.count + 1);

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
          proc_id : opaque := tu_fork_process(cmds[1], cmds, nil, PythonReferenceCacheEnd);

	  while (tu_fork_ok(proc_id)) do
	    (void) keep_busy();
	  end while;

	  tu_fork_free(proc_id);

	end does;

--
-- PythonMarkerOMIMCacheEnd
--

	PythonMarkerOMIMCacheEnd does
	  (void) mgi_writeLog("OMIM Cache done.\n\n");
	end does;

--
-- PythonAlleleCombinationEnd
--

	PythonAlleleCombinationEnd does
	  (void) mgi_writeLog("Allele Combination Cache done.\n\n");
	end does;

--
-- PythonMarkerHomologyCacheEnd
--

	PythonMarkerHomologyCacheEnd does
	  (void) mgi_writeLog("Homology Cache done.\n\n");
	end does;

--
-- PythonReferenceCacheEnd
--

	PythonReferenceCacheEnd does
	  (void) mgi_writeLog("Reference Cache done.\n\n");
	end does;

end dmodule;

