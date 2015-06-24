<?php
$module = $Params['Module'];
$tpl = eZTemplate::factory();
$ini = eZINI::instance();
$http = eZHTTPTool::instance();
$templateResult = false;

$objectId = $Params['Id'];

if ( $objectId == 'registration' )
{
    $user = eZUser::fetch( 14 );
    if ( $user === null )
        return $Module->handleError( eZError::KERNEL_NOT_FOUND, 'kernel' );

    $tpl->setVariable( 'user', $user );
    $templateResult = $tpl->fetch( 'design:social_user/mail/registrationinfo.tpl' );

//    $emailSender = $ini->variable( 'MailSettings', 'EmailSender' );
//    if ( $tpl->hasVariable( 'email_sender' ) )
//        $emailSender = $tpl->variable( 'email_sender' );
//    else if ( !$emailSender )
//        $emailSender = $ini->variable( 'MailSettings', 'AdminEmail' );
//
//    if ( $tpl->hasVariable( 'subject' ) )
//        $subject = $tpl->variable( 'subject' );
//    else
//        $subject = ezpI18n::tr( 'kernel/user/register', 'Registration info' );

//    $mail = new eZMail();
//    $mail->setSender( $emailSender );
//    $receiver = $user->attribute( 'email' );
//    $mail->setReceiver( $receiver );
//    $mail->setSubject( $subject );
//    $mail->setBody( $templateResult );
//    $mail->setContentType( 'text/html' );

    echo $templateResult;

}
else
{

    $siteUrl = eZINI::instance()->variable( 'SiteSettings', 'SiteURL' );
    $parts = explode( '/', $siteUrl );
    if ( count( $parts ) >= 2 )
    {
        $suffix = array_shift( $parts );
        $siteUrl = implode( '/', $parts );
    }
    echo rtrim( $siteUrl, '/' );

    $contentObject = eZContentObject::fetch( $objectId );
    if ( !$contentObject instanceof eZContentObject )
    {
        echo 'Oggetto non trovato';
    }
    $tpl->setVariable( 'object', $contentObject );
    $result = $tpl->fetch( 'design:notification/handler/ezsubtree/view/plain.tpl' );
    echo $result;
}

eZDisplayDebug();
eZExecution::cleanExit();

