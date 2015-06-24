<?php
require 'autoload.php';

$script = eZScript::instance( array( 'description' => ( "OpenPA Dimmi Migration \n\n" ),
                                     'use-session' => false,
                                     'use-modules' => true,
                                     'use-extensions' => true ) );

$script->startup();

$installer = new OpenPADimmiInstaller();
$options = $installer->setScriptOptions( $script );

$script->initialize();
$script->setUseDebugAccumulators( true );

$cli = eZCLI::instance();

OpenPALog::setOutputLevel( OpenPALog::ALL );

try
{
    /** @var eZUser $user */
    $user = eZUser::fetchByName( 'admin' );
    eZUser::setCurrentlyLoggedInUser( $user , $user->attribute( 'contentobject_id' ) );

    $remoteUrl = OpenPAINI::variable( 'NetworkSettings', 'PrototypeUrl', 'http://openpa.opencontent.it/openpa/classdefinition/' );
    if ( $remoteUrl != 'http://openpa.opencontent.it/openpa/classdefinition/' && $remoteUrl != 'http://openpafusioni.opencontent.it/openpa/classdefinition/' )
    {
        throw new Exception( "class remote url non valido ($remoteUrl)" );
    }

    // cambia il nome della classe Dimmi Root in Dimmi Old Root
    if ( !eZContentClass::fetchByIdentifier( 'dimmi_root_old' ) instanceof eZContentClass )
    {
        $dimmiRootClass = eZContentClass::fetchByIdentifier( 'dimmi_root' );
        if ( !$dimmiRootClass instanceof eZContentClass )
        {
            throw new Exception( "class Dimmi Root not found" );
        }
        $dimmiRootClass->setAttribute( 'identifier', 'dimmi_root_old' );
        $dimmiRootClass->store();
    }

    // cerca Sensor Root
    $remoteId = OpenPABase::getCurrentSiteaccessIdentifier() . '_openpa_sensor';
    $root = eZContentObject::fetchByRemoteID( $remoteId );
    if ( !$root instanceof eZContentObject )
    {
        throw new Exception( "object Sensor Root not found" );
    }

    // migra Sensor Root in Dimmi Root
    OpenPAClassTools::installClasses( array( 'dimmi_root' ) );

    $mapping = array();
    foreach( $root->attribute( 'data_map' ) as $identifier => $attribute )
    {
        $mapping[$identifier] = $identifier;
    }
    unset( $mapping['forum_enabled'] );
    unset( $mapping['survey_enabled'] );
    unset( $mapping['post_enabled'] );
    $conversionFunctions = new conversionFunctions();
    $containerObject = $conversionFunctions->convertObject( $root->attribute('id'), eZContentClass::classIDByIdentifier( 'dimmi_root' ), $mapping );
    if ( !$containerObject )
    {
        throw new Exception( "Errore nella conversione del sensor root" );
    }

    // cambiaci remote in <identifier>_openpa_dimmi
    $root->setAttribute( 'remote_id', OpenPABase::getCurrentSiteaccessIdentifier() . '_openpa_dimmi' );
    $root->store();

    //cambiaci sezione
    $section = OpenPABase::initSection(
        ObjectHandlerServiceControlDimmi::SECTION_NAME,
        ObjectHandlerServiceControlDimmi::SECTION_IDENTIFIER,
        OpenPAAppSectionHelper::NAVIGATION_IDENTIFIER
    );
    if ( !$section instanceof eZSection )
    {
        throw new Exception( "Sezione non trovata" );
    }
    $root->setAttribute( 'section_id', $section->attribute( 'id' ) );
    $root->store();

    // cerca <identifier>_openpa_sensor_dimmi
    $dimmiForumRoot = eZContentObject::fetchByRemoteID( OpenPABase::getCurrentSiteaccessIdentifier() . '_openpa_sensor_dimmi' );
    if ( !$dimmiForumRoot instanceof eZContentObject )
    {
        throw new Exception( "object Dimmi Forum Root not found" );
    }

    // migralo in dimmi_forum_root
    OpenPAClassTools::installClasses( array( 'dimmi_forum_root' ) );

    $mapping = array();
    foreach( $dimmiForumRoot->attribute( 'data_map' ) as $identifier => $attribute )
    {
        $mapping[$identifier] = $identifier;
    }
    $conversionFunctions = new conversionFunctions();
    $containerObject = $conversionFunctions->convertObject( $dimmiForumRoot->attribute('id'), eZContentClass::classIDByIdentifier( 'dimmi_forum_root' ), $mapping );
    if ( !$containerObject )
    {
        throw new Exception( "Errore nella conversione del dimmi_forum_root" );
    }

    // cambiaci remote in <identifier>_openpa_dimmi_forumcontainer
    $dimmiForumRoot->setAttribute( 'remote_id', OpenPABase::getCurrentSiteaccessIdentifier() . '_openpa_dimmi_forumcontainer' );
    $dimmiForumRoot->store();

    // spostalo sotto a <identifier>_openpa_dimmi
    eZContentObjectTreeNodeOperations::move( $dimmiForumRoot->attribute( 'main_node_id' ), $root->attribute( 'main_node_id' ) );

    $installer = new OpenPADimmiInstaller();
    $installer->beforeInstall( array( 'sa_suffix' => 'partecipa' ) );
    $installer->install();
    $installer->afterInstall();



    $script->shutdown();
}
catch( Exception $e )
{
    $errCode = $e->getCode();
    $errCode = $errCode != 0 ? $errCode : 1; // If an error has occured, script must terminate with a status other than 0
    $script->shutdown( $errCode, $e->getMessage() );
}
