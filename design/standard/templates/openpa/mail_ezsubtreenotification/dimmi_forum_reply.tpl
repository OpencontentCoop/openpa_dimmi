{def $post = object_handler($object.main_node).control_dimmi}
{if $post.current_moderation_state.identifier|ne('waiting')}

{def $pagedata = social_pagedata('dimmi')}
{def $siteurl = $pagedata.site_url
     $sitename = $pagedata.logo_title|strip_tags()}
{def $is_update=false()}
{foreach $object.versions as $item}{if and($item.status|eq(3),$item.version|ne($object.current_version))}{set $is_update=true()}{/if}{/foreach}

{set-block scope=root variable=content_type}text/html{/set-block}

{def $parent = $object.main_node.parent}
{if $parent.class_identifier|eq( 'dimmi_forum_reply' )}
{set $parent = $parent.parent}
{/if}

{if $is_update}
{set-block scope=root variable=subject}{$object.content_class.name|wash} [{$sitename} - {$object.main_node.parent.name|wash}]{/set-block}
{set-block scope=root variable=from}{concat($object.current.creator.name|wash,' <', $sender, '>')}{/set-block}
{set-block scope=root variable=message_id}{concat('<node.',$object.main_node_id,'.eznotification','@',$siteurl,'>')}{/set-block}
{set-block scope=root variable=reply_to}{concat('<node.',$object.main_node_id,'.eznotification','@',$siteurl,'>')}{/set-block}
{set-block scope=root variable=references}{section name=Parent loop=$object.main_node.path_array}{concat('<node.',$:item,'.eznotification','@',$siteurl,'>')}{delimiter}{" "}{/delimiter}{/section}{/set-block}

{set-block variable=$content}
{"This email is to inform you that an updated item has been published at %sitename."|i18n('design/standard/notification','',hash('%sitename',$sitename))}
<h3><a href="http://{$siteurl}{$parent.url_alias|ezurl(no)}">{$parent.name|wash()}</a></h3>
<h5>{$object.class_name} - {$object.current.creator.name|wash} - {$object.owner.name|wash}</h5>
<p><em>{attribute_view_gui attribute=$object.data_map.message}</em></p>

<small>{'Per disabilitare le notifiche email clicca %notification_link_start%qui%notification_link_end%'|i18n('openpa_dimmi/mail/post',, hash( '%notification_link_start%', concat( '<a href=http://', $siteurl, '/notification/settings/>' ), '%notification_link_end%', '</a>' ))}</small>

{/set-block}

{else}

{set-block scope=root variable=subject}{$object.content_class.name|wash} [{$sitename} - {$object.main_node.parent.name|wash}]{/set-block}
{set-block scope=root variable=from}{concat($object.owner.name,' <', $sender, '>')}{/set-block}
{set-block scope=root variable=message_id}{concat('<node.',$object.main_node_id,'.eznotification','@',$siteurl,'>')}{/set-block}
{set-block scope=root variable=reply_to}{concat('<node.',$object.main_node.parent_node_id,'.eznotification','@',$siteurl,'>')}{/set-block}
{set-block scope=root variable=references}{section name=Parent loop=$object.main_node.parent.path_array}{concat('<node.',$:item,'.eznotification','@',$siteurl,'>')}{delimiter}{" "}{/delimiter}{/section}{/set-block}

{set-block variable=$content}
{"This email is to inform you that a new item has been published at %sitename."|i18n('design/standard/notification','',hash('%sitename',$sitename))}
<h3><a href="http://{$siteurl}{$parent.url_alias|ezurl(no)}">{$parent.name|wash()}</a></h3>
<h5>{$object.class_name} - {$object.owner.name|wash}</h5>
<p><em>{attribute_view_gui attribute=$object.data_map.message}</em></p>

<small>{'Per disabilitare le notifiche email clicca %notification_link_start%qui%notification_link_end%'|i18n('openpa_sensor/mail/post',, hash( '%notification_link_start%', concat( '<a href=http://', $siteurl, '/notification/settings/>' ), '%notification_link_end%', '</a>' ))}</small>

{/set-block}
{/if}

{include uri='design:mail/mail_pagelayout.tpl' content=$content}

{/if}