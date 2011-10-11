<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">
	<xsl:output method="text" version="1.0" encoding="UTF-8" indent="yes"/>
	
	<xsl:template match="tables">
		<xsl:apply-templates select="table"/>
	</xsl:template>

	<xsl:template match="table">	
		<xsl:apply-templates select="idx"/>
		<xsl:apply-templates select="column"/>
	</xsl:template>
	
	
	
	<!-- ================== -->
	<!-- Template des index -->
	<!-- ================== -->
	<xsl:template match="idx">
<xsl:text>IF ( SELECT count(1) FROM INFORMATION_SCHEMA.STATISTICS s
	WHERE s.index_name = '</xsl:text>
		<xsl:value-of select="@name"/>
		<xsl:text>'
		AND s.table_name = '</xsl:text>
		<xsl:value-of select="../@name"/>
		<xsl:text>'
	) > 0
THEN ALTER TABLE </xsl:text>
		<xsl:value-of select="../@name"/>
<xsl:text> DROP INDEX </xsl:text>
		<xsl:value-of select="@name"/>
		<xsl:text>;
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
		<xsl:variable name="schema-name" select="normalize-space(substring-before(@target, '/'))"/>
		<xsl:variable name="rest-field" select="normalize-space(substring-after(@target, '/'))"/>
		<xsl:variable name="table-name" select="normalize-space(substring-before($rest-field, '/'))"/>
		<xsl:variable name="field-name" select="normalize-space(substring-after($rest-field, '/'))"/>
	<xsl:text>ALTER TABLE </xsl:text>
		<xsl:choose>
			<xsl:when test="../../@schema">
				<xsl:value-of select="../../@schema"/>
				<xsl:text>.</xsl:text>
			</xsl:when>
		</xsl:choose>
		<xsl:value-of select="../../@name"/>
		<xsl:text> DROP FOREIGN KEY </xsl:text>
		<xsl:value-of select="@name"/>
		<xsl:text>;
</xsl:text>
	</xsl:template>
</xsl:stylesheet>
