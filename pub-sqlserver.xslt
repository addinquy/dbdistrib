<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">
 <xsl:output method="text"/>
 
	<xsl:template match="tables">
		<xsl:apply-templates select="table"/>
	</xsl:template>
	
	<xsl:template match="table">
	
	<!-- Ligne print -->
		<xsl:text>
PRINT ('-- create [</xsl:text>
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
		
	<!-- Protection contre écrasement de tables -->
		<xsl:text>]')
	
IF NOT EXISTS
	( SELECT t.[name], s.[name]
	 FROM sys.tables as t, sys.schemas as s
	 WHERE t.[name] = '</xsl:text>
	 	<xsl:value-of select="@name"/>
	 	<xsl:text>'
	 and t.schema_id = s.schema_id
	 and s.name = '</xsl:text>
		 <xsl:choose>
				<xsl:when test="@schema">
					<xsl:value-of select="@schema"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>dbo</xsl:text>
				</xsl:otherwise>
		</xsl:choose>
	 	
	 	<!-- Déclaration de création de la table -->
	 	<xsl:text>'
	)
	CREATE TABLE [</xsl:text>
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
		<xsl:text>](
		</xsl:text>
		<xsl:apply-templates select="column" mode="others"/>
		
		<!-- Gestion de la clé primaire -->
		<xsl:if test="pk">
			<xsl:text>,
			CONSTRAINT [</xsl:text>
			<xsl:value-of select="pk/@name"/>
			<xsl:text>] PRIMARY KEY CLUSTERED
	(
			</xsl:text>
			<xsl:apply-templates select="pk/field"/>
			<xsl:text>
	) WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]</xsl:text>
		</xsl:if>
		<xsl:text>
		) ON [PRIMARY]</xsl:text>
		
		<!-- Spécification de stockage pour les mémos -->
		<xsl:if test="count(column/type[@name = 'text']) gt 0">
			<xsl:text> TEXTIMAGE_ON [PRIMARY]</xsl:text>
		</xsl:if>
		<xsl:text>
	
	/*------------------- End of table definition ---------------------*/
	
		</xsl:text>
	</xsl:template>
	

	<!-- ====================-->
	<!--  Traitement des colonnes -->
	<!-- ====================-->
	<xsl:template match="column" mode="others">
		<!-- Insérer une virgule pour séparer la définition de chaque colonne -->
		<xsl:if test="position() > 1">
			<xsl:text>,
			</xsl:text>
		</xsl:if>
		
		<!-- Type de la colonne -->
		<xsl:text>[</xsl:text>
		<xsl:value-of select="normalize-space(.)"/>
		<xsl:text>] [</xsl:text>
		<xsl:choose>
			<xsl:when test="type/@name = 'boolean'">
				<xsl:text>bit</xsl:text>
			</xsl:when>
			<xsl:when test="type/@name = 'double'">
				<xsl:text>float</xsl:text>
			</xsl:when>
			<xsl:when test="type/@name = 'date'">
				<xsl:text>datetime</xsl:text>
			</xsl:when>
			<xsl:when test="type/@name = 'smallint'">
				<xsl:text>smallint</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="normalize-space(type/@name)"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>]</xsl:text>
		
		<!-- Information de taille associée au type de la colonne-->
		<xsl:if test="(type/@name eq 'varchar') or (type/@name eq 'nvarchar') or (type/@name eq 'char') or (type/@name eq 'nchar')
				or (type/@name eq 'decimal')">
			<xsl:text>(</xsl:text>
			<xsl:value-of select="type/@length"/>
			<xsl:if test="type/@name eq 'decimal'">
				<xsl:text>, </xsl:text>
				<xsl:value-of select="type/@decimal"/>
			</xsl:if>
			<xsl:text>)</xsl:text>
		</xsl:if>
		<xsl:if test="(type/@name eq 'varchar') or (type/@name eq 'nvarchar') or (type/@name eq 'char') or (type/@name eq 'nchar')
				or (type/@name eq 'text') or (type/@name eq 'ntext') ">
			<xsl:text> COLLATE French_CI_AS</xsl:text>
		</xsl:if>
		
		<!-- Cas de l'auto-incrément -->
		<xsl:if test="identity">
			 <xsl:text> IDENTITY (</xsl:text>
			 <xsl:value-of select="normalize-space(identity/@start)"/>
			 <xsl:text>, </xsl:text>
			 <xsl:value-of select="normalize-space(identity/@step)"/>
			 <xsl:text>)</xsl:text>
		</xsl:if>
		
		<!-- Cas de la contrainte NULL ou NOT NULL -->
		<xsl:choose>
			<xsl:when test="@null eq 'false'">
				<xsl:text> NOT NULL</xsl:text>
			</xsl:when>
			<xsl:when test="@null eq 'true'">
				<xsl:text> NULL</xsl:text>
			</xsl:when>
		</xsl:choose>
		
		<!-- Gestion du defaulting -->
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
	</xsl:template>
	

	<!-- ===================================================-->
	<!--  Gestion des champs inclus dans la spécification de clé primaire -->
	<!-- ===================================================-->
	<xsl:template match="field">
		<!-- Insérer une virgule pour séparer la définition de chaque colonne -->
		<xsl:if test="position() > 1">
			<xsl:text>,
			</xsl:text>
		</xsl:if>
		<xsl:text>[</xsl:text>
		<xsl:value-of select="normalize-space(.)"/>
		<xsl:text>] </xsl:text>
		<xsl:value-of select="normalize-space(@order)"/>
	</xsl:template>
</xsl:stylesheet>

