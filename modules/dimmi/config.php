<?php

$Module = $Params['Module'];
$Offset = $Params['Offset'] ? $Params['Offset'] : 0;
$Part = $Params['Part'] ? $Params['Part'] : 'users';
$tpl = eZTemplate::factory();
$viewParameters = array( 'offset' => $Offset );
$currentUser = eZUser::currentUser();

$root = ObjectHandlerServiceControlSensor::rootNode();

if ( $Part == 'areas' )
{
    $areas = ObjectHandlerServiceControlSensor::getPostAreas();
    $tpl->setVariable( 'areas', $areas['tree'] );
}

elseif ( $Part == 'users' )
{
    $usersParentNode = eZContentObjectTreeNode::fetch( intval( eZINI::instance()->variable( "UserSettings", "DefaultUserPlacement" ) ) );
    $tpl->setVariable( 'user_parent_node', $usersParentNode );
}

elseif ( $Part == 'categories' )
{
    $categories = ObjectHandlerServiceControlSensor::getPostCategories();
    $tpl->setVariable( 'categories', $categories['tree'] );
}

elseif ( $Part == 'operators' )
{
    $operators = ObjectHandlerServiceControlSensor::getOperators();
    $tpl->setVariable( 'operators', $operators );
}

$data = array();
$otherFolders = eZContentObjectTreeNode::subTreeByNodeID( array( 'ClassFilterType' => 'include', 'ClassFilterArray' => array( 'folder' ), 'Depth' => 1, 'DepthOperator' => 'eq', ), $root->attribute( 'node_id' ) );
foreach( $otherFolders as $folder )
{
    if (
        $folder->attribute( 'contentobject_id' ) != ObjectHandlerServiceControlSensor::postCategoriesNode()->attribute( 'contentobject_id' )
        && $folder->attribute( 'contentobject_id' ) != ObjectHandlerServiceControlSensor::postContainerNode()->attribute( 'contentobject_id' )
        && $folder->attribute( 'contentobject_id' ) != ObjectHandlerServiceControlSensor::surveyContainerNode()->attribute( 'contentobject_id' )
    )
    {
        $data[] = $folder;
    }
}

if ( ObjectHandlerServiceControlSensor::ForumIsEnable() && $Part == 'dimmi' )
{
    $forums = ObjectHandlerServiceControlSensor::forums();
    $tpl->setVariable( 'forums', $forums['tree'] );
}

if ( ObjectHandlerServiceControlSensor::SurveyIsEnabled() && $Part == 'survey' )
{

}

$tpl->setVariable( 'view_parameters', $viewParameters );
$tpl->setVariable( 'current_part', $Part );
$tpl->setVariable( 'data', $data );
$tpl->setVariable( 'root', $root );
$tpl->setVariable( 'current_user', $currentUser );
$tpl->setVariable( 'persistent_variable', array() );

$Result = array();
$Result['persistent_variable'] = $tpl->variable( 'persistent_variable' );
$Result['pagelayout'] = 'design:sensor/pagelayout.tpl';
$Result['content'] = $tpl->fetch( 'design:sensor/config.tpl' );
$Result['node_id'] = 0;

$contentInfoArray = array( 'url_alias' => 'sensor/config' );
$contentInfoArray['persistent_variable'] = false;
if ( $tpl->variable( 'persistent_variable' ) !== false )
{
    $contentInfoArray['persistent_variable'] = $tpl->variable( 'persistent_variable' );
}
$Result['content_info'] = $contentInfoArray;
$Result['path'] = array();