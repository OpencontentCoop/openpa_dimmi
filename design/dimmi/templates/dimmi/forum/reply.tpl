{def $owner = $reply.object.owner}
{def $post = object_handler($reply).control_dimmi}
<div id="reply-{$reply.node_id}" class="row{if and( is_set( $current_reply.contentobject_id ), $current_reply.contentobject_id|eq($reply.contentobject_id) )} alert alert-warning{/if}">

  <figure class="col-sm-1 col-md-1 col-md-offset-{$recursion}">
    {include uri='design:parts/user_image.tpl' object=$owner}
  </figure>

  <div class="col-sm-{10|sub($recursion|mul(2))} col-md-{10|sub($recursion|mul(2))}">

    <div class="comment_name">
      {if $owner}{$owner.name|wash}{else}?{/if}


      {if $comment_form|not()}
      <div class="pull-right">
        {include name=edit uri='design:parts/toolbar/node_edit.tpl' current_node=$reply}
        {include name=trash uri='design:parts/toolbar/node_trash.tpl' current_node=$reply}
      </div>
      {/if}

      {foreach $reply.object.author_array as $author}
        {if ne( $reply.object.owner_id, $author.contentobject_id )}
          {'Moderated by'|i18n( 'design/ocbootstrap/full/forum_topic' )}: {$author.contentobject.name|wash}
        {/if}
      {/foreach}

    </div>
    <div class="comment_date">
      <i class="fa fa-clock-o"></i> {$reply.object.published|datetime( 'custom', '%l, %d %F %Y %H:%i' )} {if $reply.object.current_version|gt(1)}<em> <i class="fa fa-pencil"></i> {"Modificato"|i18n( 'dimmi/forum')}</em>{/if}
      {if $post.current_moderation_state.identifier|eq('waiting')}
        <span class="label label-{$post.current_moderation_state.css_class}">
          {$post.current_moderation_state.name}
          {if $reply.object.allowed_assign_state_id_list|contains( $post.moderation_states['moderation.accepted'].id )}
            <a href="{concat('dimmi/moderate/',$reply.contentobject_id)|ezurl(no)}" style="color:#fff"><i class="fa fa-close"></i></a>
          {/if}
        </span>
      {/if}
    </div>

    <div class="the_comment">
      <p>{$reply.object.data_map.message.content|simpletags|wordtoimage|autolink}</p>
    </div>


    {if $reply.object.data_map.links.has_content}
      <div class="reply-attachments">
        <strong>{$reply.object.data_map.links.contentclass_attribute.name}</strong>
        {def $links = $reply.object.data_map.links.content|explode(',')}
        <ul class="list-unstyled">
        {foreach $links as $l}
          <li>{$l|autolink}</li>
        {/foreach}
        </ul>
      </div>
    {/if}

    {if $reply.object.data_map.attachments.has_content}
      <div class="reply-attachments">
        <strong>{$reply.object.data_map.attachments.contentclass_attribute.name}</strong>
        <p>{attribute_view_gui attribute=$reply.data_map.attachments}</p>
      </div>
    {/if}

  </div>

  <div class="col-sm-1 col-md-1">
    {include uri='design:dimmi/forum/rating.tpl' attribute=$reply.object.data_map.like_rating}
  </div>


</div>
{undef $owner}

<div class="row">
    <div class="col-sm-12">
        {if and( $recursion|eq(0), $reply.object.can_create, current_social_user().has_deny_comment_mode|not(), $comment_form|not() )}
            <div>
                <a data-reply-id="{$reply.node_id}" href={concat("dimmi/comment/",$reply.parent_node_id,"/",$reply.node_id,'/(offset)/',$offset)|ezurl()} class="comment-reply reply btn btn-xs btn-primary">{"Rispondi"|i18n( 'dimmi/forum')}</a>
            </div>
        {elseif and( $comment_form, is_set( $current_reply.contentobject_id ), $current_reply.contentobject_id|eq($reply.contentobject_id) )}
            {$comment_form}
        {/if}
    </div>
</div>

{if and( $recursion|eq(0), $reply.children_count|gt(0) )}
    {foreach $reply.children as $child}
        {include name=forum_reply uri='design:dimmi/forum/reply.tpl' reply=$child recursion=1 comment_form=$comment_form current_reply=$current_reply offset=$offset}
    {/foreach}
{/if}