<?php

$Module = $Params['Module'];
$Offset = $Params['Offset'] ? $Params['Offset'] : 0;
$Part = $Params['Part'] ? $Params['Part'] : 'users';
$tpl = eZTemplate::factory();
$viewParameters = array( 'offset' => $Offset, 'query' => null );
$currentUser = eZUser::currentUser();

$root = ObjectHandlerServiceControlDimmi::rootNode();

if ($Http->hasVariable('s')) {
    $viewParameters['query'] = $Http->variable('s');
}

if ( $Part == 'users' )
{
    $usersParentNode = eZContentObjectTreeNode::fetch( intval( eZINI::instance()->variable( "UserSettings", "DefaultUserPlacement" ) ) );
    $tpl->setVariable( 'user_parent_node', $usersParentNode );
}

$data = array();
$otherFolders = eZContentObjectTreeNode::subTreeByNodeID( array( 'ClassFilterType' => 'include', 'ClassFilterArray' => array( 'folder' ), 'Depth' => 1, 'DepthOperator' => 'eq', ), $root->attribute( 'node_id' ) );
foreach( $otherFolders as $folder )
{
    $data[] = $folder;
}


$forums = ObjectHandlerServiceControlDimmi::forums();
$tpl->setVariable( 'forums', $forums['tree'] );


$tpl->setVariable( 'view_parameters', $viewParameters );
$tpl->setVariable( 'current_part', $Part );
$tpl->setVariable( 'data', $data );
$tpl->setVariable( 'root', $root );
$tpl->setVariable( 'current_user', $currentUser );
$tpl->setVariable( 'persistent_variable', array() );

$Result = array();
$Result['persistent_variable'] = $tpl->variable( 'persistent_variable' );
$Result['content'] = $tpl->fetch( 'design:dimmi/config.tpl' );
$Result['node_id'] = 0;

$contentInfoArray = array( 'url_alias' => 'dimmi/config' );
$contentInfoArray['persistent_variable'] = false;
if ( $tpl->variable( 'persistent_variable' ) !== false )
{
    $contentInfoArray['persistent_variable'] = $tpl->variable( 'persistent_variable' );
}
$Result['content_info'] = $contentInfoArray;
$Result['path'] = array();
