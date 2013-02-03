Barry-the-xmlRipper
===================

Jack's lesser know brother, Barry, rips through XML files. This is a tool to read (or rip) large XML files in ColdFusion. Well, to be honest I have only tried it on one XML file that was 23MB - I tried to use the built in XML parsing functions of ColdFusion but since it tried to load the whole file into memory it wasn't as efficient as I'd have liked.

Anyway I used Barry (or Bazza) to rip through the XML. It is based off SAX. I wrote a couple of extra helpers that analysed the data to determine data types and lengths so that I could create CREATE script. Another helper that created a series of INSERT statements. I'll try get them added soon. Regardless, all of this using Barry.

It is currently quite rough. 