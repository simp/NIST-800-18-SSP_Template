<?xml version="1.0" encoding="UTF-8"?>
<!--
  This stylesheet transforms the NIST 800-53 to reStructuredText in a format
  that works for reStructuredText documentation.

  It's a modified version of the transform provided by NIST.

  This expects to have a 'valid-baseline-impact-levels' variable declared as follows:

  <xsl:variable name="valid-baseline-impact-levels" as="element()*">
    <Level>LOW</Level>
    <Level>MODERATE</Level>
    etc...
  </xsl:variable>
-->

<!--
  The saxon tool is used for the conversion:

  java -jar /usr/share/java/saxon.jar -xsl:to_rst.xsl -s:800-53-controls.xml -o:800-53-low-controls.rst
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

  <xsl:template name="related-controls">
    <xsl:param name="controls"/>

    <xsl:for-each select="$impact-matching-controls/c:number">
       <xsl:variable name="control-number" select="."/>

       <xsl:for-each select="$controls">
         <xsl:variable name="to-match" select="text()"/>

          <!--
            We only want items where the node number matches the start text
            of the control number passed through
          -->
          <xsl:if test="starts-with($control-number/text(), $to-match)">
            <xsl:copy-of select="$control-number"/>
          </xsl:if>
        </xsl:for-each>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="reflink">
    <xsl:param name="header" />

    <xsl:text>&#xa;</xsl:text>
    <xsl:text>.. _NIST 800-53r4 </xsl:text>
    <!-- Need to make this RST safe -->
    <xsl:value-of select="replace($header, ':', '_')"/>:
    <xsl:text>&#xa;</xsl:text>
  </xsl:template>

  <!-- The main processing engine for controls -->
  <xsl:template name="control-info">
    <xsl:call-template name="reflink">
      <xsl:with-param name="header" select="c:number"/>
    </xsl:call-template>

    <xsl:variable name="header">
      <xsl:value-of select="c:number"/>
      <xsl:text> : </xsl:text>
      <xsl:value-of select="c:title"/>
    </xsl:variable>

    <xsl:value-of select="$header"/>
    <xsl:text>&#xa;</xsl:text>

    <xsl:value-of select="fctn:apply-header-style($header, 3)"/>

    <xsl:if test="string-length(c:priority)!=0">
      <xsl:text>&#xa;&#xa;</xsl:text>
      <xsl:text>**Priority:** </xsl:text>
      <xsl:value-of select="c:priority"/>
    </xsl:if>

    <xsl:if test="count(c:baseline-impact)!=0">
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
    <xsl:text>    </xsl:text>
    <xsl:value-of select="c:statement/c:description"/>

    <xsl:if test="string-length(c:supplemental-guidance/c:description) != 0">
      <xsl:text>&#xa;&#xa;</xsl:text>
      <xsl:text>.. NOTE::</xsl:text>
      <xsl:text>&#xa;&#xa;</xsl:text>
      <xsl:text>   </xsl:text>
      <xsl:value-of select="replace(c:supplemental-guidance/c:description, '&#xa;', '&#xa;    ')"/>
    </xsl:if>

    <xsl:variable name="related-controls" as="element()*">
      <xsl:call-template name="related-controls">
        <xsl:with-param name="controls" select="c:supplemental-guidance/c:related"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:if test="count($related-controls) != 0">
      <xsl:text>&#xa;&#xa;</xsl:text>
      <xsl:text>**Related Controls:** </xsl:text>

      <xsl:for-each select="$related-controls">
        <xsl:text>`NIST 800-53r4 </xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>`_</xsl:text>
        <xsl:if test="position() != last()">
          <xsl:text>, </xsl:text>
        </xsl:if>
      </xsl:for-each>
    </xsl:if>

    <xsl:text>&#xa;</xsl:text>

    <!-- Statements under the top-level one -->
    <xsl:apply-templates select="c:statement/descendant::c:statement"/>
  </xsl:template>

  <!-- This should only apply to statements that are numbered -->
  <xsl:template match="c:statement[c:number]">
    <xsl:call-template name="reflink">
      <xsl:with-param name="header" select="c:number"/>
    </xsl:call-template>

    <xsl:value-of select="c:number"/>
    <xsl:text>&#xa;</xsl:text>

    <xsl:value-of select="fctn:apply-header-style(c:number, 4)"/>

    <xsl:text>&#xa;&#xa;</xsl:text>
    <xsl:text>    </xsl:text>
    <xsl:value-of select="c:description"/>
    <xsl:text>&#xa;</xsl:text>
  </xsl:template>

  <xsl:template match="controls:control">

    <xsl:if test="fctn:control-is-valid(., $valid-baseline-impact-levels)">
      <!-- Controls -->
      <xsl:text>&#xa;</xsl:text>
      <xsl:variable name="header">
        <xsl:text>Control Family: </xsl:text>
        <xsl:value-of select="c:family"/>
      </xsl:variable>

      <xsl:value-of select="$header"/>
      <xsl:text>&#xa;</xsl:text>

      <xsl:value-of select="fctn:apply-header-style($header, 2)"/>

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
    <!-- Add this line to stop the left menu from expanding each control -->
    <xsl:text>:tocdepth: 2</xsl:text>
    <xsl:text>&#xa;&#xa;</xsl:text>

    <xsl:text>NIST 800-53 Rev4</xsl:text>
    <xsl:text>&#xa;</xsl:text>
    <xsl:text>================</xsl:text>
    <xsl:text>&#xa;</xsl:text>

    <xsl:apply-templates select="/controls:controls/controls:control"/>
  </xsl:template>
</xsl:stylesheet>
