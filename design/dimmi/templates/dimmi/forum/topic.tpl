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
      <p>{$node.data_map.message.content|simpletags|wordtoimage|bracket_to_strong}</p>
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
  
  {include uri='design:dimmi/forum/ratings.tpl' mode=media}

</article>

{include uri='design:dimmi/forum/replies.tpl'}


<script>
var leggiTutto = "{"leggi tutto"|i18n( 'dimmi/forum' )}";
{literal}
$(document).ready(function() {$('.the_comment').readmore({  
  moreLink: '<a class="text-center" href="#"><small>'+leggiTutto+'</small></a>',
  lessLink:''});
});
</script>{/literal}

