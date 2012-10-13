<!--- Select the xml file you'd like to parse. --->
<cfset filePath = ExpandPath(".") & "\source\ToiletmapExport.xml">

<!--- Indicate whether or not you want to only interrogate a sub set of the data first --->


<cfset fis = createObject("java", "java.io.FileInputStream").init(filePath)>
<cfset bis = createObject("java", "java.io.BufferedInputStream").init(fis)>
<cfset XMLInputFactory = createObject("java", "javax.xml.stream.XMLInputFactory").newInstance()>
<cfset reader = XMLInputFactory.createXMLStreamReader(bis)>

<cfset countStartElements = 0>
<cfset countEvents = 0>
<cfset countRecords = 0>
<cfset indentCounter = 0>
<cfset howManyRecords = 3>
<cfset extractCharacters = false>
<cfflush>
<cfoutput>
<cfloop condition="#reader.hasNext()#">
	<cfset countEvents++>
	<cfset event = reader.next()>
	
	<cfif event EQ reader.START_ELEMENT>
		<cfset countStartElements++>
		<cfset indentCounter++>
		<!--- Get all the attributes for the current START_ELEMENT --->
		<cfset HowManyAttributes = reader.getAttributeCount()>
        <cfset attrs = "">
		<cfif HowManyAttributes gt 0>
			<cfloop from="1" to="#HowManyAttributes#" index="i" >
				<cfset attrs = attrs & ' ' & reader.getAttributeLocalName(i-1) & '="' & reader.getAttributeValue(i-1) & '"'>
			</cfloop>
		</cfif>
		
        <!--- If we're on the first "start element" then we can assume this is the root node. --->
		<cfif countStartElements eq 1>
			<cfset rootNode = reader.getLocalName()>
			<cfset extractCharacters = false>
<pre>#RepeatString(chr(9),indentCounter)#&lt;#rootNode##attrs#&gt;</pre>
		</cfif>
		
		<cfif countStartElements gte 2>
			
			<!--- If we're on the second "start element" then we can assume this identifies a record. --->
			<cfif countStartElements eq 2>
				<cfset recordNode = reader.getLocalName()>
				<cfset extractCharacters = false>
<pre>#RepeatString(chr(9),indentCounter)#&lt;#recordNode##attrs#&gt;</pre>
			</cfif>
	        
	        <cfif countStartElements gt 2>
<pre>#RepeatString(chr(9),indentCounter)#&lt;#reader.getLocalName()##attrs#&gt;</pre>
				<cfset extractCharacters = true>
			</cfif>
		</cfif>
    </cfif>
    
    <cfif event EQ reader.CHARACTERS and extractCharacters>
<pre>#RepeatString(chr(9),indentCounter+1)##reader.getText()#</pre>
	</cfif>
    
    <cfif event EQ reader.END_ELEMENT>
		
<pre>#RepeatString(chr(9),indentCounter)#&lt;/#reader.getLocalName()#&gt;</pre>
		<cfset indentCounter-->
		<cfif reader.getLocalName() is recordNode>
			<cfset countRecords++>
			<cfif countRecords gte howManyRecords>
				<cfbreak>
			</cfif>
		</cfif>
		
	</cfif>

</cfloop>
<pre>#indentCounter#&lt;#rootNode#&gt;</pre>
</cfoutput>
<cfset reader.close()>

