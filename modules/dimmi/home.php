<?php

$module = $Params['Module'];

$tpl = eZTemplate::factory();        
$currentUser = eZUser::currentUser();

$ini = eZINI::instance();
$viewCacheEnabled = ( $ini->variable( 'ContentSettings', 'ViewCaching' ) == 'enabled' );

if ( $viewCacheEnabled )
{

    $cacheFilePath = DimmiModuleFunctions::globalCacheFilePath( $currentUser->isAnonymous() ? 'home-anon' : 'home' );
    $cacheFile = eZClusterFileHandler::instance( $cacheFilePath );
    $Result = $cacheFile->processCache( array( 'DimmiModuleFunctions', 'cacheRetrieve' ),
                                        array( 'DimmiModuleFunctions', 'homeGenerate' ),
                                        null,
                                        null,
                                        compact( 'Params' ) );
}
else
{    
    $data = DimmiModuleFunctions::homeGenerate( false, compact( 'Params' ) );
    $Result = $data['content']; 
}

return $Result;
