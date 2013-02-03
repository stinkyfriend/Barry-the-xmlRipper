Placeholder for database table info.
<!---Using the '+' icons beside the nodes and attributes you wish to export from the xml file into your database.--->
<cfif 1 eq 2 AND analysis.alreadyRun()>
	<cfset strFields = analysis.readJSONFile()>
	<cfset fieldsSelected = StructKeyExists(strFields, "__selected")>
	<form action="controllers/ctl_step2.cfm" method="post">
		<cfset count = 0>
		<cfloop collection="#strFields#" item="key">

			<cfif IsStruct(strFields[key])>
				<cfset count++>
				<cfset originalName = ListLast(key, "|")>
				<cfset class = (fieldsSelected ? StructKeyExists(strFields[key],"process") AND strFields[key]["process"] ? (left(originalName, 1) eq "@" ? "attribute" : "node") : 'noaction' : (left(originalName, 1) eq "@" ? "attribute" : "node"))>
				<cfoutput>
				<div class="columnDefinition #class#"> 
					<input type="checkbox" name="process_#count#" #(fieldsSelected AND StructKeyExists(strFields[key],"process") AND strFields[key]["process"] ? 'checked="checked"' : '')# />
					<input type="text" name="newFieldName_#count#" value="#(fieldsSelected AND StructKeyExists(strFields[key],"columnname") ? strFields[key]["columnname"] : originalName)#" />
					#(fieldsSelected AND StructKeyExists(strFields[key],"columnname") ? originalName : '')#
					<input type="hidden" name="originalFieldName_#count#" value="#originalName#" />
					<input type="hidden" name="fullFieldLocation_#count#" value="#key#" />
				</div>
				</cfoutput>
			</cfif>

		</cfloop>
		<cfoutput><input type="hidden" name="filePath" value="#filePath#" /></cfoutput>
		<input type="submit" name="SaveSettings" value="Save" />
		<input type="submit" name="SaveSettings" value="Schema" />
		<input type="submit" name="SaveSettings" value="Data" />
	</form>

<!--- <cfelse>
	<cfset analysis.runAnalysis()>
	<cfoutput>#analysis.getRecordCount()#</cfoutput>
	<cfdump var="#analysis.getMetadata()#"> --->
</cfif>