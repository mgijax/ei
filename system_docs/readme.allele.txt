Allele module notes (Allele.d)
==============================

Add

. if Status = 'Approved': Approved By = current user, Approved Date = current date

. default Inheritance Mode = Not Applicable

. if Parent Cell Line = blank and Allele Type in: 'Gene trapped', 'Targeted'
	
	strain = Not Specified
  else
	strain = Not Applicable

Modify

. Confirm changes to Mutant, Parent, Strain

. Confirm changes to Allele Germline Transmission

. Confirm changes to Allele Mixed

. Confirm changes to Allele Status, Strain

. reload order of Genotype (sp: GXD_orderGenotypes)

. update these caches if the SYMBOL has changed:
	alelle combination cache, by allele (cache:allcacheload/allelecombination.csh)
	. OMIM cache, by allele (cache:mrkcacheload/mrkomim.csh)

Add/Modify:

. Original: At most one Original Reference is required

. Transmission: At most one Transmission Reference is allowed.

. if Name = "wild type" or "wild-type": ALL_Allele.isWildType = true

. if isWildType = true, then add mutant cell line

. At most one Primary Image Pane is allowed.

. Marker Associations
  . if the marker symbol is blank, print a warning:
	There is no Marker association for this Allele.

  . if the marker has been changed or deleted, print a warning:
	A Marker has been changed or deleted.
	Please verify the Allele Symbol.

. Mutant Cell Line

  if no parent and no mutant:
	if 'Gene trapped' or 'Targeted'

              select the derivation key that is associated with the specified 
                   allele type
                   creator = Not Specified
                   vector = Not Specified
                   parent cell line = Not Specified
                   strain = Not Specified
                   cell line type
                
 	      if derivation is not found: Cannot find Derivation for this Allele Type and Parent = 'Not Specified'

  if parent and no mutant:

              select the derivation key that is associated with the specified 
                   allele type
                   creator = Not Specified
                   vector = Not Specified
                   parent cell line
                   strain
                   cell line type
                
 	      if derivation is not found: Cannot find Derivation for this Allele Type and Parent

  if not parent and mutant:

	Only specified MCL's may be entered in the Mutant Cell Line field

  if parent and mutant:

	if mutant cell line != Not Specified
		skip

	if modifying the derivation:
            select the derivation key that is associated with the specified
                 allele type
                 creator
                 vector
                 parent cell line
                 strain
                 cell line type

	    if derivation is not found: Cannot find Derivation for this Allele Type and Parent

	else
	    add association

. reload the Allele Label cache (sp: ALL_reloadLabel)

Verification (when user tabs thru field):

. Verify J:

. Veriy Marker

. Verify Mutant Cell Line
	Invalid Mutant Cell Line

. Verify Parent Cell Line
	Invalid Parent Cell Line

. Verify Add permissions:
	. You do not have permission to add an 'Autoload' Allele.
	. Approved Allele Symbol must have an Approved Marker
	. You do not have permission to add a 'Deleted' Allele.
	. You do not have permission to add an 'In Progress' Allele.
	. You do not have permission to add a 'Reserved' Allele.
	. You do not have permission to add an 'Approved' Allele.

. Verify Modify permissions:
	. Approved/Autoload Allele Symbol must have an Approved Marker
	. You cannot change the Allele status from Approved/Autoload to Deleted, Reserved or Pending.
	  This Allele is cross-referenced to a GO annotation.
	. Allele Symbol is referenced in GXD Allele Pair Record(s); 
          Approved/Autoload Status cannot be changed.
	. Allele Symbol is referenced in Mapping Experiment Marker Record(s); 
          Approved/Autoload Status cannot be changed.
	. Allele Symbol is referenced in Strain/Allele Record(s); 
          Approved/Autoload Status cannot be changed.
	. You do not have permission to modify an Allele with In Progress status.
	. You do not have permission to modify this Allele.
	. You do not have permission to modify an Allele with Reserved status
	. You do not have permission to modify this Allele.
	. You do not have permission to modify an Allele with Approved/Autoload status.
	. You do not have permission to modify this Allele.
	. You do not have permission to change the Allele status from Pending to Approved/Autoload.
	. You do not have permission to modify this Allele.
	. You do not have permission to change the Allele status from Pending or Deleted to Reserved.
	. You do not have permission to change the Allele status from Pending to Deleted.
	. You do not have permission to modify this Allele.
	. You do not have permission to change the Allele status from Reserved to Deleted.
	. You do not have permission to change the Allele status from Deleted or Reserved to Pending 
		or Approved/Autoload.
	. You do not have permission to update nomenclature for this Allele record.
	. You do not have permission to update nomenclature for this Allele record.
	. You do not have permission to update nomenclature for this Allele record.
	. You do not have permission to update nomenclature for this Allele record.
	. You do not have permission to update nomenclature for this Allele record.
	. You do not have permission to change the Allele status from 
		Approved/Autoload to Deleted, Reserved or Pending.
	. You cannot change the Allele status because this Allele is cross-referenced to 
		Genotype, Mapping or Strain data.
	. You do not have permission to delete this Allele record.
	. Allele Symbol is referenced in Allele Knockout Cache Record(s)
	. Allele Symbol is referenced in GXD Allele Pair Record(s)
	. Allele Symbol is referenced in Mapping Experiment Marker Record(s)
	. Allele Symbol is referenced in Strain/Allele Record(s)

