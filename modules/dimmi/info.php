<?php

$Module = $Params['Module'];
$identifier = $Params['Page'];


$ini = eZINI::instance();
$viewCacheEnabled = ( $ini->variable( 'ContentSettings', 'ViewCaching' ) == 'enabled' );

if ( $viewCacheEnabled )
{
    $cacheFilePath = DimmiModuleFunctions::globalCacheFilePath( 'info-' . $identifier );
    $cacheFile = eZClusterFileHandler::instance( $cacheFilePath );
    $Result = $cacheFile->processCache( array( 'DimmiModuleFunctions', 'cacheRetrieve' ),
                                        array( 'DimmiModuleFunctions', 'infoGenerate' ),
                                        null,
                                        null,
                                        compact( 'Params' ) );
}
else
{    
    $data = DimmiModuleFunctions::infoGenerate( false, compact( 'Params' ) );
    $Result = $data['content']; 
}
return $Result;
