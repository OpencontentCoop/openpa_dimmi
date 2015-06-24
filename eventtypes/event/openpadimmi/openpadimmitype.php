<?php

class OpenPADimmiType extends eZWorkflowEventType
{

    const WORKFLOW_TYPE_STRING = 'openpadimmi';

    function __construct()
    {
        $this->eZWorkflowEventType(
            self::WORKFLOW_TYPE_STRING,
            ezpI18n::tr( 'openpa/workflow/event', 'Workflow Dimmi' )
        );
    }

    /**
     * @param eZWorkflowProcess $process
     * @param eZEvent $event
     *
     * @return int
     */
    function execute( $process, $event )
    {
        $parameters = $process->attribute( 'parameter_list' );
        try
        {
            ObjectHandlerServiceControlDimmi::executeWorkflow( $parameters, $process, $event );
            return eZWorkflowType::STATUS_ACCEPTED;
        }
        catch( Exception $e )
        {
            eZDebug::writeError( $e->getMessage(), __METHOD__ );
            return eZWorkflowType::STATUS_REJECTED;
        }

    }
}

eZWorkflowEventType::registerEventType( OpenPADimmiType::WORKFLOW_TYPE_STRING, 'OpenPADimmiType' );
