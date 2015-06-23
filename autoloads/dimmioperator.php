<?php

class DimmiOperator
{
    function operatorList()
    {
        return array(
            'dimmi_root_handler',
            'dimmi_forum_container'
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

        }
        return null;
    }
} 