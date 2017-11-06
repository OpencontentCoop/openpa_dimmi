<?php

class DimmiOperator
{
    function operatorList()
    {
        return array(
            'dimmi_root_handler',
            'dimmi_forum_container',
            'dimmi_user_rating'
        );
    }

    function namedParameterPerOperator()
    {
        return true;
    }

    function namedParameterList()
    {
        return array();
    }

    function modify( $tpl, $operatorName, $operatorParameters, $rootNamespace, $currentNamespace, &$operatorValue, $namedParameters )
    {
        switch ( $operatorName )
        {
            case 'dimmi_root_handler':
            {
                return $operatorValue = ObjectHandlerServiceControlDimmi::rootHandler();
            } break;

            case 'dimmi_forum_container':
            {
                return $operatorValue = ObjectHandlerServiceControlDimmi::forumContainerNode();
            } break;

            case 'dimmi_user_rating':
            {
                if ($operatorValue instanceof ezsrRatingObject){

                    $cond = array( 
                        'user_id' => eZUser::currentUserID(),
                        'contentobject_id' => $operatorValue->attribute('contentobject_id'), // for table index
                        'contentobject_attribute_id' => $operatorValue->attribute('contentobject_attribute_id') 
                    );
                    $objects = eZPersistentObject::fetchObjectList( ezsrRatingDataObject::definition(), null, $cond, array('created_at' => 'desc'), array('offset' => 0, 'length' => 1) );

                    return $operatorValue = isset($objects[0]) ? $objects[0] : null;
                }
                return $operatorValue = null;
            } break;

        }
        return null;
    }
} 