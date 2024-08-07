<?xml version='1.0' encoding='UTF-8'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:db="http://docbook.org/ns/docbook"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:p="http://www.w3.org/ns/xproc" 
                exclude-result-prefixes="#all"
                version="3.0">

<xsl:import href="xprocns2.xsl"/>

<xsl:strip-space elements="p:*"/>

<!--
<p:declare-step type="p:identity">
  <p:input port="source" sequence="yes"/>   
  <p:output port="result" sequence="yes"/>   
</p:declare-step>
-->

<xsl:template match="p:declare-step" priority="100">
  <div class="declare-step">
    <p>Summary</p>
    <xsl:apply-templates select="." mode="alternate-xprocns"/>
    <details>
      <summary>Declaration</summary>
      <xsl:next-match/>
    </details>
  </div>
</xsl:template>

<xsl:template match="p:declare-step">
  <p>
    <xsl:choose>
      <xsl:when test="ancestor::db:section[@xml:id='std-required']">
	<xsl:attribute name="class" select="'element-syntax element-syntax-declare-step-rqd'"/>
      </xsl:when>
      <xsl:when test="ancestor::db:section[@xml:id='std-optional']">
	<xsl:attribute name="class" select="'element-syntax element-syntax-declare-step-opt'"/>
      </xsl:when>
      <xsl:when test="ancestor::db:section[@role='ext-optional']">
	<xsl:attribute name="class" select="'element-syntax element-syntax-declare-step-opt'"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:attribute name="class" select="'element-syntax element-syntax-declare-step'"/>
      </xsl:otherwise>
    </xsl:choose>

    <span class="decl">
      <code>&lt;p:<xsl:value-of select="local-name(.)"/></code>
      <xsl:for-each select="@*">
	<xsl:call-template name="doAttr"/>
      </xsl:for-each>
      <code>&gt;</code>
    </span>
    <xsl:apply-templates mode="xprocelem"/>
    <br/>
    <code>&lt;/p:<xsl:value-of select="local-name(.)"/>&gt;</code>
  </p>
</xsl:template>

<xsl:template name="doAttr">
 <xsl:text> </xsl:text>
 <code class="attr {local-name(.)}-attr">
  <xsl:value-of select="name(.)"/>
 </code>
 <code>="</code>
 <xsl:if test=". != ''">
   <code class="value {local-name(.)}-value">
     <xsl:value-of select="."/>
   </code>
 </xsl:if>
 <code>"</code>
</xsl:template>

<xsl:template match="*" mode="xprocelem">
  <br/>
  <xsl:text>&#160;&#160;&#160;&#160;&#160;</xsl:text>
  <span>
    <xsl:attribute name="class">
      <xsl:choose>
	<xsl:when test="self::p:option and @required='true'">opt-req</xsl:when>
	<xsl:when test="self::p:option">opt-opt</xsl:when>
	<xsl:when test="self::p:with-option">with-option</xsl:when>
	<xsl:when test="self::p:input">input</xsl:when>
	<xsl:when test="self::p:output">input</xsl:when>
	<xsl:otherwise>
	  <xsl:message>
	    <xsl:text>Unexpected element </xsl:text>
	    <xsl:value-of select="name(.)"/>
	  </xsl:message>
	  <xsl:text>p-elem</xsl:text>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>

    <code>&lt;p:<xsl:value-of select="local-name(.)"/></code>

    <xsl:for-each select="@name|@port">
      <xsl:call-template name="doAttr"/>
    </xsl:for-each>

    <xsl:for-each select="@*[not(name()='name' or name()='port' or namespace-uri()='http://www.w3.org/1999/XSL/Spec/ElementSyntax')]">
      <xsl:call-template name="doAttr"/>
    </xsl:for-each>

    <xsl:choose>
      <xsl:when test="self::p:input and p:*">
        <xsl:if test="count(p:*) gt 1 or not(p:empty)">
          <xsl:message terminate="yes">Only p:empty is supported as a default!</xsl:message>
        </xsl:if>
        <code>&gt;</code>
        <br/>
        <xsl:text>&#160;&#160;&#160;&#160;&#160;</xsl:text>
        <xsl:text>&#160;&#160;&#160;&#160;&#160;</xsl:text>
        <code>&lt;p:empty/&gt;</code>
        <br/>
        <xsl:text>&#160;&#160;&#160;&#160;&#160;</xsl:text>
        <code>&lt;/p:input&gt;</code>
      </xsl:when>
      <xsl:otherwise>
        <code>/&gt;</code>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:if test="self::p:option">
      <xsl:variable name="lengths" as="xs:integer+">
	<xsl:for-each select="@*[not(namespace-uri()='http://www.w3.org/1999/XSL/Spec/ElementSyntax')]">
	  <xsl:if test="position()&gt;1">
	    <xsl:sequence select="1"/>
	  </xsl:if>
	  <xsl:value-of select="string-length(name(.))+1"/>
	  <xsl:value-of select="string-length(.)+2"/>
	</xsl:for-each>
      </xsl:variable>

      <code>
	<xsl:call-template name="cpad">
	  <xsl:with-param name="len" select="sum($lengths)"/>
	</xsl:call-template>
      </code>

      <xsl:variable name="type" as="xs:string*">
	<xsl:choose xmlns:e="http://www.w3.org/1999/XSL/Spec/ElementSyntax">
          <xsl:when test="@values">
	    <xsl:value-of select="'string'"/>
          </xsl:when>
	  <xsl:when test="not(@as) and not(@e:type)">
	    <xsl:message>Warning: no e:type!!!</xsl:message>
            <xsl:message><xsl:sequence select="."/></xsl:message>
	    <xsl:value-of select="'item()*'"/>
	  </xsl:when>
          <xsl:when test="not(@e:type)"/>
	  <xsl:otherwise>
	    <xsl:value-of select="replace(@e:type,'xsd:','')"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:variable>

      <xsl:variable name="typestr" as="xs:string">
	<xsl:value-of select="$type" separator=" "/>
      </xsl:variable>

      <xsl:if test="exists($type)">
        <code class="comment">&lt;!--&#160;</code>
        <span class="opt-type">
	  <xsl:value-of select="$typestr"/>
        </span>
        <code class="comment">&#160;--&gt;</code>
      </xsl:if>
    </xsl:if>
  </span>
</xsl:template>

<xsl:template name="cpad">
  <xsl:param name="len"/>
  <xsl:if test="$len &lt; 50">
    <xsl:text>&#160;</xsl:text>
    <xsl:call-template name="cpad">
      <xsl:with-param name="len" select="$len + 1"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>

</xsl:stylesheet>
