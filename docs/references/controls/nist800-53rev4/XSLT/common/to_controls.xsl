<?xml version="1.0" encoding="UTF-8"?>
<!--
  This stylesheet transforms the NIST 800-53 to reStructuredText in a format
  suitable for splitting into fillable files.

  This expects to have a 'valid-baseline-impact-levels' variable declared as follows:

  <xsl:variable name="valid-baseline-impact-levels" as="element()*">
    <Level>LOW</Level>
    <Level>MODERATE</Level>
    etc...
  </xsl:variable>
-->

<!--
  The saxon tool is used for the conversion:

  java -jar /usr/share/java/saxon.jar -xsl:to_controls.xsl -s:800-53-controls.xml -o:800-53-low-controls.rst
-->
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:c="http://scap.nist.gov/schema/sp800-53/2.0"
  xmlns:controls="http://scap.nist.gov/schema/sp800-53/feed/2.0"
  xmlns:xhtml="http://www.w3.org/1999/xhtml"
  xmlns:fctn="http://internal/functions"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://scap.nist.gov/schema/sp800-53/feed/2.0 http://scap.nist.gov/schema/sp800-53/feed/2.0/sp800-53-feed_2.0.xsd"
  version="2.0">

  <xsl:import href="functions.xsl"/>

  <!-- Get ALL control elements that match the 'valid-baseline-impact-levels' element values -->
  <xsl:template name="impact-matching-controls">
    <xsl:for-each select="//c:number">
      <!-- This is needed due to the scope change in a for-each loop -->
      <xsl:variable name="parent" select=".."/>

      <xsl:if test="fctn:control-is-valid($parent, $valid-baseline-impact-levels)">
        <xsl:copy-of select="$parent"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:variable name="impact-matching-controls" as="element()*">
    <xsl:call-template name="impact-matching-controls"/>
  </xsl:variable>

  <xsl:template name="todo-banner">
    <xsl:text>Control Response</xsl:text>
    <xsl:text>&#xa;</xsl:text>
    <xsl:value-of select="fctn:apply-header-style('Control Response', 2)"/>
    <xsl:text>&#xa;&#xa;</xsl:text>

    <xsl:text>.. todo:: Add control response information and remove this line when done</xsl:text>
    <xsl:text>&#xa;&#xa;</xsl:text>
  </xsl:template>

  <xsl:template name="nist-reference">
    <xsl:param name="number"/>

    <xsl:text>&#xa;&#xa;</xsl:text>
    <xsl:text>**Reference:** </xsl:text>
    <xsl:text>:ref:`NIST 800-53r4 </xsl:text>
    <xsl:value-of select="$number"/>
    <xsl:text>`</xsl:text>
    <xsl:text>&#xa;</xsl:text>
  </xsl:template>

  <xsl:template name="reflink">
    <xsl:param name="header" />

    <xsl:text>&#xa;</xsl:text>
    <xsl:text>.. _Controls </xsl:text>
    <!-- Need to make this RST safe -->
    <xsl:value-of select="replace($header, ':', '_')"/>:
    <xsl:text>&#xa;</xsl:text>
  </xsl:template>

  <!-- The main processing engine for controls -->
  <xsl:template name="control-info">
    <xsl:if test="not(c:withdrawn)">
      <xsl:variable name="family" select="fctn:downcase(ancestor-or-self::*[c:family][1]/c:family/text())"/>
      <xsl:value-of select="fctn:tear-line(replace(concat($family, '/', c:number, ' ', replace(fctn:downcase(c:title), '/', 'or'), '.rst'), '\s+', '_'))"/>

      <xsl:call-template name="reflink">
        <xsl:with-param name="header" select="c:number"/>
      </xsl:call-template>

      <xsl:variable name="header">
        <xsl:value-of select="c:number"/>
        <xsl:text> : </xsl:text>
        <xsl:value-of select="fctn:downcase(c:title)"/>
      </xsl:variable>

      <xsl:value-of select="$header"/>
      <xsl:text>&#xa;</xsl:text>

      <xsl:value-of select="fctn:apply-header-style($header, 1)"/>

      <xsl:if test="count(c:baseline-impact) != 0">
        <xsl:text>&#xa;&#xa;</xsl:text>
        <xsl:text>**Baseline-Impact:** </xsl:text>

        <xsl:for-each select="c:baseline-impact">
          <xsl:choose>
            <xsl:when test=". = 'MODERATE'">
              <xsl:text>*MODERATE*, </xsl:text>
            </xsl:when>
            <xsl:when test=". = 'HIGH'">
              <xsl:text>**HIGH**</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="."/>
              <xsl:text>, </xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </xsl:if>

      <xsl:text>&#xa;&#xa;</xsl:text>
      <xsl:value-of select="normalize-space(c:statement/c:description/text())"/>
      <xsl:text>&#xa;&#xa;</xsl:text>

      <xsl:call-template name="todo-banner"/>

      <xsl:text>.. Remove this line to prevent this file from being overwritten - !!AUTO_OVERWRITE!!</xsl:text>
      <xsl:text>&#xa;&#xa;</xsl:text>

      <xsl:call-template name="nist-reference">
        <xsl:with-param name="number" select="c:number"/>
      </xsl:call-template>

      <!-- Statements under the top-level one -->
      <xsl:apply-templates select="c:statement/descendant::c:statement"/>
    </xsl:if>
  </xsl:template>

  <!-- This should only apply to statements that are numbered -->
  <xsl:template match="c:statement[c:number]">
    <xsl:call-template name="reflink">
      <xsl:with-param name="header" select="c:number"/>
    </xsl:call-template>

    <xsl:value-of select="c:number"/>
    <xsl:text>&#xa;</xsl:text>

    <xsl:value-of select="fctn:apply-header-style(c:number, 2)"/>

    <xsl:text>&#xa;&#xa;</xsl:text>
    <xsl:value-of select="normalize-space(c:description/text())"/>
    <xsl:text>&#xa;&#xa;</xsl:text>

    <xsl:call-template name="todo-banner"/>
    <xsl:call-template name="nist-reference">
      <xsl:with-param name="number" select="c:number"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="controls:control">
    <xsl:if test="fctn:control-is-valid(., $valid-baseline-impact-levels) and not(c:withdrawn)">
      <xsl:text>&#xa;</xsl:text>
      <xsl:call-template name="control-info"/>
      <xsl:text>&#xa;</xsl:text>

        <xsl:for-each select="c:control-enhancements/c:control-enhancement">
        <xsl:if test="fctn:control-is-valid(., $valid-baseline-impact-levels)">
          <xsl:call-template name="control-info"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>

  <xsl:template match="/">
    <xsl:value-of select="fctn:tear-line('index.rst')"/>

    <!-- The global TOC -->
    <xsl:text>Security Control Mapping</xsl:text>
    <xsl:text>&#xa;</xsl:text>
    <xsl:value-of select="fctn:apply-header-style('Security Control Mapping', 1)"/>
    <xsl:text>&#xa;&#xa;</xsl:text>

    <xsl:text>.. toctree::</xsl:text>
    <xsl:text>&#xa;</xsl:text>
    <xsl:text>   :maxdepth: 2</xsl:text>
    <xsl:text>&#xa;&#xa;</xsl:text>

    <xsl:for-each select="distinct-values($impact-matching-controls//c:family/text())">
      <xsl:text>   </xsl:text>
      <xsl:value-of select="replace(fctn:downcase(.), '\s+', '_')"/>
      <xsl:text>&#xa;</xsl:text>
    </xsl:for-each>

    <!-- Individual RST files for each of the families -->
    <xsl:for-each select="distinct-values($impact-matching-controls//c:family/text())">
      <xsl:variable name="subtitle">
        <xsl:value-of select="replace(fctn:downcase(.), '\s+', '_')"/>
      </xsl:variable>

      <xsl:value-of select="fctn:tear-line(concat($subtitle, '.rst'))"/>
      <xsl:text>&#xa;</xsl:text>

      <xsl:value-of select="$subtitle"/>
      <xsl:text>&#xa;</xsl:text>
      <xsl:value-of select="fctn:apply-header-style($subtitle, 1)"/>

      <xsl:text>&#xa;&#xa;</xsl:text>
      <xsl:text>.. toctree::&#xa;</xsl:text>
      <xsl:text>   :maxdepth: 2&#xa;</xsl:text>
      <xsl:text>   :glob:&#xa;</xsl:text>
      <xsl:text>&#xa;</xsl:text>

      <xsl:text>   </xsl:text>
      <xsl:value-of select="concat(replace(fctn:downcase(.), '\s+', '_'), '/*')"/>
      <xsl:text>&#xa;</xsl:text>
    </xsl:for-each>

    <!-- Individual controls -->
    <xsl:apply-templates select="/controls:controls/controls:control"/>
  </xsl:template>
</xsl:stylesheet>
