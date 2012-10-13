
<cfset analysis = CreateObject("component","components.analysis")>
<cfset analysis.init(form.filePath,-1)>

<cfset migrate = CreateObject("component","components.migrate")>
<cfset migrate.init(anaylsis)>

<cfset migrate.ripData()>
