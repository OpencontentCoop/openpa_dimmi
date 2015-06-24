<?php

class OpenPADimmiInstaller implements OpenPAInstaller
{
    protected $options = array();

    protected $steps = array(
        'a' => '[a] alberatura',
        'r' => '[r] ruoli',
        'c' => '[c] configurazioni ini',
        'd' => '[d] demo content'
    );

    protected $installOnlyStep;

    public function setScriptOptions( eZScript $script )
    {
        return $script->getOptions(
            '[parent-node:][step:][sa_suffix:][clean]',
            '',
            array(
                'parent-node' => 'Nodo id contenitore di Dimmi (Applicazioni di default)',
                'step' => 'Esegue solo lo step selezionato: gli step possibili sono' . implode( ', ', $this->steps ),
                'sa_suffix' => 'Suffisso del siteaccess (default: dimmi)',
                'clean' => 'Elimina tutti i contenuti presenti di Dimmi prima di eseguire l\'installazione'
            )
        );
    }

    public function beforeInstall( $options = array() )
    {        
        eZContentClass::removeTemporary();
        $this->options = $options;

        if ( !isset( $this->options['sa_suffix'] ) )
        {
            $this->options['sa_suffix'] = 'dimmi';
        }

        if ( isset( $this->options['step'] ) )
        {
            if ( array_key_exists( $this->options['step'], $this->steps ) )
                $this->installOnlyStep = $this->options['step'];
            else
                throw new Exception( "Step {$this->options['step']} not found, run script with -h for help" );

            if ( isset( $this->options['clean'] ) )
            {
                throw new Exception( "Can not activate 'clean' with 'step' option" );
            }
        }

        if ( isset( $this->options['clean'] ) )
        {
            self::cleanup();
        }
    }

    protected static function cleanup()
    {
        OpenPALog::warning( "Cleanup data" );
        $rootNode = ObjectHandlerServiceControlDimmi::rootNode();
        if ( $rootNode instanceof eZContentObjectTreeNode )
        {
            eZContentObjectTreeNode::removeNode( $rootNode->attribute( 'node_id' ) );
        }
        unset( $GLOBALS['DimmiRootNode'] );
    }


    public function install()
    {
        OpenPALog::warning( "Controllo stati" );
        $states = self::installStates();
        
        OpenPALog::warning( "Controllo sezioni" );
        $section = self::installSections();

        OpenPALog::warning( "Controllo classi" );
        self::installClasses();

        OpenPALog::warning( "Installazione Dimmi root" );
        if ( isset( $this->options['parent-node'] ) )
            $parentNodeId = $this->options['parent-node'];
        else
            $parentNodeId = OpenPAAppSectionHelper::instance()->rootNode()->attribute( 'node_id' );
        $root = self::installAppRoot( $parentNodeId, $section );

        if ( $this->installOnlyStep !== null )
        {
            OpenPALog::warning( "Install step " . $this->steps[$this->installOnlyStep] );
        }

        if ( ( $this->installOnlyStep !== null && ( $this->installOnlyStep == 'a' || $this->installOnlyStep == 'd' ) ) || $this->installOnlyStep === null )
        {
            OpenPALog::warning( "Installazione alberatura Dimmi" );
            self::installDimmiStuff( $root, $section, $this->installOnlyStep == 'd' );
        }

        if ( ( $this->installOnlyStep !== null && $this->installOnlyStep == 'r' ) || $this->installOnlyStep === null )
        {
            OpenPALog::warning( "Installazione ruoli" );
            self::installRoles( $section, $states );
        }

        if ( ( $this->installOnlyStep !== null && $this->installOnlyStep == 'c' ) || $this->installOnlyStep === null )
        {
            OpenPALog::warning( 'Salvo configurazioni' );
            self::installIniParams( $this->options['sa_suffix'] );
        }

        eZCache::clearById( 'global_ini' );
        eZCache::clearById( 'template' );

        OpenPALog::error( "@todo Impostare i workflow di PreRead" );
    }

    public function afterInstall()
    {
        return false;
    }

    protected static function installStates()
    {
        $moderationStates = OpenPABase::initStateGroup(
            ObjectHandlerServiceControlDimmi::$moderationStateGroupIdentifier,
            ObjectHandlerServiceControlDimmi::$moderationStateIdentifiers
        );
        return $moderationStates;
    }

    protected static function installSections()
    {
        $section = OpenPABase::initSection(
            ObjectHandlerServiceControlDimmi::SECTION_NAME,
            ObjectHandlerServiceControlDimmi::SECTION_IDENTIFIER,
            OpenPAAppSectionHelper::NAVIGATION_IDENTIFIER
        );
        return $section;
    }

    public static function dimmiClassIdentifiers()
    {
        return array(
            "dimmi_category",
            "dimmi_forum_reply",
            "dimmi_forum",
            "dimmi_forum_root",
            "dimmi_root",
            "dimmi_forum_topic"
        );
    }
    
    protected static function installClasses()
    {
        OpenPAClassTools::installClasses( OpenPADimmiInstaller::dimmiClassIdentifiers() );
    }

    protected static function installAppRoot( $parentNodeId, eZSection $section, $options = array() )
    {
        $rootObject = eZContentObject::fetchByRemoteID( ObjectHandlerServiceControlDimmi::dimmiRootRemoteId() );
        if ( !$rootObject instanceof eZContentObject )
        {
            // root
            $params = array(
                'parent_node_id' => $parentNodeId,
                'section_id' => $section->attribute( 'id' ),
                'remote_id' => ObjectHandlerServiceControlDimmi::dimmiRootRemoteId(),
                'class_identifier' => 'dimmi_root',
                'attributes' => array(
                    'name' => 'DimmiCittà',
                    'logo' => 'extension/openpa_dimmi/doc/default/logo.png',
                    'logo_title' => 'Dimmi[Città]',
                    'logo_subtitle' => 'Confronto tra [cittadini] ed il Comune',
                    'banner' => 'extension/openpa_dimmi/doc/default/banner.png',
                    'banner_title' => "Spazio istituzionale per il confronto con i cittadini e l'Amministrazione",
                    'banner_subtitle' => "L'ambiente adatto per discutere tra cittadini",
                    'faq' => SQLIContentUtils::getRichContent( "<p>Attraverso la<b>&nbsp;piattaforma Dimmi</b>&nbsp;i/le cittadini/e possono formulare suggerimenti e problematiche rivolte a migliorare la vivibilità della tua Città.</p>" ),
                    'privacy' => SQLIContentUtils::getRichContent( "Da compilare" ),
                    'terms' => SQLIContentUtils::getRichContent( "Da compilare" ),
                    'footer' => SQLIContentUtils::getRichContent( "Da compilare" ),
                    'contacts' => SQLIContentUtils::getRichContent( "Da compilare" ),
                    'forum_enabled' => isset( $options['forum'] ),
                    'survey_enabled' => isset( $options['survey'] ),
                    'post_enabled' => isset( $options['post'] )
                )
            );
            /** @var eZContentObject $rootObject */
            $rootObject = eZContentFunctions::createAndPublishObject( $params );
            if( !$rootObject instanceof eZContentObject )
            {
                throw new Exception( 'Failed creating Dimmi root node' );
            }
        }
        return $rootObject;
    }

    protected static function installDimmiStuff( eZContentObject $rootObject, eZSection $section, $installDemoContent = true )
    {
        $containerObject = eZContentObject::fetchByRemoteID( ObjectHandlerServiceControlDimmi::dimmiRootRemoteId() . '_forumcontainer' );
        if ( !$containerObject instanceof eZContentObject )
        {
            // Post container
            OpenPALog::warning( "Install Dimmi container" );
            $params = array(
                'parent_node_id' => $rootObject->attribute( 'main_node_id' ),
                'section_id' => $section->attribute( 'id' ),
                'remote_id' => ObjectHandlerServiceControlDimmi::dimmiRootRemoteId() . '_forumcontainer',
                'class_identifier' => 'dimmi_forum_root',
                'attributes' => array(
                    'title' => 'Quali sono le principali sfide che il tuo Comune sta affrontando?',
                    'subtitle' => 'Discutine qui con i tuoi concittadini',
                    'description' => SQLIContentUtils::getRichContent( "<p>Questo media civico istituzionale è aperto alla consultazione, confronto e partecipazione dei cittadini.</p><p>Per partecipare, basta effettuare una rapida registrazione.</p>" ),
                    'image' => 'extension/openpa_dimmi/doc/default/dimmi_root.jpg'

                )
            );
            /** @var eZContentObject $containerObject */
            $containerObject = eZContentFunctions::createAndPublishObject( $params );
            if( !$containerObject instanceof eZContentObject )
            {
                throw new Exception( 'Failed creating Dimmi container' );
            }
        }

        if ( $containerObject->attribute( 'main_node' )->attribute( 'children_count' ) > 0 )
        {
            $installDemoContent = false;
        }

        if ( $installDemoContent )
        {
            // Forum sample
            OpenPALog::warning( "Install Forum demo " );
            $params = array(
                'parent_node_id' => $containerObject->attribute( 'main_node_id' ),
                'section_id' => $section->attribute( 'id' ),
                'class_identifier' => 'dimmi_forum',
                'attributes' => array(
                    'title' => 'Demo'
                )
            );
            /** @var eZContentObject $categoryObject */
            $forumObject = eZContentFunctions::createAndPublishObject( $params );
            if ( !$forumObject instanceof eZContentObject )
            {
                throw new Exception( 'Failed creating Dimmi forum demo' );
            }

            for ( $i = 1; $i <= 2; $i++ )
            {
                // Topic sample
                OpenPALog::warning( "Install Topic demo " );
                $params = array(
                    'parent_node_id' => $forumObject->attribute( 'main_node_id' ),
                    'section_id' => $section->attribute( 'id' ),
                    'class_identifier' => 'dimmi_forum_topic',
                    'attributes' => array(
                        'subject' => 'Demo'
                    )
                );
                /** @var eZContentObject $categoryObject */
                $topicObject = eZContentFunctions::createAndPublishObject( $params );
                if ( !$topicObject instanceof eZContentObject )
                {
                    throw new Exception( 'Failed creating Dimmi topic demo' );
                }
            }
        }
    }

    protected static function installRoles( eZSection $section, array $states )
    {
        $roles = array(

            "Dimmi Admin" => array(
                array(
                    'ModuleName' => 'apps',
                    'FunctionName' => '*'
                ),
                array(
                    'ModuleName' => 'openpa',
                    'FunctionName' => '*'
                ),

                array(
                    'ModuleName' => 'dimmi',
                    'FunctionName' => '*'
                ),
                array(
                    'ModuleName' => 'user',
                    'FunctionName' => 'login',
                    'Limitation' => array(
                        'SiteAccess' => eZSys::ezcrc32( OpenPABase::getCustomSiteaccessName( 'dimmi', false ) )
                    )
                ),
                array(
                    'ModuleName' => 'websitetoolbar',
                    'FunctionName' => '*'
                ),
                array(
                    'ModuleName' => 'content',
                    'FunctionName' => 'edit',
                    'Limitation' => array( 'Section' => $section->attribute( 'id' ) )
                ),
                array(
                    'ModuleName' => 'content',
                    'FunctionName' => 'read',
                    'Limitation' => array( 'Section' => $section->attribute( 'id' ) )
                ),
                array(
                    'ModuleName' => 'content',
                    'FunctionName' => 'remove',
                    'Limitation' => array(
                        'Class' => array(
                            eZContentClass::classIDByIdentifier( 'dimmi_forum' ),
                            eZContentClass::classIDByIdentifier( 'dimmi_forum_topic' ),
                            eZContentClass::classIDByIdentifier( 'dimmi_forum_reply' )
                        ),
                        'Section' => $section->attribute( 'id' )
                    )
                )
            ),

            "Dimmi Participant" => array(
                array(
                    'ModuleName' => 'content',
                    'FunctionName' => 'create',
                    'Limitation' => array(
                        'Class' => eZContentClass::classIDByIdentifier( 'dimmi_forum_reply' ),
                        'ParentClass' => array(
                            eZContentClass::classIDByIdentifier( 'dimmi_forum_topic' ),
                            eZContentClass::classIDByIdentifier( 'dimmi_forum_reply' )
                        ),
                        'Section' => $section->attribute( 'id' )
                    )
                ),
                array(
                    'ModuleName' => 'content',
                    'FunctionName' => 'read',
                    'Limitation' => array(
                        'Class' => array(
                            eZContentClass::classIDByIdentifier( 'dimmi_forum_reply' )
                        ),
                        'Owner' => 1,
                        'Section' => $section->attribute( 'id' )
                    )
                ),
                array(
                    'ModuleName' => 'notification',
                    'FunctionName' => '*'
                ),
                array(
                    'ModuleName' => 'dimmi',
                    'FunctionName' => 'manage'
                ),
                array(
                    'ModuleName' => 'user',
                    'FunctionName' => 'login',
                    'Limitation' => array(
                        'SiteAccess' => eZSys::ezcrc32( OpenPABase::getCustomSiteaccessName( 'dimmi', false ) )
                    )
                ),
            ),

            "Dimmi Anonymous" => array(
                array(
                    'ModuleName' => 'content',
                    'FunctionName' => 'read',
                    'Limitation' => array(
                        'Class' => eZContentClass::classIDByIdentifier( 'dimmi_forum_reply' ),
                        'Section' => $section->attribute( 'id' ),
                        'StateGroup_moderation' => array(
                            $states['moderation.skipped']->attribute( 'id' ),
                            $states['moderation.accepted']->attribute( 'id' )
                        )
                    )
                ),
                array(
                    'ModuleName' => 'content',
                    'FunctionName' => 'read',
                    'Limitation' => array(
                        'Class' => array(
                            eZContentClass::classIDByIdentifier( 'dimmi_category' ),
                            eZContentClass::classIDByIdentifier( 'dimmi_forum_topic' ),
                            eZContentClass::classIDByIdentifier( 'dimmi_forum' ),
                            eZContentClass::classIDByIdentifier( 'dimmi_root' )
                        ),
                        'Section' => $section->attribute( 'id' )
                    )
                ),
                array(
                    'ModuleName' => 'dimmi',
                    'FunctionName' => 'use'
                ),
                array(
                    'ModuleName' => 'user',
                    'FunctionName' => 'login',
                    'Limitation' => array(
                        'SiteAccess' => eZSys::ezcrc32( OpenPABase::getCustomSiteaccessName( 'dimmi', false ) )
                    )
                ),
            )
        );

        foreach( $roles as $roleName => $policies )
        {
            OpenPABase::initRole( $roleName, $policies, true );
        }

        $anonymousUserId = eZINI::instance()->variable( 'UserSettings', 'AnonymousUserID' );
        /** @var eZRole $anonymousRole */
        $anonymousRole = eZRole::fetchByName( "Dimmi Anonymous" );
        if ( !$anonymousRole instanceof eZRole )
        {
            throw new Exception( "Error: problem with roles" );
        }
        $anonymousRole->assignToUser( $anonymousUserId );

        /** @var eZRole $reporterRole */
        $reporterRole = eZRole::fetchByName( "Dimmi Participant" );
        if ( !$reporterRole instanceof eZRole )
        {
            throw new Exception( "Error: problem with roles" );
        }
        $memberNodeId = eZINI::instance()->variable( 'UserSettings', 'DefaultUserPlacement' );
        $members = eZContentObject::fetchByNodeID( $memberNodeId );
        if ( $members instanceof eZContentObject )
        {
            $anonymousRole->assignToUser( $members->attribute( 'id' ) );
            $reporterRole->assignToUser( $members->attribute( 'id' ) );
        }
    }

    protected static function installIniParams( $saSuffix )
    {
        $dimmi = OpenPABase::getCustomSiteaccessName( 'dimmi', false );
        $dimmiPath = "settings/siteaccess/{$dimmi}/";

        // impostatzioni in backend
        $backend = OpenPABase::getBackendSiteaccessName();
        $backendPath = "settings/siteaccess/{$backend}/";
        $iniFile = "contentstructuremenu.ini";
        $ini = new eZINI( $iniFile . '.append', $backendPath, null, null, null, true, true );
        $value = array_unique( array_merge( (array) $ini->variable( 'TreeMenu', 'ShowClasses' ), array( 'dimmi_root', 'dimmi_forum_root' ) ) );
        $ini->setVariable( 'TreeMenu', 'ShowClasses', $value );
        if ( !$ini->save() ) throw new Exception( "Non riesco a salvare {$backendPath}{$iniFile}" );

        $iniFile = "site.ini";
        $ini = new eZINI( $iniFile . '.append', $backendPath, null, null, null, true, true );
        $value = array_unique(
            array_merge(
                (array) $ini->variable( 'ExtensionSettings', 'ActiveAccessExtensions' ),
                array(
                    'ocoperatorscollection',
                    'ocsocialuser',
                    'ocsocialdesign',
                    'openpa_dimmi'
                )
            )
        );
        $ini->setVariable( 'ExtensionSettings', 'ActiveAccessExtensions', $value );
        $value = array_unique( array_merge( (array) $ini->variable( 'SiteAccessSettings', 'RelatedSiteAccessList' ), array( $dimmi ) ) );
        $ini->setVariable( 'SiteAccessSettings', 'RelatedSiteAccessList', $value );
        if ( !$ini->save() ) throw new Exception( "Non riesco a salvare {$backendPath}{$iniFile}" );

        // impostatzioni in dimmi
        eZDir::mkdir( $dimmiPath );

        $frontend = OpenPABase::getFrontendSiteaccessName();
        $frontendPath = "settings/siteaccess/{$frontend}/";
        $frontendSiteUrl = eZINI::instance()->variable( 'SiteSettings', 'SiteURL' );
        $parts = explode( '/', $frontendSiteUrl ); //bugfix
        $frontendSiteUrl = $parts[0];

        eZFileHandler::copy( $frontendPath . 'site.ini.append.php', $dimmiPath . 'site.ini.append.php' );
        $iniFile = "site.ini";
        $ini = new eZINI( $iniFile . '.append', $dimmiPath, null, null, null, true, true );
        $ini->setVariable(
            'ExtensionSettings',
            'ActiveAccessExtensions',
            array(
                '',
                'openpa_theme_2014',
                'ocbootstrap',
                'ocoperatorscollection',
                'ocsocialuser',
                'ocsocialdesign',
                'openpa_dimmi'
            )
        );
        $ini->setVariable( 'SiteSettings', 'SiteURL', $frontendSiteUrl . '/' . $saSuffix );
        $ini->setVariable( 'SiteSettings', 'DefaultPage', 'dimmi/home' );
        $ini->setVariable( 'SiteSettings', 'IndexPage', 'dimmi/home' );
        $ini->setVariable( 'SiteSettings', 'LoginPage', 'embedded' );
        $ini->setVariable( 'DesignSettings', 'SiteDesign', 'dimmi' );
        $ini->setVariable( 'DesignSettings', 'AdditionalSiteDesignList', array( '', 'social', 'ocbootstrap', 'standard' ) );
        if ( !$ini->save() ) throw new Exception( "Non riesco a salvare {$dimmiPath}{$iniFile}" );

        $iniFile = "ezcomments.ini";
        $ini = new eZINI( $iniFile . '.append', $dimmiPath, null, null, null, true, true );
        $ini->setVariable( 'RecaptchaSetting', 'PublicKey', '6Lee6v4SAAAAAKaBcnKYaMiD' );
        $ini->setVariable( 'RecaptchaSetting', 'PrivateKey', '6Lee6v4SAAAAAD39ImIzsTrIOkyPy2La13T7aZzf' );
        $ini->setVariable( 'RecaptchaSetting', 'Theme', 'custom' );
        $ini->setVariable( 'RecaptchaSetting', 'Language', 'en' );
        $ini->setVariable( 'RecaptchaSetting', 'TabIndex', '0' );
        if ( !$ini->save() ) throw new Exception( "Non riesco a salvare {$dimmiPath}{$iniFile}" );

        OpenPALog::error( "@todo Aggiungere siteaccess in override/site.ini:
[SiteSettings]
SiteList[]={$dimmi}
[SiteAccessSettings]
AvailableSiteAccessList[]={$dimmi}
HostUriMatchMapItems[]={$frontendSiteUrl};{$saSuffix};{$dimmi} \n" );
    }
}
