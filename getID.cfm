<cfquery name="qry">
	SELECT count(*)
	FROM 	toi_t_toilets
</cfquery>

<cfdump var="#qry#">

<cfif StructKeyExists(url, "truncate")>
	<cfquery name="qry">
		TRUNCATE TABLE 	toi_t_toilets
	</cfquery>
</cfif>



<cfabort>
<cfset fullURL = "http://www.toiletmap.gov.au/toilet.aspx?id=00C9AF7B-C979-4F95-8179-ADA8C3522CE2&type=toilet">

<!--- Get everything after the ? --->
<cfset queryString = ListLast(fullURL, "?")>

<!--- Now split the remainder into an array --->
<cfset arr = ListToArray(queryString, "&")>

<cfset arrFinal = []>

<!--- Loop over the array and separate the query string into a struct i.e. key/value pairs. --->
<cfloop array="#arr#" index="e">
	<cfset str = {}>
	<cfset str["name"] = trim(ListFirst(e,"="))>
	<cfset str["value"] = trim(ListLast(e,"="))>
	<cfset ArrayAppend(arrFinal, str)>
</cfloop>

<cfdump var="#arrFinal#">

