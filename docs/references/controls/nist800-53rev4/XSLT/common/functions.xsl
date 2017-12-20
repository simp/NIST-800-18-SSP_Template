<?xml version="1.0" encoding="UTF-8"?>
<!--
     Common custom functions
-->
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:c="http://scap.nist.gov/schema/sp800-53/2.0"
  xmlns:fctn="http://internal/functions"
  version="2.0">

  <!-- Repeat a character a given number of times -->
  <!-- Pulled from https://stackoverflow.com/questions/5089096/how-to-show-a-character-n-times-in-xslt -->
  <xsl:template name="repeat">
    <xsl:param name="output" />
    <xsl:param name="count" />

    <xsl:if test="$count &gt; 0">
      <xsl:value-of select="$output" />
      <xsl:call-template name="repeat">
        <xsl:with-param name="output" select="$output" />
        <xsl:with-param name="count" select="$count - 1" />
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!--
       Determine if a control has a baseline-impact that is included in valid-impact-levels
  -->
  <xsl:function name="fctn:control-is-valid">
    <xsl:param name="control"/>
    <xsl:param name="valid-impact-levels"/>

    <!-- Find the closest baseline-impact up the node ancestry -->
    <xsl:variable name="baseline-impact" select="$control/ancestor-or-self::*[c:baseline-impact][1]/c:baseline-impact"/>

    <xsl:choose>
      <!-- If there is no impact listed, then go ahead and include it -->
      <xsl:when test="count($baseline-impact) = 0">
        <xsl:value-of select="true()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:for-each select="$valid-impact-levels">
          <xsl:variable name="impact-level" select="text()"/>

          <xsl:for-each select="$baseline-impact">
            <xsl:if test="text() = $impact-level">
              <xsl:value-of select="true()"/>
            </xsl:if>
          </xsl:for-each>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!--
      Return an appropriate length header line for reStructuredText
  -->
  <xsl:function name="fctn:apply-header-style">
    <xsl:param name="header"/>
    <xsl:param name="level"/>

    <xsl:variable name="header_char">
      <xsl:choose>
        <xsl:when test="$level = 1">
          <xsl:value-of>=</xsl:value-of>
        </xsl:when>
        <xsl:when test="$level = 2">
          <xsl:value-of>-</xsl:value-of>
        </xsl:when>
        <xsl:when test="$level = 3">
          <xsl:value-of>^</xsl:value-of>
        </xsl:when>
        <xsl:when test="$level = 4">
          <xsl:value-of>"</xsl:value-of>
        </xsl:when>
        <xsl:when test="$level = 5">
          <xsl:value-of>'</xsl:value-of>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of>+</xsl:value-of>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:call-template name="repeat">
      <xsl:with-param name="output" select="$header_char"/>
      <xsl:with-param name="count" select="string-length($header)"/>
    </xsl:call-template>
  </xsl:function>

  <!--
      A program processable tear line
  -->
  <xsl:function name="fctn:tear-line">
    <xsl:param name="content"/>

    <xsl:variable name="pre">
      <xsl:value-of>&#xa;.. ++++++++++++++++++++TEAR| </xsl:value-of>
    </xsl:variable>
    <xsl:variable name="post">
      <xsl:value-of> |TEAR++++++++++++++++++++&#xa;</xsl:value-of>
    </xsl:variable>

    <xsl:value-of select="concat($pre, $content, $post)"/>
  </xsl:function>

  <!--
      Convert a string to noun capital case on all individual words
  -->
  <xsl:function name="fctn:downcase">
    <xsl:param name="input"/>

    <xsl:variable name="output">
      <xsl:for-each select="tokenize($input, '\s+')">
          <xsl:value-of select="concat(substring(., 1, 1), lower-case(substring(., 2)))"/>
          <xsl:if test="not(position() eq last())">
            <xsl:text> </xsl:text>
          </xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <xsl:value-of select="$output"/>
  </xsl:function>
</xsl:stylesheet>
