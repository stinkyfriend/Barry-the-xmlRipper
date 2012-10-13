
<cfdump var="#form#">

<!--- If the File has been uploaded save it to the uploads folder --->
<cfif StructKeyExists(form, "FileUpload")>
	<cfinclude template="inc_upload.cfm">
</cfif>