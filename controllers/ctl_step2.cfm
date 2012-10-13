<cfsetting requesttimeout="2500" >

<cfset analysis = CreateObject("component","components.analysis")>
<cfset analysis.init(form.filePath,-1)>
<cfset strFields = analysis.readJSONFile()>

<cfset FULL_FIELD = "fullfieldlocation_">
<cfset NEW_FIELD = "newfieldname_">
<cfset ORIGINAL_FIELD = "originalfieldname_">
<cfset PROCESS_FIELD = "process_">

<cfswitch expression="#LCase(form.savesettings)#">
	<cfcase value="save">
		<cfloop collection="#form#" item="formName">
			
			<cfif not formName is "fieldnames" 
				AND not formName is "savesettings"
					AND not formName is "filePath">
				
				<cfset batchNumber = ListLast(formName, "_")>
				
				<cfif StructKeyExists(form, "#PROCESS_FIELD##batchNumber#")
					AND form["#PROCESS_FIELD##batchNumber#"] is "on">
					<cfset strFields[form["#FULL_FIELD##batchNumber#"]]["columnname"] = form["#NEW_FIELD##batchNumber#"]>
					<cfset strFields[form["#FULL_FIELD##batchNumber#"]]["process"] = true>
				<cfelse>
					<cfset StructDelete(strFields[form["#FULL_FIELD##batchNumber#"]], "process")>
					<cfset StructDelete(strFields[form["#FULL_FIELD##batchNumber#"]], "columnname")>
				</cfif> 
					
			</cfif> 
			
			<cfset strFields["__selected"] = true>

			<cfset analysis.save(strFields, "analysis")>
			
		</cfloop>
	</cfcase>
	<cfcase value="schema">
		<cfset arr = ArrayNew(1)>
		<cfloop collection="#strFields#" item="key">
			<cfif IsStruct(strFields[key]) AND StructKeyExists(strFields[key], "process")>
				<cfset ArrayAppend(arr, "#UCase(strFields[key]['columnname'])# #strFields[key]['datatype']##strFields[key]['datatype'] is 'varchar' ? '(' & strFields[key]['length']+20 & ')' : strFields[key]['datatype'] is 'decimal' ? '(' & strFields[key]['length'] & ')' : ''# #strFields[key]['nullable'] ? '' : 'NOT NULL'#")>
			</cfif>
		</cfloop>
<cfsavecontent variable="createScript">CREATE TABLE TOI_T_TOILETS
(T_ID MEDIUMINT NOT NULL AUTO_INCREMENT, PRIMARY KEY (T_ID),<cfset iterator = arr.iterator()><cfloop condition="iterator.hasNext()"><cfoutput>#iterator.next() & (iterator.hasnext() ? ',' : '')#</cfoutput></cfloop>)</cfsavecontent>
		
		<cfset analysis.save(createScript, "create")>
		
		<cfset analysis.createTable()>
	</cfcase>
	<cfcase value="data">
		<cfset migrate = CreateObject("component","components.migrate")>
		<cfset migrate.init(analysis)>
		
		<cfset migrate.ripData()>
	</cfcase>
</cfswitch>


