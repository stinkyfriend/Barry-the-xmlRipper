<cfcomponent extends="obj_XMLParser" implements="IHandler">
	
	<cfset variables.s = "">
	
	<cffunction name="startElement" returntype="void" access="public">
		<cfargument name="details" type="struct">
		
		<cfif arguments.details.indent gt 1>
			<cfset buildString('<div>')>
		</cfif>
		<!--- Open the node/tag i.e. <bob --->
		<cfset buildString('<span class="operators">&lt;</span>')>
		<cfset buildString('<span class="node-name">#arguments.details.node_name#</span>')>
		
		<cfset closeAngleBracket = true>
		
		<!--- If tag/node has attributes then we need to render these. --->
		<cfif structKeyExists(arguments.details, "node_attributes") AND StructCount(arguments.details.node_attributes) gt 0>
			<cfset howManyAttributes = StructCount(arguments.details.node_attributes)>
			<cfset countAttributes = 0>
			<cfloop collection="#arguments.details.node_attributes#" item="attrib">
				<cfset countAttributes++>
				<cfset buildString(' <div><div><span class="attr-name">#attrib#</span><span class="operators">=</span><span class="attr-value">"#arguments.details.node_attributes[attrib]#"</span>' & (howManyAttributes eq countAttributes?'<span class="operators">&gt;</span>' : '') & '</div></div>')>
				<cfset closeAngleBracket = false>
			</cfloop>
		</cfif>
		
		<!--- once the attributes have been added then we close the tag/node i.e. > --->
		<cfset (closeAngleBracket ? buildString('<span class="operators">&gt;</span>') : '')>
		
	</cffunction>
	
	<cffunction name="characters" returntype="void" access="public">
		<cfargument name="details" type="struct">
		
		<cfif len(trim(arguments.details.characters)) gt 0>
            <!--- If there are any characters then add them to the render too. --->
            <cfset buildString('<div><span class="node-value">#arguments.details.characters#</span></div>')>
        </cfif>
	</cffunction>
	
	<cffunction name="endElement" returntype="void" access="public">
		<cfargument name="details" type="struct">
		
		<!--- Finally the closing tag/node i.e. </tag> --->
		<cfset buildString('<span class="operators">&lt;/</span><span class="node-name">#arguments.details.node_name#</span><span class="operators">&gt;</span></div>')>
		
	</cffunction>
	
	<cffunction name="buildString" access="private" returntype="void" hint="This concatenates the string together.">
		<cfargument name="string">
		
		<cfset variables.s = variables.s & arguments.string>		 
		
	</cffunction>
	
	<cffunction name="getRender" access="public" hint="Return the finished redner of the first 'record'.">
		<cfset super.run()>
		
		<cfreturn variables.s>		
	</cffunction>
	
</cfcomponent>