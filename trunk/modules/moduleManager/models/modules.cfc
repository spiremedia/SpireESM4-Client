<cfcomponent name="Users Model" output="false" extends="resources.abstractmodel">

	<cffunction name="init">
		<cfargument name="requestObj" required="true">
		<cfset variables.requestObj = arguments.requestObj>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="getModuleMdl">
		<cfargument name="r">
		
		<cfreturn createObject("component","modules.modulemanager.models.module").init(r)>
	</cffunction>
	
	<cffunction name="getDownloadAbleModuleInfo">
		<cfargument name="mdl" required="true">
		<cfset var l = structnew()>
		<cfhttp method="get" url="http://esm3installer.spiremedia.com/index.cfm?view=getModuleInfo&module=#mdl#" result="l.result">
		<cfreturn deserializejson(l.result.filecontent)>
	</cffunction>
	
	<cffunction name="installModule">
		<cfargument name="info">
		<cfset var l = structnew()>
		<cfset var m = createObject("component","modules.modulemanager.models.moduleinstaller").init(variables.requestObj)>

		<cfreturn m.install(info)>
	</cffunction>
	<!--- <cffunction name="getModuleXML">
		<cfargument name="module">
		<cfset var modulexml = "">
		<cfinclude template="../../#module#/modulexml.cfm">
		
		<cfreturn modulexml>
	</cffunction> --->
	
	<cffunction name="getAll" output="false">
		<cfset var modules= "">
		<cfset var q = querynew("path,name,hasmodelsdir,hastemplatesdir,hasunittestfiles")>
		<cfset var modulemdl = getModuleMdl(requestObj)>
		
		<cfdirectory action="list" name="modules" directory="#requestObj.getVar("machineroot")#/modules" sort="asc">
		
		<cfloop query="modules">
			<cfif modules.type EQ "dir">
				<cfif isanesmmodule(modules.name)>
					<cfset queryaddrow(q)>
					<cfset querysetcell(q, "path", path )>
					<cfset querysetcell(q, "name", modules.name )>
					
					<cfset modulemdl.setFolderName(modules.name)>
					
					<cfset querysetcell(q, "hasmodelsdir", modulemdl.hasmodelsdirectory() )>
					<cfset querysetcell(q, "hastemplatesdir", modulemdl.hastemplatesdirectory() )>
					<cfset querysetcell(q, "hasunittestfiles", modulemdl.hasunittestfiles() )>
				</cfif>
			</cfif>
		</cfloop>
		
		<cfreturn q>
	</cffunction>
	
	<!--- <cffunction name="getNextModuleOrderNo" output="false">
		<cfset var modules= getAll()>
		<cfset var modulexml = "">
		<cfset var count = 0>
		
		<cfloop query="modules">
			<cfset modulexml = getModuleXml(modules.name)>
			<cfif modulexml.module.xmlattributes.menuorder GTE count>
				<cfset count = modulexml.module.xmlattributes.menuorder + 1>
			</cfif>
		</cfloop>
		
		<cfreturn count>
	</cffunction> --->
	
	<!--- <cffunction name="modelAlreadyExists">
		<cfreturn 0>
	</cffunction> --->
	
	<cffunction name="templatePatternExists">
		<cfargument name="filename">
		<cfreturn fileexists(requestObj.getVar("machineroot") & "/modules/modulemanager/patterns/" & replace(filename,".cfm","template.cfm") & ".txt")>
	</cffunction>
		
	<cffunction name="getTemplatePatterns">
		<cfset var l = structnew()>
		<cfdirectory action="list" name="l.list" directory="#requestObj.getVar("machineroot") & "/modules/modulemanager/patterns/"#" filter="*template.cfm.txt" sort="desc">
		<cfset l.a = arraynew(1)>
		<cfloop query="l.list">
			<cfset arrayappend(l.a, replace(name, ".cfm.txt","","all"))>
		</cfloop>
		<cfset queryaddcolumn(l.list,"filename", l.a)>
		<cfreturn l.list>
	</cffunction>
	
	<cffunction name="isanesmmodule">
		<cfargument name="name">
		<cfif fileexists(requestObj.getVar("machineroot") & "/modules/" & name & "/controller.cfc")>
			<cfreturn true>
		</cfif>
		<cfreturn false>
	</cffunction>
	
	<cffunction name="fixModuleName" output="false">
		<cfargument name="name">
		<cfset var l = structnew()>
		<cfset name = listtoarray(lcase(name)," ")>
		
		<cfif arraylen(name) GTE 2>
			<cfloop from="2" to="#arraylen(name)#" index="l.idx">
				<cfset name[l.idx] = ucase(left(name[l.idx], 1)) & right(name[l.idx], len(name[l.idx])-1)>
			</cfloop>
		</cfif>
		<cfreturn arraytolist(name,"")/>
	</cffunction>
	
	<!--- <cffunction name="makeModuleSkeleton" output="false">
		<cfargument name="foldername" required="true">
		
		<cfset var l = structnew()>
		
		<cfif isanesmmodule(folderName)>
			<cfthrow message="Unsafe action. Already exists">
		</cfif>
		
		<cfdirectory  action="create" directory="#requestObj.getVar("machineroot") & "modules/" & foldername#" mode="644">

		<cfset l.replaceable = structnew()>
		<cfset l.replaceable.name = modulename>
		
		<cfset makeFile("controller.cfc", "controller.cfc", foldername, l.replaceable)>
		<cfset makeFile("modulexml.cfm", "configxml.cfm", foldername, l.replaceable)>
	</cffunction> --->
	
</cfcomponent>