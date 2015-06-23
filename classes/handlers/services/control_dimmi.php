<?php

class ObjectHandlerServiceControlDimmi extends ObjectHandlerServiceBase implements OCPageDataHandlerInterface
{

    const SECTION_IDENTIFIER = "dimmi";
    const SECTION_NAME = "Dimmi";

    /**
     * @var eZContentObjectTreeNode
     */
    protected static $rootNode;

    /**
     * @var eZContentObjectAttribute[]
     */
    protected static $rootNodeDataMap;

    public static $moderationStateGroupIdentifier = 'moderation';
    public static $moderationStateIdentifiers = array(
        'skipped' => "Non necessita di moderazione",
        'waiting' => "In attesa di moderazione",
        'accepted' => "Accettato",
        'refused' => "Rifiutato"
    );

    /**
     * @var eZContentObjectTreeNode
     */
    protected static $forumContainerNode;
    protected static $forums;
    protected static $forumCommentClass;


    function run()
    {
        // forum
        $this->fnData['forum_container_node'] = 'forumContainerNode';
        $this->fnData['forums'] = 'forums';
        $this->fnData['privacy'] = 'getPrivacy';
        $this->fnData['faq'] = 'getFaq';
        $this->fnData['terms'] = 'getTerms';
        $this->fnData['cookie'] = 'getCookie';
        $this->fnData['current_moderation_state'] = 'getCurrentModerationState';
    }

    public function getCurrentModerationState()
    {
        if ( $this->container->getContentObject() instanceof eZContentObject )
        {
            $states = OpenPABase::initStateGroup(
                self::$moderationStateGroupIdentifier,
                self::$moderationStateIdentifiers
            );
            foreach ( $states as $state )
            {
                if ( in_array( $state->attribute( 'id' ), $this->container->getContentObject()->attribute( 'state_id_array' ) ) )
                {
                    return array(
                        'name' => $state->attribute( 'current_translation' )->attribute( 'name' ),
                        'identifier' => $state->attribute( 'identifier' ),
                        'css_class' => 'danger'
                    );
                }
            }
        }
        return array();
    }

    public static function dimmiRootRemoteId()
    {
        return OpenPABase::getCurrentSiteaccessIdentifier() . '_openpa_dimmi';
    }

    public static function isDimmiSiteAccessName( $currentSiteAccessName )
    {
        return OpenPABase::getCustomSiteaccessName( 'dimmi' ) == $currentSiteAccessName;
    }

    public static function getDimmiSiteAccessName()
    {
        return OpenPABase::getCustomSiteaccessName( 'dimmi' );
    }

    /**
     * @return eZContentObjectTreeNode|null
     */
    public static function forumContainerNode()
    {
        if ( self::$forumContainerNode == null )
        {
            $root = eZContentObject::fetchByRemoteID( self::dimmiRootRemoteId() . '_forumcontainer' );
            if ( $root instanceof eZContentObject )
            {
                self::$forumContainerNode = $root->attribute( 'main_node' );
            }
        }
        return self::$forumContainerNode;
    }

    public static  function rootNodeHasAttribute( $identifier )
    {
        $root = eZContentObject::fetchByRemoteID( self::dimmiRootRemoteId() );
        $rootHandler = OpenPAObjectHandler::instanceFromContentObject( $root );
        return $rootHandler->hasAttribute( $identifier );
    }

    public static function forumCommentClass()
    {
        if ( self::$forumCommentClass == null )
        {
            self::$forumCommentClass = eZContentClass::fetchByIdentifier( 'dimmi_forum_reply' );
        }
        return self::$forumCommentClass;
    }

    /**
     * @return eZContentObjectTreeNode|null
     */
    public static function rootNode()
    {
        if ( self::$rootNode == null )
        {
            if ( !isset( $GLOBALS['DimmiRootNode'] ) )
            {
                $root = eZContentObject::fetchByRemoteID( self::dimmiRootRemoteId() );
                if ( $root instanceof eZContentObject )
                {
                    $GLOBALS['DimmiRootNode'] = $root->attribute( 'main_node' );
                }
            }
            self::$rootNode = $GLOBALS['DimmiRootNode'];
        }
        return self::$rootNode;
    }

    public static function rootHandler()
    {
        if ( !isset( $GLOBALS['DimmiRootHandler'] ) )
        {
            $root = eZContentObject::fetchByRemoteID( self::dimmiRootRemoteId() );
            $rootHandler = OpenPAObjectHandler::instanceFromContentObject( $root );
            $GLOBALS['DimmiRootHandler'] = $rootHandler->attribute( 'control_dimmi' );
        }
        return $GLOBALS['DimmiRootHandler'];
    }

    public static function rootNodeDataMap()
    {
        if ( self::$rootNodeDataMap == null )
        {
            $node = self::rootNode();
            self::$rootNodeDataMap = $node->attribute( 'data_map' );
        }
        return self::$rootNodeDataMap;
    }

    /**
     * Ritorna l'attributo privacy di rootNode
     * @return eZContentObjectAttribute
     */
    protected function getPrivacy()
    {
        $dataMap = self::rootNodeDataMap();
        return $dataMap['privacy'];
    }

    /**
     * Ritorna l'attributo faq di rootNode
     * @return eZContentObjectAttribute
     */
    protected function getFaq()
    {
        $dataMap = self::rootNodeDataMap();
        return $dataMap['faq'];
    }

    /**
     * Ritorna l'attributo terms di rootNode
     * @return eZContentObjectAttribute
     */
    protected function getTerms()
    {
        $dataMap = self::rootNodeDataMap();
        return $dataMap['terms'];
    }

    /**
     * Ritorna l'attributo cookie di rootNode
     * @return eZContentObjectAttribute
     */
    protected function getCookie()
    {
        $dataMap = self::rootNodeDataMap();
        return $dataMap['cookie'];
    }

    public function siteTitle()
    {
        return strip_tags( $this->logoTitle() );
    }

    public function siteUrl()
    {
        $currentSiteaccess = eZSiteAccess::current();
        $sitaccessIdentifier = $currentSiteaccess['name'];
        if ( !self::isDimmiSiteAccessName( $sitaccessIdentifier ) )
        {
            $sitaccessIdentifier = self::getDimmiSiteAccessName();
        }
        $path = "settings/siteaccess/{$sitaccessIdentifier}/";
        $ini = new eZINI( 'site.ini.append', $path, null, null, null, true, true );
        return rtrim( $ini->variable( 'SiteSettings', 'SiteURL' ), '/' );
    }

    public function assetUrl()
    {
        $siteUrl = eZINI::instance()->variable( 'SiteSettings', 'SiteURL' );
        $parts = explode( '/', $siteUrl );
        if ( count( $parts ) >= 2 )
        {
            array_pop( $parts );
            $siteUrl = implode( '/', $parts );
        }
        return rtrim( $siteUrl, '/' );
    }

    public function logoPath()
    {
        $data = false;
        $root = eZContentObject::fetchByRemoteID( self::dimmiRootRemoteId() );
        $rootHandler = OpenPAObjectHandler::instanceFromContentObject( $root );
        if ( $rootHandler->hasAttribute( 'logo' ) )
        {
            $attribute = $rootHandler->attribute( 'logo' )->attribute( 'contentobject_attribute' );
            if ( $attribute instanceof eZContentObjectAttribute && $attribute->hasContent() )
            {
                /** @var eZImageAliasHandler $content */
                $content = $attribute->content();
                $original = $content->attribute( 'original' );
                $data = $original['full_path'];
            }
            else
            {
                $data = '/extension/openpa_dimmi/design/standard/images/logo_dimmi.png';
            }
        }
        return $data;
    }

    public function logoTitle()
    {
        return $this->getAttributeString( 'logo_title' );
    }

    public function logoSubtitle()
    {
        return $this->getAttributeString( 'logo_subtitle' );
    }

    public function headImages()
    {
        return array(
            "apple-touch-icon-114x114-precomposed" => null,
            "apple-touch-icon-72x72-precomposed" => null,
            "apple-touch-icon-57x57-precomposed" => null,
            "favicon" => null
        );
    }

    public function needLogin()
    {
        // TODO: Implement needLogin() method.
    }

    public function attributeContacts()
    {
        $data = '';
        $root = eZContentObject::fetchByRemoteID( self::dimmiRootRemoteId() );
        $rootHandler = OpenPAObjectHandler::instanceFromContentObject( $root );
        if ( $rootHandler->hasAttribute( 'contacts' ) )
        {
            $attribute = $rootHandler->attribute( 'contacts' )->attribute( 'contentobject_attribute' );
            if ( $attribute instanceof eZContentObjectAttribute )
            {
                $data = $attribute;
            }
        }
        return $data;
    }

    public function attributeFooter()
    {
        $data = '';
        $root = eZContentObject::fetchByRemoteID( self::dimmiRootRemoteId() );
        $rootHandler = OpenPAObjectHandler::instanceFromContentObject( $root );
        if ( $rootHandler->hasAttribute( 'footer' ) )
        {
            $attribute = $rootHandler->attribute( 'footer' )->attribute( 'contentobject_attribute' );
            if ( $attribute instanceof eZContentObjectAttribute )
            {
                $data = $attribute;
            }
        }
        return $data;
    }

    public function textCredits()
    {
        return ezpI18n::tr( 'dimmi', 'Dimmi - progetto di riuso del Consorzio dei Comuni Trentini - realizzato da Opencontent con ComunWeb' );
    }

    public function googleAnalyticsId()
    {
        return OpenPAINI::variable( 'Seo', 'GoogleAnalyticsAccountID', false );
    }

    public function cookieLawUrl()
    {
        $href = 'dimmi/info/cookie';
        eZURI::transformURI( $href, false, 'full' );
        return $href;
    }

    public function menu()
    {
        $menu = array(
            array(
                'name' => ezpI18n::tr( 'dimmi/menu', 'Informazioni' ),
                'url' => 'dimmi/info',
                'highlight' => false,
                'has_children' => true,
                'children' => array(
                    array(
                        'name' => ezpI18n::tr( 'dimmi/menu', 'Faq' ),
                        'url' => 'dimmi/info/faq',
                        'has_children' => false,
                    ),
                    array(
                        'name' => ezpI18n::tr( 'dimmi/menu', 'Privacy' ),
                        'url' => 'dimmi/info/privacy',
                        'has_children' => false,
                    ),
                    array(
                        'name' => ezpI18n::tr( 'dimmi/menu', 'Termini di utilizzo' ),
                        'url' => 'dimmi/info/terms',
                        'has_children' => false,
                    )
                )
            ),
            array(
                'name' => ezpI18n::tr( 'dimmi/menu', 'Discussioni' ),
                'url' => 'dimmi/forums',
                'highlight' => false,
                'has_children' => false
            )
        );
        if ( eZUser::currentUser()->isLoggedIn() )
        {
            $menu[] = array(
                'name' => ezpI18n::tr( 'dimmi/menu', 'Le mie attività' ),
                'url' => 'dimmi/dashboard',
                'highlight' => false,
                'has_children' => false
            );
        }
        return $menu;
    }

    public function userMenu()
    {
        $userMenu = array(
            array(
                'name' => ezpI18n::tr( 'dimmi/menu', 'Profilo' ),
                'url' => 'user/edit',
                'highlight' => false,
                'has_children' => false
            ),
            array(
                'name' => ezpI18n::tr( 'dimmi/menu', 'Notifiche' ),
                'url' => 'notification/settings',
                'highlight' => false,
                'has_children' => false
            )
        );
        if ( eZUser::currentUser()->hasAccessTo( 'dimmi', 'config' ) )
        {
            $userMenu[] = array(
                'name' => ezpI18n::tr( 'dimmi/menu', 'Settings' ),
                'url' => 'dimmi/config',
                'highlight' => false,
                'has_children' => false
            );
        }
        $userMenu[] = array(
            'name' => ezpI18n::tr( 'dimmi/menu', 'Esci' ),
            'url' => 'user/logout',
            'highlight' => false,
            'has_children' => false
        );
        return $userMenu;
    }

    public function bannerPath()
    {
        $data = false;
        $root = eZContentObject::fetchByRemoteID( self::dimmiRootRemoteId() );
        $rootHandler = OpenPAObjectHandler::instanceFromContentObject( $root );
        if ( $rootHandler->hasAttribute( 'banner' ) )
        {
            $attribute = $rootHandler->attribute( 'banner' )->attribute( 'contentobject_attribute' );
            if ( $attribute instanceof eZContentObjectAttribute && $attribute->hasContent() )
            {
                /** @var eZImageAliasHandler $content */
                $content = $attribute->content();
                $original = $content->attribute( 'original' );
                $data = $original['full_path'];
            }
        }
        return $data;
    }

    public function bannerTitle()
    {
        return $this->getAttributeString( 'banner_title' );
    }

    public function bannerSubtitle()
    {
        return $this->getAttributeString( 'banner_subtitle' );
    }

    /**
     * @param string $identifier
     *
     * @return string
     */
    private function getAttributeString( $identifier )
    {
        $data = '';
        $root = eZContentObject::fetchByRemoteID( self::dimmiRootRemoteId() );
        $rootHandler = OpenPAObjectHandler::instanceFromContentObject( $root );
        if ( $rootHandler->hasAttribute( $identifier ) )
        {
            $attribute = $rootHandler->attribute( $identifier )->attribute( 'contentobject_attribute' );
            if ( $attribute instanceof eZContentObjectAttribute )
            {
                $data = self::replaceBracket( $attribute->toString() );
            }
        }
        return $data;
    }

    /**
     * Replace [ ] with strong html tag
     * @param string $string
     * @return string
     */
    public static function replaceBracket( $string )
    {
        $string = str_replace( '[', '<strong>', $string );
        $string = str_replace( ']', '</strong>', $string );
        return $string;
    }
}
