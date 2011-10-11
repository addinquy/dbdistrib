<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">
	<xsl:output method="text"/>
	
	<xsl:param name="engine"/>
	<xsl:param name="charset"/>
	
	<xsl:template match="tables">
		<xsl:apply-templates select="table"/>
	</xsl:template>
	
	<xsl:template match="table">
		<xsl:text>DROP TABLE if EXISTS </xsl:text>
		<xsl:value-of select="@name"/>
		<xsl:text>;
CREATE TABLE </xsl:text>
		<xsl:value-of select="@name"/>
		<xsl:text> (
		</xsl:text>
		<xsl:apply-templates select="column"/>
		<xsl:text>primary key (</xsl:text>
		<xsl:apply-templates select="pk/field"/>
		<xsl:text>) </xsl:text>
		<xsl:apply-templates select="column/index"/>
		<!--xsl:text>
	) ENGINE = MYISAM;
	</xsl:text-->
		<xsl:text>
	) ENGINE = </xsl:text>
	<xsl:value-of select="$engine"/>
	<xsl:text> CHARSET=</xsl:text>
	<xsl:value-of select="$charset"/>
	<xsl:text>;</xsl:text>
	</xsl:template>
	
	
	<xsl:template match="column">
		<xsl:value-of select="normalize-space(.)"/>
		<xsl:text> </xsl:text>
		
		<!-- Traduction de types en specifique MySQL -->
		<xsl:choose>
			<xsl:when test="(type/@name = 'text') and (type/@size = 'medium')">
				<xsl:text>mediumtext</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="normalize-space(type/@name)"/>
			</xsl:otherwise>
		</xsl:choose>
		
		<!-- Cas des entiers avec une longueur -->
		<xsl:if test="((type/@name eq 'int') or (type/@name eq 'smallint')) and (type/@length ne '')">
			<xsl:text>(</xsl:text>
			<xsl:value-of select="type/@length"/>
			<xsl:text>)</xsl:text>
		</xsl:if>
		<!-- Cas des chaines de caractères -->
		<xsl:if test="(type/@name eq 'varchar') or (type/@name eq 'nvarchar') or (type/@name eq 'char') or (type/@name eq 'nchar') or (type/@name eq 'decimal')">
			<xsl:text>(</xsl:text>
			<xsl:value-of select="type/@length"/>
			<xsl:if test="(type/@name eq 'decimal') or (type/@name eq 'numeric')">
				<xsl:text>, </xsl:text>
				<xsl:value-of select="type/@decimal"/>
			</xsl:if>
			<xsl:text>)</xsl:text>
		</xsl:if>
		<xsl:if test="(type/@name eq 'tinyint')">
			<xsl:if test="(type/@signed eq 'false')">
				<xsl:text> unsigned</xsl:text>
			</xsl:if>
		</xsl:if>
		
		<!-- Cas de la contrainte NULL ou NOT NULL -->
		<xsl:if test="@null eq 'false'">
			<xsl:text> NOT NULL</xsl:text>
		</xsl:if>
		
		<!--  Gestion de l'auto-increment -->
		<xsl:if test="identity">
			<xsl:text> auto_increment</xsl:text>
		</xsl:if>
		
		<!-- Gestion du defaulting -->
		<xsl:if test="@null-default eq 'true'">
			<xsl:text> default NULL</xsl:text>
		</xsl:if>
		<xsl:if test="@default">
			<xsl:choose>
				<xsl:when test="@default eq 'NULL'">
					<xsl:text> default NULL</xsl:text>
				</xsl:when>
				<xsl:when test="(type/@name eq 'varchar') or (type/@name eq 'nvarchar') or (type/@name eq 'char') or (type/@name eq 'nchar') or (type/@name eq 'text') or (type/@name eq 'ntext')">
					<xsl:text> default '</xsl:text>
					<xsl:value-of select="@default"/>
					<xsl:text>'</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text> default </xsl:text>
					<xsl:value-of select="@default"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
		<xsl:text>,
		</xsl:text>
	</xsl:template>
	
	
	<!-- =================================================================-->
	<!--  Gestion des champs inclus dans la spécification de clé primaire -->
	<!-- =================================================================-->
	<xsl:template match="field">
		<!-- Insérer une virgule pour séparer la définition de chaque colonne -->
		<xsl:if test="position() > 1">
			<xsl:text>,
			</xsl:text>
		</xsl:if>
		<xsl:value-of select="normalize-space(.)"/>
	</xsl:template>
	
	
	<xsl:template match="index">
		<xsl:text>,
		KEY </xsl:text>
		<xsl:value-of select="normalize-space(@name)"/>
		<xsl:text>(</xsl:text>
		<xsl:value-of select="normalize-space(..)"/>
		<xsl:text>)</xsl:text>
	</xsl:template>
</xsl:stylesheet>
