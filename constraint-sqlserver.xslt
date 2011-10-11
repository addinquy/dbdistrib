<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">
	<xsl:output method="text" version="1.0" encoding="UTF-8" indent="yes"/>
	
	<xsl:template match="tables">
		<xsl:apply-templates select="table"/>
	</xsl:template>
	<xsl:template match="table">
	
	<!-- Impression d'un commentaire de début -->
		<xsl:text>PRINT('-- constraints [</xsl:text>
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
		<!--xsl:value-of select="../@schema"/-->
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
		<!--xsl:value-of select="../@schema"/-->
		<xsl:text>].[</xsl:text>
		<xsl:value-of select="../@name"/>
		<xsl:text>];
		
CREATE UNIQUE INDEX </xsl:text>
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
		<!--xsl:value-of select="../@schema"/-->
		<xsl:text>].[</xsl:text>
		<xsl:value-of select="../@name"/>
		<xsl:text>]
		(
			</xsl:text>
		<xsl:apply-templates select="field"/>
		<xsl:text>
		) ON [PRIMARY];

		</xsl:text>
	</xsl:template>
	
	
	
	<!-- ================ -->
	<!-- Champs des index -->
	<!-- ================ -->
	<xsl:template match="field">
		<xsl:if test="position() > 1">
			<xsl:text>,
			</xsl:text>
		</xsl:if>
		<xsl:text>[</xsl:text>
		<xsl:value-of select="normalize-space(.)"/>
		<xsl:text>] </xsl:text>
		<xsl:value-of select="@order"/>
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
		<!--xsl:variable name="field-name" select="normalize-space(substring-before(@target, '/'))"/-->
		<xsl:variable name="schema-name" select="normalize-space(substring-before(@target, '/'))"/>
		<xsl:variable name="rest-field" select="normalize-space(substring-after(@target, '/'))"/>
		<xsl:variable name="table-name" select="normalize-space(substring-before($rest-field, '/'))"/>
		<xsl:variable name="field-name" select="normalize-space(substring-after($rest-field, '/'))"/>
		<!--xsl:if test="position() > 1">
			<xsl:text>
GO


			</xsl:text>
		</xsl:if-->
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
		<!--xsl:value-of select="../../@schema"/-->
		<xsl:text>].[</xsl:text>
		<xsl:value-of select="../../@name"/>
		<xsl:text>] DROP CONSTRAINT </xsl:text>
		<xsl:value-of select="@name"/>
		<xsl:text>

ALTER TABLE [</xsl:text>
		<xsl:choose>
			<xsl:when test="../../@schema">
				<xsl:value-of select="../../@schema"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>dbo</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<!--xsl:value-of select="../../@schema"/-->
		<xsl:text>].[</xsl:text>
		<xsl:value-of select="../../@name"/>
		<xsl:text>] WITH CHECK ADD CONSTRAINT </xsl:text>
		<xsl:value-of select="@name"/>
		<xsl:text> FOREIGN KEY (</xsl:text>
		<xsl:value-of select="../normalize-space(.)"/>
		<xsl:text>)
REFERENCES [</xsl:text>
		<!--xsl:choose>
			<xsl:when test="@target-schema">
				<xsl:value-of select="@target-schema"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>dbo</xsl:text>
			</xsl:otherwise>
		</xsl:choose-->
		<xsl:value-of select="$schema-name"/>
		<xsl:text>].[</xsl:text>
		<xsl:value-of select="$table-name"/>
		<xsl:text>] (</xsl:text>
		<!-- xsl:value-of select="@target-field"/-->
		<xsl:value-of select="$field-name"/>
		<xsl:text>)
ALTER TABLE [</xsl:text>
		<xsl:choose>
			<xsl:when test="../../@schema">
				<xsl:value-of select="../../@schema"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>dbo</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<!--xsl:value-of select="../../@schema"/-->
		<xsl:text>].[</xsl:text>
		<xsl:value-of select="../../@name"/>
		<xsl:text>] CHECK CONSTRAINT </xsl:text>
		<xsl:value-of select="@name"/>
	</xsl:template>
</xsl:stylesheet>
