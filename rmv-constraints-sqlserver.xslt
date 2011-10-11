<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">
	<xsl:output method="text" version="1.0" encoding="UTF-8" indent="yes"/>
	
	<xsl:template match="tables">
		<xsl:apply-templates select="table"/>
	</xsl:template>

	<xsl:template match="table">
	
	<!-- Impression d'un commentaire de début -->
		<xsl:text>PRINT('-- rmv-constraints [</xsl:text>
		<xsl:choose>
			<xsl:when test="@schema">
				<xsl:value-of select="@schema"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>dbo</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>].[</xsl:text>
		<xsl:value-of select="@name"/>
		<xsl:text>]')

</xsl:text>
		<xsl:apply-templates select="idx"/>
		<xsl:apply-templates select="column"/>
	</xsl:template>



	<!-- ================== -->
	<!-- Template des index -->
	<!-- ================== -->
	<xsl:template match="idx">
<xsl:text>IF EXISTS( SELECT * FROM sys.indexes i, sys.tables t, sys.schemas s
	WHERE
		i.name='</xsl:text>
		<xsl:value-of select="@name"/>
		<xsl:text>'
		AND s.name='</xsl:text>
		<xsl:choose>
			<xsl:when test="../@schema">
				<xsl:value-of select="../@schema"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>dbo</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>'
		AND t.name='</xsl:text>
		<xsl:value-of select="../@name"/>
		<xsl:text>'
		AND i.object_id=t.object_id
		AND t.schema_id=s.schema_id
	)
DROP INDEX </xsl:text>
		<xsl:value-of select="@name"/>
		<xsl:text> ON [</xsl:text>
		<xsl:choose>
			<xsl:when test="../@schema">
				<xsl:value-of select="../@schema"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>dbo</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>].[</xsl:text>
		<xsl:value-of select="../@name"/>
		<xsl:text>];
GO
		
		</xsl:text>
	</xsl:template>



	<!-- =================== -->
	<!-- Colonnes de l'index -->
	<!-- =================== -->
	<xsl:template match="column">
		<xsl:apply-templates select="fk"/>
	</xsl:template>



	<!-- ============ -->
	<!-- Foreign keys -->
	<!-- ============ -->
	<xsl:template match="fk">
		<!--xsl:if test="position() > 1"-->
			<xsl:text>


			</xsl:text>
		<!--/xsl:if-->
		<xsl:text>
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID('</xsl:text>
		<xsl:choose>
			<xsl:when test="../../@schema">
				<xsl:value-of select="../../@schema"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>dbo</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<!--xsl:value-of select="../../@schema"/-->
		<xsl:text>.</xsl:text>
		<xsl:value-of select="@name"/>
		<xsl:text>') AND parent_object_id = OBJECT_ID('</xsl:text>
		<xsl:choose>
			<xsl:when test="../../@schema">
				<xsl:value-of select="../../@schema"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>dbo</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<!--xsl:value-of select="../../@schema"/-->
		<xsl:text>.</xsl:text>
		<xsl:value-of select="../../@name"/>
		<xsl:text>'))
ALTER TABLE [</xsl:text>
		<xsl:choose>
			<xsl:when test="../../@schema">
				<xsl:value-of select="../../@schema"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>dbo</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>].[</xsl:text>
		<xsl:value-of select="../../@name"/>
		<xsl:text>] DROP CONSTRAINT </xsl:text>
		<xsl:value-of select="@name"/>
	</xsl:template>
	
</xsl:stylesheet>
