<?php

class DimmiModuleFunctions
{
    const GLOBAL_PREFIX = 'global-';
    
    public static function onClearObjectCache( $nodeList )
    {
        return $nodeList;
    }
    
    protected static function clearDimmiCache( $prefix )
    {
        $ini = eZINI::instance();
        if ( $ini->hasVariable( 'SiteAccessSettings', 'RelatedSiteAccessList' ) &&
             $relatedSiteAccessList = $ini->variable( 'SiteAccessSettings', 'RelatedSiteAccessList' ) )
        {
            if ( !is_array( $relatedSiteAccessList ) )
            {
                $relatedSiteAccessList = array( $relatedSiteAccessList );
            }
            $relatedSiteAccessList[] = $GLOBALS['eZCurrentAccess']['name'];
            $siteAccesses = array_unique( $relatedSiteAccessList );
        }
        else
        {
            $siteAccesses = $ini->variable( 'SiteAccessSettings', 'AvailableSiteAccessList' );
        }            
        if ( !empty( $siteAccesses ) )
        {                
            $cacheBaseDir = eZDir::path( array( eZSys::cacheDirectory(), 'dimmi' ) );
            $fileHandler = eZClusterFileHandler::instance();
            $fileHandler->fileDeleteByDirList( $siteAccesses, $cacheBaseDir, $prefix );
        }
    }
    
    public static function homeGenerate( $file, $args )
    {
        $currentUser = eZUser::currentUser();
        
        $tpl = eZTemplate::factory();        
        $tpl->setVariable( 'current_user', $currentUser );
        $tpl->setVariable( 'persistent_variable', array() );

        $Result = array();
        $Result['persistent_variable'] = $tpl->variable( 'persistent_variable' );
        $Result['content'] = $tpl->fetch( 'design:dimmi/home.tpl' );
        $Result['node_id'] = 0;
        
        $contentInfoArray = array( 'url_alias' => 'dimmi/home' );
        $contentInfoArray['persistent_variable'] = array( 'dimmi_home' => true );
        if ( $tpl->variable( 'persistent_variable' ) !== false )
        {
            $contentInfoArray['persistent_variable'] = $tpl->variable( 'persistent_variable' );
            $contentInfoArray['persistent_variable']['dimmi_home'] = true;
        }
        $Result['content_info'] = $contentInfoArray;
        $Result['path'] = array();
        $returnValue = array( 'content' => $Result,
                              'scope'   => 'dimmi' );
        return $returnValue;
    }
    
    public static function infoGenerate( $file, $args )
    {
        extract( $args );
        if ( isset( $Params ) && $Params['Module'] instanceof eZModule )
        {
            $tpl = eZTemplate::factory();
            $identifier = $Params['Page'];
            if ( ObjectHandlerServiceControlDimmi::rootNodeHasAttribute( $identifier ) )
            {
                $currentUser = eZUser::currentUser();

                $tpl->setVariable( 'current_user', $currentUser );
                $tpl->setVariable( 'persistent_variable', array() );
                $tpl->setVariable( 'identifier', $identifier );

                $Result = array();

                $Result['persistent_variable'] = $tpl->variable( 'persistent_variable' );
                $Result['content'] = $tpl->fetch( 'design:dimmi/info.tpl' );
                $Result['node_id'] = 0;

                $contentInfoArray = array( 'url_alias' => 'dimmi/info' );
                $contentInfoArray['persistent_variable'] = false;
                if ( $tpl->variable( 'persistent_variable' ) !== false )
                {
                    $contentInfoArray['persistent_variable'] = $tpl->variable(
                        'persistent_variable'
                    );
                }
                $Result['content_info'] = $contentInfoArray;
                $Result['path'] = array();

                $returnValue = array(
                    'content' => $Result,
                    'scope' => 'dimmi'
                );
            }
            else
            {
                /** @var eZModule $module */
                $module = $Params['Module'];
                $returnValue = array(
                    'content' => $module->handleError(
                        eZError::KERNEL_NOT_AVAILABLE,
                        'kernel'
                    ),
                    'store' => false
                );
            }
        }
        else
        {
            $returnValue = array(
                'content' => 'error',
                'store' => false
            );
        }
        return $returnValue;
    }    
    
    public static function cacheRetrieve( $file, $mtime, $args )
    {
        $Result = include( $file );        
        return $Result;
    }
    

    public static function globalCacheFilePath( $fileName )
    {
        $currentSiteAccess = $GLOBALS['eZCurrentAccess']['name'];
        $cacheFile = self::GLOBAL_PREFIX . $fileName . '.php';
        $cachePath = eZDir::path( array( eZSys::cacheDirectory(), 'dimmi', $currentSiteAccess, $cacheFile ) );
        return $cachePath;
    }
}