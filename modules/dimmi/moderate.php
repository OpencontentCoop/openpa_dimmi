<?php
/** @var eZModule $module */
$module = $Params['Module'];
$http = eZHTTPTool::instance();
$objectId = $Params['ObjectID'];

$object = eZContentObject::fetch( $objectId );
if ( $object instanceof eZContentObject )
{
    ObjectHandlerServiceControlDimmi::setState( $object, 'moderation', 'accepted' );
}
$module->redirectTo( $http->sessionVariable( 'LastAccessesURI' ) );