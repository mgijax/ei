--
-- Name: PythonLib.d
--
-- 03/26/2015   lec
--      removed PythonAlleleCreCache
--
-- 02/11/2015	kstone
--	- TR11750/added PythonExpressionCache
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
--	  PythonADSystemLoad (obsolete)
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

#include <dblib.h>
#include <mgilib.h>
#include <teleuse/tu_file.h>

rules:

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

	  if (pythonevent = EVENT_ALLELECOMB_BYALLELE) then
	    cmds.insert("/opt/python3.7/bin/python3", cmds.count + 1);
	    cmds.insert(getenv("ALLCACHELOAD") + "/allelecombinationByAllele.py", cmds.count + 1);
	  elsif (pythonevent = EVENT_ALLELECOMB_BYMARKER) then
	    cmds.insert("/opt/python3.7/bin/python3", cmds.count + 1);
	    cmds.insert(getenv("ALLCACHELOAD") + "/allelecombinationByMarker.py", cmds.count + 1);
	  elsif (pythonevent = EVENT_ALLELECOMB_BYGENOTYPE) then
	    cmds.insert("/opt/python3.7/bin/python3", cmds.count + 1);
	    cmds.insert(getenv("ALLCACHELOAD") + "/allelecombinationByGenotype.py", cmds.count + 1);
	  end if;

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
-- PythonMarkerCVCache
--
-- Activated from:  TCD module, Marker Category Vocabulary
--

	PythonMarkerCVCache does
	  objectKey : string := PythonMarkerCVCache.objectKey;
	  cmds : string_list := create string_list();
	  buf : string;

	  cmds.insert("/opt/python3.7/bin/python3 " +  getenv("MRKCACHELOAD") + "/mrkmcv.py", cmds.count + 1);
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
          proc_id : opaque := tu_fork_process(cmds[1], cmds, nil, PythonMarkerCVCacheEnd);

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

	  cmds.insert("/opt/python3.7/bin/python3", cmds.count + 1);
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
-- PythonExpressionCache
--
-- Activated from:  Assay module
-- after an insert, update or delete
--

	PythonExpressionCache does
	  top : widget := PythonExpressionCache.source_widget.root;
	  dialog : widget := top->ReportDialog->Output;
	  objectKey : string := PythonExpressionCache.objectKey;
	  cmds : string_list := create string_list();
	  buf : string;

	  cmds.insert("/opt/python3.7/bin/python3", cmds.count + 1);
          cmds.insert(getenv("MGICACHELOAD") + "/gxdexpression.py", cmds.count + 1);
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
          proc_id : opaque := tu_fork_process(cmds[1], cmds, dialog, PythonExpressionCacheEnd);

	  while (tu_fork_ok(proc_id)) do
	    (void) keep_busy();
	  end while;

	  if (dialog.value.length > 0) then
	      (void) mgi_writeLog(dialog.value);
	  end if;

	  tu_fork_free(proc_id);

	end does;

--
-- PythonAlleleCombinationEnd
--

	PythonAlleleCombinationEnd does
	  (void) mgi_writeLog("Allele Combination Cache done.\n\n");
	end does;

--
-- PythonMarkerCVCacheEnd
--

	PythonMarkerCVCacheEnd does
	  (void) mgi_writeLog("Marker Category Vocabulary Cache done.\n\n");
	end does;

--
-- PythonInferredFromCacheEnd
--

	PythonInferredFromCacheEnd does
	  (void) mgi_writeLog("Inferred From Cache done.\n\n");
	end does;

--
-- PythonExpressionCacheEnd
--

	PythonExpressionCacheEnd does
	  (void) mgi_writeLog("Expression Cache done.\n\n");
	end does;

end dmodule;

