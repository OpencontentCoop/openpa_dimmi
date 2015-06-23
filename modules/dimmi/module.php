<?php
$Module = array( 'name' => 'Dimmi' );

$ViewList = array();
$ViewList['home'] = array(
	'script' =>	'home.php',
	'functions' => array( 'use' )
);

$ViewList['info'] = array(
    'script' =>	'info.php',
    'params' => array( 'Page' ),
    'functions' => array( 'use' )
);

$ViewList['forums'] = array(
    'script' =>	'forums.php',
    'params' => array( 'ID', 'Offset' ),
    'unordered_params' => array( "offset" => "Offset" ),
    'functions' => array( 'use' )
);

$ViewList['dashboard'] = array(
    'script' =>	'dashboard.php',
    'params' => array( "Part", "Group", "Export" ),
    'unordered_params' => array(
        "list" => "List",
        "offset" => "Offset" ),
    'functions' => array( 'use' )
);

$ViewList['comment'] = array(
    'script' =>	'comment.php',
    'params' => array( 'ForumID', 'ForumReplyID' ),
    'functions' => array( 'use' )
);

$FunctionList = array();
$FunctionList['use'] = array();
$FunctionList['manage'] = array();

