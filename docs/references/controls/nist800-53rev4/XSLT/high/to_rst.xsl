<?xml version="1.0" encoding="UTF-8"?>
<!--
  Select all LOW controls from the NIST 800-53 and output in reStructuredText
  format with rich links

  The saxon tool is used for the conversion:

  java -jar /usr/share/java/saxon.jar -xsl:low_rst.xsl -s:800-53-controls.xml -o:800-53-low-controls.rst
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

  <xsl:import href="../common/to_rst.xsl"/>

  <xsl:output method="text" omit-xml-declaration="yes" />

  <xsl:variable name="valid-baseline-impact-levels" as="element()*">
    <Level>LOW</Level>
    <Level>MODERATE</Level>
    <Level>HIGH</Level>
  </xsl:variable>
</xsl:stylesheet>
