<cfcomponent accessors="true">
	
	<cfproperty name="FilePath">
	<cfproperty name="RecordLimit">
	<cfproperty name="RecordNode">	
	
	<cffunction name="init" access="public" returntype="obj_XMLParser">
		<cfargument name="filePath" required="true" hint="The full path to the xml file you want to analyse">
		<cfargument name="howManyRecords" required="false" default="-1" hint="How many records [properties] do you want to analyse? -1 means all records.">
		<cfargument name="recordNode" required="false" hint="Enter the node that identifies the 'record' node">
		
		<cfif FileExists(arguments.filePath)>
			<cfset setFilePath(arguments.filePath)>
			<cfset setRecordLimit(arguments.howManyrecords)>
			<cfset StructKeyExists(arguments, "recordNode") ? setRecordNode(arguments.recordNode) : ''>
		<cfelse>
			<cfthrow message="The file you have pointed me at doesn't seem to exist. #arguments.filePath#">
		</cfif>		
		
		<cfreturn this>
	</cffunction>
	
	<!--- Takes the path to a large XML file and parses it.
		This calls three methods startElement() characters() endElement() that will need to be overridden. --->
	<cffunction name="run">
		
		<cfset var fis = createObject("java", "java.io.FileInputStream").init(getFilePath())>
		<cfset var bis = createObject("java", "java.io.BufferedInputStream").init(fis)>
		<cfset var XMLInputFactory = createObject("java", "javax.xml.stream.XMLInputFactory").newInstance()>
		<cfset var reader = XMLInputFactory.createXMLStreamReader(bis)>
		<cfset var countStartElements = 0>
		<cfset var countEvents = 0>
		<cfset var countRecords = 0>
		<cfset var indentCounter = 0>
		<cfset var extractCharacters = false>
		<cfset var str = {}>
		<cfset var node_path = "">
		<cfset var event = "">
		<cfset var node_attributes = []>
		<cfset var tempstr = {}>

		<!--- If there is another element (a start node, characters or an end node) then process it. --->
		<cfloop condition="#reader.hasNext()#">
			<cfset str = {}>
			<cfset countEvents++>
			<cfset event = reader.next()>
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
				<cfset node_attributes = {}>

				<!--- Get all the attributes for the current START_ELEMENT --->
				<cfset HowManyAttributes = reader.getAttributeCount()>
				<cfif HowManyAttributes gt 0>
					<cfloop from="1" to="#HowManyAttributes#" index="i" >
						<cfset tempstr = {}>
						<cfset tempstr["#reader.getAttributeLocalName(i-1)#"] =  reader.getAttributeValue(i-1)>
						<cfset StructAppend(node_attributes, tempstr)>
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

					<cfif not IsNull(getRecordNode()) AND getRecordNode() eq reader.getLocalName() AND IsNull(recordNode)>
						<!--- If the user has identified and passed in a record name then we treat this node as the record node --->  
						<cfset recordNode = reader.getLocalName()>
						<cfset str["node_record"] = true>
						<cfset extractCharacters = false>
					<cfelseif IsNull(getRecordNode()) AND countStartElements eq 2>
						<!--- If we're on the second "start element" and the user hasn't passed in the name for the 'record' node 
								then we can assume this identifies a record. --->
						<cfset recordNode = reader.getLocalName()>
						<cfset str["node_record"] = true>
						<cfset extractCharacters = false>
					</cfif>
					
					<cfif reader.getLocalName() is recordNode>
						<cfset str["node_record"] = true>
						<cfset countRecords++>
					</cfif>

					<cfif countStartElements gt 2>
						<cfset extractCharacters = true>
					</cfif>
				</cfif>
				<cfset startElement(str)>
			</cfif>

			<cfif event EQ reader.CHARACTERS and extractCharacters and len(trim(reader.getText())) gt 0>
				<cfset str["node_type"] = "characters">
				<cfset str["characters"] = reader.getText()>
				<cfset characters(str)>
			</cfif>

			<cfif event EQ reader.END_ELEMENT>
				<cfset indentCounter-->				
				<cfset str["indent"] = indentCounter>
				<cfset str["node_type"] = "end">
				<cfset str["node_name"] = reader.getLocalName()>
				<cfset node_path = ListDeleteAt(node_path, ListFind(node_path, reader.getLocalName(), '|'), '|')>
				<cfset str["node_path"] = node_path>
				<cfset str["node_record"] = reader.getLocalName() is recordNode>
				<cfset endElement(str)>
				<cfif str.node_record>
					<cfif getRecordLimit() gte 0 AND countRecords gte getRecordLimit()>
						<cfbreak>
					</cfif>
				</cfif>
			</cfif>

		</cfloop>

		<cfset indentCounter-->				
		<cfset str["indent"] = indentCounter>
		<cfset str["node_type"] = "end">
		<cfset str["node_name"] = rootNode>

		<cfset reader.close()>

	</cffunction>
</cfcomponent>