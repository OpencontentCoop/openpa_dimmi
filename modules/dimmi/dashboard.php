<?php

//
//SensorHelper::deleteCollaborationStuff( 16 );
//SensorHelper::deleteCollaborationStuff( 17 );
//
//$db = eZDB::instance();
//$db->begin();
//$res = $db->arrayQuery( "SELECT id FROM ezcollab_item WHERE data_int1 = 1841" );
//$db->commit();
//echo '<pre>';print_r($res);die();

/** @var eZModule $module */
$module = $Params['Module'];
$tpl = eZTemplate::factory();
$http = eZHTTPTool::instance();
$offset = !is_numeric( $Params['Offset'] ) ? 0 : $Params['Offset'];
$export = !is_string( $Params['Export'] ) ? false : strtolower( $Params['Export'] ); 

$limit = 15;

$currentUser = eZUser::currentUser();
$currentSensorUser = SocialUser::current();

$tpl->setVariable( 'current_user', $currentUser );
$tpl->setVariable( 'limit', $limit );
$viewParameters = array( 'offset' => $offset );
$tpl->setVariable( 'view_parameters', $viewParameters );

$access = $currentUser->hasAccessTo( 'sensor', 'manage' );
$tpl->setVariable( 'simplified_dashboard', $access['accessWord'] == 'no' );

if ( $currentUser->isAnonymous() )
{
    $module->redirectTo( 'dimmi/home' );
    return;
}
else
{
    $Result = array();

    $Result['persistent_variable'] = $tpl->variable( 'persistent_variable' );
    $Result['content'] = $tpl->fetch( 'design:dimmi/dashboard.tpl' );
    $Result['node_id'] = 0;
    
    $contentInfoArray = array( 'url_alias' => 'sensor/home' );
    $contentInfoArray['persistent_variable'] = false;
    if ( $tpl->variable( 'persistent_variable' ) !== false )
    {
        $contentInfoArray['persistent_variable'] = $tpl->variable( 'persistent_variable' );
    }
    $Result['content_info'] = $contentInfoArray;
    $Result['path'] = array();
}