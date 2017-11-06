<?php

$Module = $Params['Module'];
$objectId = $Params['ObjectID'];
$action = $Params['Action'];

$object = eZContentObject::fetch((int)$objectId);
if ($object instanceof eZContentObject && $object->attribute('class_identifier') == 'dimmi_forum'){
	$selectedSection = false;
	if ($action == 'show'){
		$selectedSection = eZSection::fetchByIdentifier('dimmi');
	}elseif ($action == 'hide'){
		$selectedSection = eZSection::fetchByIdentifier('restricted');
	}

	if ($selectedSection instanceof eZSection){
		$selectedSection->applyTo( $object );
		eZContentCacheManager::clearContentCacheIfNeeded( $object->attribute( 'id' ) );
		DimmiModuleFunctions::clearDimmiCache();
	}
}

$Module->redirectTo('dimmi/config/dimmi');