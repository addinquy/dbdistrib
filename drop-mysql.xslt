<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:fn="http://www.w3.org/2005/xpath-functions">
	<xsl:output method="text"/>
	
	<xsl:template match="tables">
		<xsl:apply-templates select="table"/>
	</xsl:template>
	
	<xsl:template match="table">
		<xsl:text>DROP TABLE IF  EXISTS </xsl:text>
		<xsl:value-of select="@name"/>
		<xsl:text> ;
		</xsl:text>
	</xsl:template>
</xsl:stylesheet>
