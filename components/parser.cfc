<cfcomponent>
	
	<cffunction name="init" output="false">
		<cfargument name="filePath">
		<cfargument name="howManyRecords">
		<cfargument name="action" >
		
		<cfset var fis = createObject("java", "java.io.FileInputStream").init(arguments.filePath)>
		<cfset var bis = createObject("java", "java.io.BufferedInputStream").init(fis)>
		<cfset var XMLInputFactory = createObject("java", "javax.xml.stream.XMLInputFactory").newInstance()>
		<cfset var reader = XMLInputFactory.createXMLStreamReader(bis)>
		<cfset var countStartElements = 0>
		<cfset var countEvents = 0>
		<cfset var countRecords = 0>
		<cfset var indentCounter = 0>
		<cfset var extractCharacters = false>
		<cfset var node_path = "">
		<cfset var event = "">
		<cfset var node_attributes = []>
		<cfset var tempstr = {}>
		<cfset var str = {}>
		
		<!--- If there is another element then process it --->
		<cfloop condition="#reader.hasNext()#">
			<cfset event = reader.next()>
			
			<cfset countEvents++>
			<cfset str = {}>
			
			<!--- If the current event is a 'START_ELEMENT' --->
			<cfif event EQ reader.START_ELEMENT>
				<cfset countStartElements++>
				<cfset indentCounter++>
				<cfset node_path = node_path & (len(node_path) gt 0? '|' : '') & reader.getLocalName()>
				
				<cfset str["node_type"] = "start">
				<cfset str["indent"] = indentCounter>
				<cfset str["node_root"] = false>
				<cfset str["node_record"] = false>
				<cfset str["node_name"] = reader.getLocalName()>
				<cfset str["node_path"] = node_path>
				<cfset node_attributes = []>
				
				<!--- Get all the attributes for the current START_ELEMENT --->
				<cfset HowManyAttributes = reader.getAttributeCount()>
				<cfif HowManyAttributes gt 0>
					<cfloop from="1" to="#HowManyAttributes#" index="i" >
						<cfset tempstr = {}>
						<cfset tempstr["#reader.getAttributeLocalName(i-1)#"] =  reader.getAttributeValue(i-1)>
						<cfset ArrayAppend(node_attributes, tempstr)>
					</cfloop>
				</cfif>
				<cfset str["node_attributes"] = node_attributes>
				
		        <!--- If we're on the first "start element" then we can assume this is the root node. --->
				<cfif countStartElements eq 1>
					<cfset rootNode = reader.getLocalName()>
					<cfset str["node_root"] = true>
					<cfset extractCharacters = false>
				</cfif>
				
				<cfif countStartElements gte 2>
					
					<!--- If we're on the second "start element" then we can assume this identifies a record. --->
					<cfif countStartElements eq 2>
						<cfset recordNode = reader.getLocalName()>
						<cfset str["node_record"] = true>
						<cfset extractCharacters = false>
						<cfset countRecords++>
					</cfif>
			        
			        <cfif countStartElements gt 2>
						<cfset extractCharacters = true>
						<cfif reader.getLocalName() is recordNode>
							<cfset str["node_record"] = true>
							<cfset countRecords++>
						</cfif>
					</cfif>
				</cfif>
				<cfset action.process(str)>
		    </cfif>
		    
		    
		    <cfif event EQ reader.CHARACTERS and extractCharacters and len(trim(reader.getText())) gt 0>
				<cfset str["node_type"] = "characters">
				<cfset str["characters"] = reader.getText()>
				<cfset arguments.action.process(str)>
			</cfif>
		    
		    <cfif event EQ reader.END_ELEMENT>
				<cfset indentCounter-->				
				<cfset str["indent"] = indentCounter>
				<cfset str["node_type"] = "end">
				<cfset str["node_name"] = reader.getLocalName()>
				<cfset node_path = ListDeleteAt(node_path, ListFind(node_path, reader.getLocalName(), '|'), '|')>
				<cfset str["node_path"] = node_path>
				<cfset arguments.action.process(str)>
				<cfif reader.getLocalName() is recordNode>
					<cfif arguments.howManyRecords gte 0 AND countRecords gte arguments.howManyRecords>
						<cfbreak>
					</cfif>
				</cfif>
			</cfif>
			
		</cfloop>
		
		
		<cfset indentCounter-->				
		<cfset str["indent"] = indentCounter>
		<cfset str["node_type"] = "end">
		<cfset str["node_name"] = rootNode>
		<cfset arguments.action.process(str)>
		
		<cfset reader.close()>
		 
	</cffunction>
	
</cfcomponent>