<?xml version='1.0' encoding='UTF-8'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:e="http://www.w3.org/1999/XSL/Spec/ElementSyntax"
                xmlns:db="http://docbook.org/ns/docbook"
                xmlns:m="http://docbook.org/xslt/ns/mode"
                xmlns:p="http://www.w3.org/ns/xproc" 
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="#all"
                default-mode="alternate-xprocns"
                expand-text="yes"
                version="3.0">

<xsl:strip-space elements="p:*"/>

<xsl:template match="p:declare-step">
  <xsl:if test="p:input">
    <xsl:variable name="columns" as="xs:integer"
                  select="4
                          + (if (p:input/@select or p:output/@select) then 1 else 0)
                          + (if (p:input/* or p:output/*) then 1 else 0)"/>
    <table class="tableaux">
      <thead>
        <tr>
          <th class="port">Input port</th>
          <th class="check">Primary</th>
          <th class="check">Sequence</th>
          <th>Content types</th>
          <xsl:if test="p:input/@select or p:output/@select">
            <th>Default selection</th>
          </xsl:if>
          <xsl:if test="p:input/* or p:output/*">
            <th class="binding">Default binding</th>
          </xsl:if>
        </tr>
      </thead>
      <tbody>
        <xsl:apply-templates select="p:input"/>
      </tbody>
    </table>
  </xsl:if>

  <xsl:if test="p:output">
    <xsl:variable name="columns" as="xs:integer"
                  select="4
                          + (if (p:input/@select or p:output/@select) then 1 else 0)
                          + (if (p:input/* or p:output/*) then 1 else 0)"/>
    <table class="tableaux">
      <thead>
        <tr>
          <th class="port">Output port</th>
          <th class="check">Primary</th>
          <th class="check">Sequence</th>
          <th>Content types</th>
          <xsl:if test="p:input/@select or p:output/@select">
            <th>Default selection</th>
          </xsl:if>
          <xsl:if test="p:input/* or p:output/*">
            <th class="binding">Default binding</th>
          </xsl:if>
        </tr>
      </thead>
      <tbody>
        <xsl:apply-templates select="p:output"/>
      </tbody>
    </table>
  </xsl:if>

  <xsl:if test="p:option">
    <xsl:variable name="columns" as="xs:integer"
                  select="2
                          + (if (p:option/@values) then 1 else 0)
                          + (if (p:option/@static) then 1 else 0)
                          + (if (p:option/@required) then 1 else 0)"/>
    <table class="tableaux">
      <thead>
        <tr>
          <th>Option name</th>
          <th>Type</th>
          <xsl:if test="p:option/@values">
            <th>Values</th>
          </xsl:if>
          <xsl:if test="exists(p:option[not(@required)])">
            <th>Default value</th>
          </xsl:if>
          <xsl:if test="p:option/@static">
            <th>Static</th>
          </xsl:if>
          <xsl:if test="p:option/@required">
            <th>Required</th>
          </xsl:if>
        </tr>
      </thead>
      <tbody>
        <xsl:apply-templates select="p:option[@required='true']">
          <xsl:sort select="@name"/>
        </xsl:apply-templates>
        <xsl:apply-templates select="p:option[not(@required='true')]">
          <xsl:sort select="@name"/>
        </xsl:apply-templates>
      </tbody>
    </table>
  </xsl:if>

  <xsl:if test="..//db:error">
    <details>
      <summary>Errors</summary>
      <table class="tableaux">
        <thead>
          <tr>
            <th>Error code</th>
            <th>Description</th>
          </tr>
        </thead>
        <tbody>
          <xsl:for-each-group select="..//db:error" group-by="@code">
            <xsl:sort select="@code"/>
            <tr>
              <td class="errcode">
                <a>
                  <xsl:attribute name="href">
                    <xsl:text>#</xsl:text>
                    <xsl:apply-templates select="current-group()[1]"
                                         mode="m:inline-error-anchor"/>
                  </xsl:attribute>
                  <xsl:text>err:{current-group()[1]/@code/string()}</xsl:text>
                </a>
              </td>
              <td class="description"><xsl:apply-templates select="current-group()[1]"/></td>
            </tr>
          </xsl:for-each-group>
        </tbody>
      </table>
    </details>
  </xsl:if>

  <xsl:if test="..//db:impl">
    <details>
      <summary>Implementation details</summary>
      <table class="tableaux">
        <thead>
          <tr>
            <th>Implementation</th>
            <th>Description</th>
          </tr>
        </thead>
        <tbody>
          <xsl:for-each select="..//db:impl">
            <tr>
              <td>
                <a href="#impl-{count(preceding::db:impl)+1}">
                  <xsl:choose>
                    <xsl:when test="db:glossterm[. = 'implementation-defined']">Defined</xsl:when>
                    <xsl:when test="db:glossterm[. = 'implementation-dependent']">Dependent</xsl:when>
                    <xsl:otherwise>
                      <xsl:message>Bad markup in {serialize(.)}.</xsl:message>
                      <xsl:text>Defined</xsl:text>
                    </xsl:otherwise>
                  </xsl:choose>
                </a>
              </td>
              <td class="description"><xsl:apply-templates select="."/></td>
            </tr>
          </xsl:for-each>
        </tbody>
      </table>
    </details>
  </xsl:if>
</xsl:template>

<xsl:template match="p:input|p:output">
  <xsl:if test="exists(@* except (@port|@primary|@sequence|@select|@content-types))">
    <xsl:message terminate="yes" select="'Unexpected attributes:', @* ! node-name(.)"/>
  </xsl:if>

  <xsl:variable name="primary"
                select="@primary = 'true'
                        or (self::p:input and count(../p:input) = 1 and not(@primary='false'))
                        or (self::p:output and count(../p:output) = 1 and not(@primary='false'))"/>

  <tr>
    <td>
      <xsl:variable name="port" select="string(@port)"/>
      <xsl:if test="$primary">
        <xsl:attribute name="class" select="'primary'"/>
      </xsl:if>

      <xsl:choose>
        <xsl:when test="../../db:variablelist/db:varlistentry/db:term/db:port[. = $port]">
          <a href="#{ancestor::db:section[1]/@xml:id}-def-{$port}">{$port}</a>
        </xsl:when>
        <xsl:when test="../following::db:port[. = $port]">
          <xsl:variable name="first" select="(../following::db:port[. = $port])[1]"/>
          <a href="#port.inline.{$port}-{count($first/preceding::db:port[. = $port])+1}">{$port}</a>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>{$port}</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </td>
    <td class="check">
      <xsl:if test="$primary">✔</xsl:if>
      <xsl:text> </xsl:text>
    </td>
    <td class="check">
      <xsl:if test="@sequence='true'">✔</xsl:if>
      <xsl:text> </xsl:text>
    </td>
    <td>
      <xsl:text>{@content-types/string()}</xsl:text>
      <xsl:text> </xsl:text>
    </td>
    <xsl:if test="../p:input/@select or ../p:output/@select">
      <td>
        <xsl:text>{@select/string()}</xsl:text>
        <xsl:text> </xsl:text>
      </td>
    </xsl:if>
    <xsl:if test="../p:input/* or ../p:output/*">
      <td>
        <xsl:if test="not(empty(*))">
          <xsl:if test="exists(* except p:empty)">
            <xsl:message terminate="yes"
                         select="'Unexpected default binding:', * ! node-name(.)"/>
          </xsl:if>
          <xsl:text>p:empty</xsl:text>
        </xsl:if>
      </td>
    </xsl:if>
  </tr>
</xsl:template>

<xsl:template match="p:option">
  <xsl:if test="exists(@* except (@name|@as|@values|@select|@required|@static|@e:type))">
    <xsl:message terminate="yes" select="'Unexpected attributes:', @* ! node-name(.)"/>
  </xsl:if>

  <tr>
    <td>
      <xsl:variable name="name" select="string(@name)"/>
      <xsl:if test="@required='true'">
        <xsl:attribute name="class" select="'required'"/>
      </xsl:if>

      <xsl:choose>
        <xsl:when test="../../db:variablelist/db:varlistentry/db:term/db:option[. = $name]">
          <a href="#{ancestor::db:section[1]/@xml:id}-def-{$name}">{$name}</a>
        </xsl:when>
        <xsl:when test="../following::db:option[. = $name]">
          <xsl:variable name="first" select="(../following::db:option[. = $name])[1]"/>
          <a href="#opt.inline.{$name}-{count($first/preceding::db:option[. = $name])+1}">{$name}</a>
        </xsl:when>
        <xsl:otherwise>{$name}</xsl:otherwise>
      </xsl:choose>
    </td>
    <td>{(@e:type/string(), @as/string(), "xs:string")[1]}</td>
    <xsl:if test="../p:option/@values">
      <td>
        <xsl:text>{@values/string()}</xsl:text>
        <xsl:text> </xsl:text>
      </td>
    </xsl:if>

    <xsl:if test="exists(../p:option[not(@required)])">
      <td>
        <xsl:choose>
          <xsl:when test="@required"> </xsl:when>
          <xsl:when test="@select">
            <xsl:text>{@select/string()}</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>()</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </td>
    </xsl:if>

    <xsl:if test="../p:option/@static">
      <td>
        <xsl:if test="@static='true'">✔</xsl:if>
        <xsl:text> </xsl:text>
      </td>
    </xsl:if>
    <xsl:if test="../p:option/@required">
      <td>
        <xsl:if test="@required='true'">✔</xsl:if>
        <xsl:text> </xsl:text>
      </td>
    </xsl:if>
  </tr>
</xsl:template>
        


</xsl:stylesheet>
