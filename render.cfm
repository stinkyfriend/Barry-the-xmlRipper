<!--- Since this template is included only when an XML file has been selected
we can now attempt to parse the XML file render it nicely for the user to see available nodes/attributes etc. --->
<cfset filePath = qryFile.directory & "/" & qryFile.name> 
<cfset objRender = CreateObject("component","components.core.obj_Render").init(filepath=filePath, howManyRecords=1)>
<cfoutput>
#objRender.getRender()#
</cfoutput>