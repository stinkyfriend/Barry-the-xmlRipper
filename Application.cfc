<cfcomponent>
	
	<cfset this.name = "Barry-XML-Ripper">
	<cfset this.mappings = structNew()>
	<!--- Seems a bit pointless setting a mapping to a folder in the root of the site. --->
	<cfset this.mappings["/components"] = getDirectoryFromPath(getCurrentTemplatePath()) & "components/">
	
	<cffunction name="onApplicationStart">
		
		<cfset setup()>
		
	</cffunction>
	
	<cffunction name="onRequestStart">
		
		<cfif StructKeyExists(url, "flush") AND url.flush>
			<!--- Ability to check if there are any new files 'data' location. --->
			<cfset setup()>
		</cfif>
		
	</cffunction>
	
	<cffunction name="setup">
		<!--- Interrogate the file location where all the XML files are located i.e. /data/
			The XML files found in this location will be available to the user to parse/render/analyse. --->
		<cfset application.objFileManager = CreateObject("component" ,"components.core.obj_FileManager" ).init()>
	</cffunction>
	
</cfcomponent>