<cfcomponent implements="IAction">
	
	<cffunction name="init">
		<cfset variables.s = "">
	</cffunction>
	
	<cffunction name="process">
		<cfargument name="record">
		
		<cfif arguments.record.node_type neq 'characters'>
			<cfif arguments.record.node_type eq 'start' AND arguments.record.indent gt 1>
                <cfset variables.s = variables.s & '<div>'>
            </cfif>
			<cfset variables.s = variables.s & '<span style="color: ##F8F8F2">&lt;'>
			<cfif arguments.record.node_type eq 'end'>
				<cfset variables.s = variables.s & '/'>
			</cfif>
			<cfset variables.s = variables.s & '</span>'>
			<cfset variables.s = variables.s & '<span style="color: ##F92672">#arguments.record.node_name#</span>'>
		</cfif>
		
		<cfset closeAngleBracket = true>
		<cfif structKeyExists(arguments.record, "node_attributes") AND ArrayLen(arguments.record.node_attributes) gt 0>
			<cfset howManyAttributes = ArrayLen(arguments.record.node_attributes)>
			<cfset countAttributes = 0>
			<cfloop array="#arguments.record.node_attributes#" index="attrib">
				<cfset countAttributes++>
				<cfset variables.s = variables.s & ' <div><div><span style="color: ##A6E22E">#StructKeyArray(attrib)[1]#</span><span style="color: ##F8F8F2">=</span><span style="color: ##E6DB74">"#attrib[StructKeyArray(attrib)[1]]#"</span>' & (howManyAttributes eq countAttributes?'<span style="color: ##F8F8F2">&gt;</span>' : '') & '</div></div>'>
				<cfset closeAngleBracket = false>
			</cfloop>
		</cfif>
		
		<cfif arguments.record.node_type neq 'characters'>
			<cfset variables.s = variables.s & (closeAngleBracket?'<span style="color: ##F8F8F2">&gt;</span>' : '')>
			<cfif arguments.record.node_type eq 'end'>
                <cfset variables.s = variables.s & '</div>'>
            </cfif>
		</cfif>
		
		<cfif arguments.record.node_type eq 'characters' AND len(trim(arguments.record.characters)) gt 0>
            <cfset variables.s = variables.s & '<div><span style="color: ##F8F8F2">#arguments.record.characters#</span></div>'>
        </cfif>
		
	</cffunction>
	
	<cffunction name="getRender">
		<cfreturn variables.s>		
	</cffunction>
	
</cfcomponent>