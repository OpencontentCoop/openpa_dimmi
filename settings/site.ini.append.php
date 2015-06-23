<?php /*

[RegionalSettings]
TranslationExtensions[]=openpa_dimmi

[TemplateSettings]
ExtensionAutoloadPath[]=openpa_dimmi

[RoleSettings]
PolicyOmitList[]=dimmi/use

[Event]
Listeners[]=content/cache@DimmiModuleFunctions::onClearObjectCache


[Cache]
CacheItems[]=dimmi

[Cache_dimmi]
name=Dimmi cache
id=dimmi
tags[]=content
path=dimmi


*/ ?>
