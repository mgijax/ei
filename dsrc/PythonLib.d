--
-- Name: PythonLib.d
--
-- lec	04/14/2014
--	- TR11549/PythonImageCache obsolete
--	- TR11549/PythonMarkerHomologyCache obsolete
--
-- 06/30/2010	lec
--	- TR 9316
--	  PythonMarkerCVCache
--
-- 09/09/2009	lec
--	- TR 9797
--        PythonAlleleCreCache
--	  PythonADSystemLoad
--
-- 06/17/2008	lec
--	- TR 9057; Inferred From Cache; errors are printed
--
-- 04/15/2008	lec
--	- TR 8633; Inferred From Cache
--
-- 12/04/2006	lec
--	- TR 7710; Image Cache
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
-- PythonADSystemLoad
--
-- Activated from:  Anatomical Dictionary module
--

	PythonADSystemLoad does
	  top : widget := PythonADSystemLoad.source_widget.root;
	  dialog : widget := top->ReportDialog->Output;
	  cmds : string_list := create string_list();
	  buf : string;

	  if (getenv("EISSHCOMMAND") != "") then
	  	cmds.insert(getenv("EISSHCOMMAND"), cmds.count + 1);
	  end if;

	  cmds.insert(getenv("ADSYSTEMLOAD") + "/adsystemload.py", cmds.count + 1);
	  cmds.insert("-S" + getenv("MGD_DBSERVER"), cmds.count + 1);
	  cmds.insert("-D" + getenv("MGD_DBNAME"), cmds.count + 1);
	  cmds.insert("-U" + global_login, cmds.count + 1);
	  cmds.insert("-P" + global_passwd_file, cmds.count + 1);

	  -- Write cmds to user log
	  buf := "";
	  cmds.rewind;
	  while (cmds.more) do
	    buf := buf + cmds.next + " ";
	  end while;
	  buf := buf + "\n\n";
	  (void) mgi_writeLog(buf);

	  -- Execute
	  dialog.value := "";
          proc_id : opaque := tu_fork_process(cmds[1], cmds, dialog, PythonADSystemLoadEnd);

	  while (tu_fork_ok(proc_id)) do
	    (void) keep_busy();
	  end while;

	  if (dialog.value.length > 0) then
	      (void) mgi_writeLog(dialog.value);
	  end if;

	  tu_fork_free(proc_id);

	end does;

--
-- PythonAlleleCombination
--
-- Activated from:  Genotype module, Allele module, Marker module
-- after an update or Marker withdrawal
--

	PythonAlleleCombination does
	  top : widget := PythonAlleleCombination.source_widget.root;
	  pythonevent : string := PythonAlleleCombination.pythonevent;
	  objectKey : string := PythonAlleleCombination.objectKey;
	  dialog : widget := top->ReportDialog->Output;
	  cmds : string_list := create string_list();
	  buf : string;

	  if (getenv("EISSHCOMMAND") != "") then
	  	cmds.insert(getenv("EISSHCOMMAND"), cmds.count + 1);
	  end if;

	  if (pythonevent = EVENT_ALLELECOMB_BYALLELE) then
	    cmds.insert(getenv("ALLCACHELOAD") + "/allelecombinationByAllele.py", cmds.count + 1);
	  elsif (pythonevent = EVENT_ALLELECOMB_BYMARKER) then
	    cmds.insert(getenv("ALLCACHELOAD") + "/allelecombinationByMarker.py", cmds.count + 1);
	  elsif (pythonevent = EVENT_ALLELECOMB_BYGENOTYPE) then
	    cmds.insert(getenv("ALLCACHELOAD") + "/allelecombinationByGenotype.py", cmds.count + 1);
	  end if;

	  cmds.insert("-S" + getenv("MGD_DBSERVER"), cmds.count + 1);
	  cmds.insert("-D" + getenv("MGD_DBNAME"), cmds.count + 1);
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
	  dialog.value := "";
          proc_id : opaque := tu_fork_process(cmds[1], cmds, dialog, PythonAlleleCombinationEnd);

	  while (tu_fork_ok(proc_id)) do
	    (void) keep_busy();
	  end while;

	  if (dialog.value.length > 0) then
	      (void) mgi_writeLog(dialog.value);
	  end if;

	  tu_fork_free(proc_id);

	end does;

--
-- PythonAlleleCreCache
--
-- Activated from:  Allele module, Assay module
--

	PythonAlleleCreCache does
	  top : widget := PythonAlleleCreCache.source_widget.root;
	  pythonevent : string := PythonAlleleCreCache.pythonevent;
	  objectKey : string := PythonAlleleCreCache.objectKey;
	  dialog : widget := top->ReportDialog->Output;
	  cmds : string_list := create string_list();
	  buf : string;

	  if (getenv("EISSHCOMMAND") != "") then
	  	cmds.insert(getenv("EISSHCOMMAND"), cmds.count + 1);
	  end if;

	  if (pythonevent = EVENT_ALLELECRE_BYALLELE) then
	    cmds.insert(getenv("ALLCACHELOAD") + "/allelecrecacheByAllele.py", cmds.count + 1);
	  elsif (pythonevent = EVENT_ALLELECRE_BYASSAY) then
	    cmds.insert(getenv("ALLCACHELOAD") + "/allelecrecacheByAssay.py", cmds.count + 1);
	  end if;

	  cmds.insert("-S" + getenv("MGD_DBSERVER"), cmds.count + 1);
	  cmds.insert("-D" + getenv("MGD_DBNAME"), cmds.count + 1);
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
	  dialog.value := "";
          proc_id : opaque := tu_fork_process(cmds[1], cmds, dialog, PythonAlleleCreCacheEnd);

	  while (tu_fork_ok(proc_id)) do
	    (void) keep_busy();
	  end while;

	  if (dialog.value.length > 0) then
	      (void) mgi_writeLog(dialog.value);
	  end if;

	  tu_fork_free(proc_id);

	end does;

--
-- PythonMarkerCVCache
--
-- Activated from:  TCD module, Marker Category Vocabulary
--

	PythonMarkerCVCache does
	  objectKey : string := PythonMarkerCVCache.objectKey;
	  cmds : string_list := create string_list();
	  buf : string;

	  if (getenv("EISSHCOMMAND") != "") then
	  	cmds.insert(getenv("EISSHCOMMAND"), cmds.count + 1);
	  end if;

	  cmds.insert(getenv("MRKCACHELOAD") + "/mrkmcv.py", cmds.count + 1);
	  cmds.insert("-S" + getenv("MGD_DBSERVER"), cmds.count + 1);
	  cmds.insert("-D" + getenv("MGD_DBNAME"), cmds.count + 1);
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
          proc_id : opaque := tu_fork_process(cmds[1], cmds, nil, PythonMarkerCVCacheEnd);

	  while (tu_fork_ok(proc_id)) do
	    (void) keep_busy();
	  end while;

	  tu_fork_free(proc_id);

	end does;

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

	  if (getenv("EISSHCOMMAND") != "") then
	  	cmds.insert(getenv("EISSHCOMMAND"), cmds.count + 1);
	  end if;

	  if (pythonevent = EVENT_OMIM_BYALLELE) then
	    cmds.insert(getenv("MRKCACHELOAD") + "/mrkomimByAllele.py", cmds.count + 1);
	  elsif (pythonevent = EVENT_OMIM_BYMARKER) then
	    cmds.insert(getenv("MRKCACHELOAD") + "/mrkomimByMarker.py", cmds.count + 1);
	  elsif (pythonevent = EVENT_OMIM_BYGENOTYPE) then
	    cmds.insert(getenv("MRKCACHELOAD") + "/mrkomimByGenotype.py", cmds.count + 1);
	  end if;

	  cmds.insert("-S" + getenv("MGD_DBSERVER"), cmds.count + 1);
	  cmds.insert("-D" + getenv("MGD_DBNAME"), cmds.count + 1);
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
-- PythonReferenceCache
--
-- Activated from:  Reference module
-- after an insert, update or delete
--

	PythonReferenceCache does
	  objectKey : string := PythonReferenceCache.objectKey;
	  cmds : string_list := create string_list();
	  buf : string;

	  if (getenv("EISSHCOMMAND") != "") then
	  	cmds.insert(getenv("EISSHCOMMAND"), cmds.count + 1);
	  end if;

	  cmds.insert(getenv("MGICACHELOAD") + "/bibcitation.py", cmds.count + 1);
	  cmds.insert("-S" + global_server, cmds.count + 1);
	  cmds.insert("-D" + global_database, cmds.count + 1);
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
-- PythonInferredFromCache
--
-- Activated from:  GO Annotation module
-- after an insert, update or delete
--

	PythonInferredFromCache does
	  top : widget := PythonInferredFromCache.source_widget.root;
	  dialog : widget := top->ReportDialog->Output;
	  objectKey : string := PythonInferredFromCache.objectKey;
	  cmds : string_list := create string_list();
	  buf : string;

	  if (getenv("EISSHCOMMAND") != "") then
	  	cmds.insert(getenv("EISSHCOMMAND"), cmds.count + 1);
	  end if;

	  cmds.insert(getenv("MGICACHELOAD") + "/inferredfrom.py", cmds.count + 1);
	  cmds.insert("-S" + global_server, cmds.count + 1);
	  cmds.insert("-D" + global_database, cmds.count + 1);
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

	  dialog.value := "";
          proc_id : opaque := tu_fork_process(cmds[1], cmds, dialog, PythonInferredFromCacheEnd);

	  while (tu_fork_ok(proc_id)) do
	    (void) keep_busy();
	  end while;

	  tu_fork_free(proc_id);

	end does;

--
-- PythonADSystemLoadEnd
--

	PythonADSystemLoadEnd does
	  (void) mgi_writeLog("AD System Load done.\n\n");
	end does;

--
-- PythonAlleleCombinationEnd
--

	PythonAlleleCombinationEnd does
	  (void) mgi_writeLog("Allele Combination Cache done.\n\n");
	end does;

--
-- PythonAlleleCreCacheEnd
--

	PythonAlleleCreCacheEnd does
	  (void) mgi_writeLog("Allele Cre Cache done.\n\n");
	end does;

--
-- PythonMarkerCVCacheEnd
--

	PythonMarkerCVCacheEnd does
	  (void) mgi_writeLog("Marker Category Vocabulary Cache done.\n\n");
	end does;

--
-- PythonMarkerOMIMCacheEnd
--

	PythonMarkerOMIMCacheEnd does
	  (void) mgi_writeLog("OMIM Cache done.\n\n");
	end does;

--
-- PythonReferenceCacheEnd
--

	PythonReferenceCacheEnd does
	  (void) mgi_writeLog("Reference Cache done.\n\n");
	end does;

--
-- PythonInferredFromCacheEnd
--

	PythonInferredFromCacheEnd does
	  (void) mgi_writeLog("Inferred From Cache done.\n\n");
	end does;

end dmodule;

