{run-once}
{ezcss_require( 'star_rating.css' )}
{ezscript_require( array( 'ezjsc::jquery', 'ezjsc::jqueryio', 'ezstarrating_jquery.js', 'readmore.min.js' ) )}
{/run-once}

{def $reply_limit=20
     $reply_tree_count = fetch('content','tree_count', hash( parent_node_id, $node.node_id ) )
     $reply_count=fetch('content','list_count', hash( parent_node_id, $node.node_id ) )}

<section class="hgroup">
  <h1>
    {$node.name|wash|bracket_to_strong}
    {if $reply_tree_count|gt(0)} <a href="#post_comments"><small><i class="fa fa-comments-o"></i> {$reply_tree_count}  {if $reply_tree_count|gt(1)}{"commenti"|i18n( 'dimmi/forum' )}{else}{"commento"|i18n( 'dimmi/forum' )}{/if}</small></a>{/if}
  </h1>
  <h2>
    <i class="fa fa-clock-o"></i> {$node.modified_subnode|datetime( 'custom', '%l, %d %F %Y' )}
  </h2>
  <ul class="breadcrumb pull-right">
    <li><a href="{concat( 'dimmi/forums/', $node.parent_node_id )|ezurl(no)}"><small>{$node.parent.name|wash()|bracket_to_strong}</small></a></li>
  </ul>
</section>

<article class="post">
  <div class="post_content row">

    {if $node|has_attribute('image')}
    <div class="col-md-3">
      <figure>{attribute_view_gui attribute=$node.data_map.image image_class=original}</figure>
    </div>
    {/if}

    <div class="col-md-{if and( or($node|has_attribute('approfondimenti'),$node|has_attribute('documentazione')), $node|has_attribute('image') )}6{elseif or( $node|has_attribute('approfondimenti'), $node|has_attribute('documentazione'), $node|has_attribute('image') )}9{else}12{/if} abstract">
      <p>{$node.data_map.message.content|simpletags|wordtoimage|autolink|bracket_to_strong}</p>
    </div>

    {if or($node|has_attribute('approfondimenti'),$node|has_attribute('documentazione'))}
      <div class="col-md-3">
        <div class="alert alert-info">
          <strong>{"Per saperne di più..."|i18n( 'dimmi/forum' )}</strong>
          {if $node|has_attribute('approfondimenti')}
          <ul class="list list-unstyled">            
            {foreach $node.data_map.approfondimenti.content.rows.sequential as $s}
              <li><a href="{$s.columns[1]}">{$s.columns[0]}</a></li>
            {/foreach}
        </ul>
        {/if}
        {if $node|has_attribute('documentazione')}
            {attribute_view_gui attribute=$node|attribute('documentazione')}
        {/if}          
        </div>
      </div>
    {/if}

  </div>

  {if or( $node.data_map.star_rating.data_int|not(), $node.data_map.usefull_rating.data_int|not() )}
  <div class="row">
    <div class="col-md-6 text-center">
      {if $node.data_map.star_rating.data_int|not()}
        <h4><span>{"Come valuti la chiarezza di questa proposta?"|i18n( 'dimmi/forum' )}</span></h4>
        {include uri='design:dimmi/forum/rating.tpl' attribute=$node.data_map.star_rating}
      {/if}
    </div>
    <div class="col-md-6 {*people_rating*} text-center">
      {if $node.data_map.usefull_rating.data_int|not()}
        <h4><span>{"Come valuti l'importanza di questa proposta?"|i18n( 'dimmi/forum' )}</span></h4>
        {include uri='design:dimmi/forum/rating.tpl' attribute=$node.data_map.usefull_rating}
      {/if}
    </div>
  </div>
  {/if}

</article>

{if $reply_count}
    {include uri='design:dimmi/forum/replies.tpl'}
{/if}

{if and( $comment_form, current_social_user().has_deny_comment_mode|not(), $current_reply|is_object|not() )}
  {$comment_form}
{elseif and( $node.object.can_create, current_social_user().has_deny_comment_mode|not() )}
    {def $offset = $view_parameters.offset}
    {if is_numeric( $view_parameters.offset )|not()}
        {set $offset = 0}
    {/if}
    <div class="pull-left">
        <a class="btn btn-lg btn-primary comment-reply" href={concat("dimmi/comment/", $node.node_id, "/(offset)/", $offset )|ezurl()}>{'Inserisci commento'|i18n( 'dimmi/forum' )}</a>
    </div>
    {def $notification_access=fetch( 'user', 'has_access_to', hash( 'module', 'notification', 'function', 'use' ) )}
  <form method="post" action={"content/action/"|ezurl}>
    <input type="hidden" name="ContentNodeID" value="{$node.node_id}" />
    <input type="hidden" name="ContentObjectID" value="{$node.contentobject_id}" />
    {if $notification_access}
      <input class="btn btn-lg btn-info pull-right" type="submit" name="ActionAddToNotification" value="{'Tienimi aggiornato'|i18n( 'dimmi/forum' )}" />
    {/if}
    <input type="hidden" name="NodeID" value="{$node.node_id}" />
    <input type="hidden" name="ClassIdentifier" value="dimmi_forum_reply" />
    <input type="hidden" name="ContentLanguageCode" value="{ezini( 'RegionalSettings', 'ContentObjectLocale', 'site.ini')}" />
  </form>
{/if}

{literal}<script>
$(document).ready(function() {$('.the_comment').readmore({moreLink: '<a class="text-center" href="#"><small>{"leggi tutto"|i18n( 'dimmi/forum' )}</small></a>',lessLink:''});});
</script>{/literal}
{*
{literal}<script>
    window.commentStarted = false;
    $(document).ready(function() {
        $('.the_comment').readmore({moreLink: '<a class="text-center" href="#">leggi tutto</a>',lessLink:''});
        $(document).on( 'click', '.__replies-navigator a', function(e){
            $.get({/literal}{'dimmi/comments'|ezurl()}{literal},data,function(response){
                var data = {{/literal}
                    'node_id': {$node.node_id},
                    'reply_count': {$reply_count},
                    'offset': {$view_parameters.offset},
                    'limit': {$reply_limit}
                    {literal}};
            });
            e.preventDefault();
        });

        $(document).on("click", "a.comment-reply", function(e){
            e.preventDefault();
            if( window.commentStarted == false ) {
                window.commentStarted = $(this).clone();
                var that = $(this);
                $.get(that.attr('href'), {ajax: true}, function (response) {
                    that.parent('div').html(response);
                });
            }
        });

        $(document).on("click", ":submit", function(e){
            if( window.commentStarted != false ) {
                var currentAction = $(this).attr('name');
                var form =  $(this).parents('form');
                if ( form.attr('id') == 'edit' ){
                    var data = form.serializeArray();
                    data.push({name:currentAction,value:''});
                    $.ajax({
                        type: "POST",
                        url: form.attr('action'),
                        data: data,
                        dataType: "html",
                        success: function (response) {
                            var hiddenDiv = $('<div style="display:none" />');
                            response = response.replace(/^[\s\S]*<body.*?>|<\/body>[\s\S]*$/g, '');
                            var firstForm = $($(response).find('form')[0]);
                            if(firstForm.attr('id') == 'edit')
                            {
                                form.replaceWith(firstForm);
                            }else{
                                hiddenDiv.html(response);
                                $('body').append(hiddenDiv);
                                var button = hiddenDiv.find('input[type="submit"]');
                                var currentSubAction = button.attr('name');
                                var subForm = button.parents('form');
                                var subData = subForm.serializeArray();
                                subData.push({name: currentSubAction, value: ''});
                                $.ajax({
                                    type: "POST",
                                    url: subForm.attr('action'),
                                    data: subData,
                                    dataType: "html",
                                    success: function (subResponse) {
                                        form.replaceWith(window.commentStarted);
                                        window.commentStarted = false;
                                    }
                                });
                            }
                        }
                    });
                    e.preventDefault();
                }
            }
        });
    });
</script>{/literal}
*}