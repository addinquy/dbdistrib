<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">


	<xsl:output method="text"/>
	<xsl:template match="table">
	
		<!-- Impression d'un commentaire de début -->
		<xsl:text>PRINT('-- drop [</xsl:text>
		<xsl:choose>
			<xsl:when test="@schema">
				<xsl:value-of select="@schema"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>dbo</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<!-- xsl:value-of select="@schema"/ -->
		<xsl:text>].[</xsl:text>
		<xsl:value-of select="@name"/>
		<xsl:text>]')


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[</xsl:text>
		<xsl:choose>
			<xsl:when test="@schema">
				<xsl:value-of select="@schema"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>dbo</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<!--xsl:value-of select="@schema"/-->
		<xsl:text>].[</xsl:text>
		<xsl:value-of select="@name"/>
		<xsl:text>]') AND type in (N'U'))
DROP TABLE [</xsl:text>
		<xsl:choose>
			<xsl:when test="@schema">
				<xsl:value-of select="@schema"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>dbo</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<!--xsl:value-of select="@schema"/-->
		<xsl:text>].[</xsl:text>
		<xsl:value-of select="@name"/>
		<xsl:text>]
		</xsl:text>
	</xsl:template>
</xsl:stylesheet>
