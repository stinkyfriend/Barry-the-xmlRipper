<cfcomponent>
	<!---<cfset this.clientManagement = true>--->
	<cfset this.name = "Rubbertooth">
	<cfset this.datasource = "stinkylittlefriend">
	<cfset this.mappings = structNew() />
	<cfset this.mappings["/components"] = getDirectoryFromPath(getCurrentTemplatePath()) & "components/" />
	
	<cffunction name="onApplicationStart">
		
		<cfset setup()>
		
	</cffunction>
	
	<cffunction name="onRequestStart">
		
		<cfif StructKeyExists(url, "flush") AND url.flush>
			<cfset setup()>
		</cfif>
		
	</cffunction>
	
	<cffunction name="setup">
		<cfset application.objFiles = CreateObject("component" ,"components.files" ).init()>
	</cffunction>
	
</cfcomponent>