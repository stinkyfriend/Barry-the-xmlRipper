<cfcomponent extends="components.core.obj_XMLParser" implements="components.core.IHandler">
	
	<cfset variables.counterStart = 0>
	<cfset variables.counterChars = 0>
	<cfset variables.counterEnd = 0>
	
	<cffunction name="doIt">
		<cfset super.run()>
				
	</cffunction>
	
	<cffunction name="startElement" returntype="void" access="public">
		<cfargument name="details" type="struct">
		
		<cfset variables.counterStart++>
		
	</cffunction>

	<cffunction name="characters" returntype="void" access="public">
		<cfargument name="details" type="struct">
		
		<cfset variables.counterChars++>
					
	</cffunction>
	
	<cffunction name="endElement" returntype="void" access="public">
		<cfargument name="details" type="struct">
		
		<cfset variables.counterEnd++>
		
	</cffunction>
	
	<cffunction name="getStartElementCount">
		
		<cfreturn variables.counterStart>
	</cffunction>
	
	<cffunction name="getCharacterCount">
		
		<cfreturn variables.counterChars>
	</cffunction>
	
	<cffunction name="getEndElementCount">
		
		<cfreturn variables.counterEnd>
	</cffunction>
	
</cfcomponent>