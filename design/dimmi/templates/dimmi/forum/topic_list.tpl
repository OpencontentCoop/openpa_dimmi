{def $page_limit = 20
     $topic_count = fetch( 'content', 'list_count', hash( 'parent_node_id', $node.node_id ) )
     $related_objects = array()
     $topic_reply_count = 0
     $topic_reply_pages = 0
     $col-width=4
     $modulo=3
}

{if $topic_count|eq(2)}
  {set $col-width = '6'}
{/if}
{if $topic_count|eq(1)}
  {set $col-width = '6 col-md-offset-3'}
{/if}

{if $topic_count}
  <div class="row">
  {foreach fetch( 'content', 'list', hash( 'parent_node_id', $node.node_id,
                                          'limit', $page_limit, 'offset', $view_parameters.offset,
                                          'sort_by', $node.sort_array ) ) as $topic}
    {set $topic_reply_count=fetch( 'content', 'tree_count', hash( parent_node_id, $topic.node_id ) )
         $topic_reply_pages=sum( int( div( sum( $topic_reply_count, 1 ), 20 ) ), cond( mod( sum( $topic_reply_count, 1 ), 20 )|gt( 0 ), 1, 0 ) )}

    {set $related_objects = fetch( 'content', 'related_objects', hash( 'object_id', $topic.contentobject_id, 'all_relations', true() ) )}
    <div class="col-md-{$col-width}">
      <div class="service_teaser vertical">
        {if $topic|has_attribute( 'image' )}
        <div class="service_photo hidden-xs hidden-sm">
          <figure style="background-image:url({$topic|attribute( 'image' ).content.original.full_path|ezroot(no)})"></figure>
        </div>
        {/if}
        <div class="service_details">
          <h2 class="section_header skincolored">
            <a href="{concat( 'dimmi/forums/', $topic.node_id )|ezurl(no)}">{$topic.object.name|wash|bracket_to_strong}</a>
            <small>{$topic.modified_subnode|datetime( 'custom', '%l, %d %F %Y' )} {if $topic_reply_count|gt(0)}<a class="pull-right" href="{concat( 'dimmi/forums/', $topic.node_id )|ezurl(no)}">{$topic_reply_count} <i class="fa fa-comments-o"></i></a>{/if}</small>
          </h2>
          <p>{$topic.data_map.message.content|simpletags|wordtoimage|autolink|bracket_to_strong}</p>
          {if $topic.data_map.comment_and_vote.data_int|eq(0)}
            <div style="margin: 20px -20px;padding: 3px 0">
              {include name=rating uri='design:dimmi/forum/ratings.tpl' mode=media node=$topic wide=true()}
            </div>
          {else}            
              <div style="margin: 20px -20px;" class="vote-result" data-node="{$topic.node_id}" data-depth="{$topic.depth}"></div>
          {/if}
          <p class="text-center">
            <a href="{concat( 'dimmi/forums/', $topic.node_id )|ezurl(no)}" class="btn btn-primary">{"Partecipa"|i18n( 'dimmi/forum' )}</a>
          </p>
        </div>
      </div>
    </div>
    {delimiter modulo=$modulo}
      </div>
      <div class="row">
    {/delimiter}
  {/foreach}
  </div>
{/if}

{literal}
<script id="tpl-vote-result" type="text/x-jsrender">   
    {{if TOTAL > 0}}
    <div class="row">
        <div class="col-md-12 text-center">
            <h4>{/literal}{"La media dei voti"|i18n( 'dimmi/forum' )}{literal} <small style="color:#000">(<span>{{:TOTAL}} {{if TOTAL > 1}}{/literal}{"votanti"|i18n( 'dimmi/forum' )}{literal} {{else}}{/literal}{"votante"|i18n( 'dimmi/forum' )}{literal}{{/if}}</span>)</small></h4>    
            <div class="row">
                <div class="col-md-12">                    
                    <div class="progress">
                      <div class="progress-bar progress-bar-success" role="progressbar" aria-valuenow="{{:SI_perc}}" aria-valuemin="0" aria-valuemax="100" style="width: {{:SI_perc}}%;">
                        {{:SI_perc}}% 
                      </div>                    
                      <div class="progress-bar progress-bar-danger" role="progressbar" aria-valuenow="{{:NO_perc}}" aria-valuemin="0" aria-valuemax="100" style="width: {{:NO_perc}}%;">
                        {{:NO_perc}}% 
                      </div>
                    </div>             
                    <strong>
                      {/literal}{"il"|i18n( 'dimmi/forum' )}{literal} {{:SI_perc}}% {/literal}{"è d'accordo"|i18n( 'dimmi/forum' )}{literal} 
                      ({{:SI}} {{if SI > 1}}{/literal}{"utenti"|i18n( 'dimmi/forum' )}{literal} {{else}}{/literal}{"utente"|i18n( 'dimmi/forum' )}{literal}{{/if}})
                    </strong><br />
                    <strong>
                      {/literal}{"il"|i18n( 'dimmi/forum' )}{literal} {{:NO_perc}}% {/literal}{"non è d'accordo"|i18n( 'dimmi/forum' )}{literal} 
                      ({{:NO}} {{if NO > 1}}{/literal}{"utenti"|i18n( 'dimmi/forum' )}{literal} {{else}}{/literal}{"utente"|i18n( 'dimmi/forum' )}{literal}{{/if}})
                    </strong><br />                              
                </div>
            </div>            
        </div>
    </div>
    {{/if}}
</script>
{/literal}

{include name=navigator
        uri='design:navigator/google.tpl'
        page_uri=concat('/content/view','/full/',$node.node_id)
        item_count=$topic_count
        view_parameters=$view_parameters
        item_limit=$page_limit}

{ezcss_require( 'star_rating.css' )}
{ezscript_require( array( 'ezjsc::jquery', 'ezjsc::jqueryio', 'ezstarrating_jquery.js', 'readmore.min.js', 'jquery.opendataTools.js', 'jsrender.js') )}

<script type="text/javascript" language="javascript">
{literal}
$(document).ready(function () {
    var CommentIsVoteTemplate = $.templates('#tpl-vote-result');    
    var tools = $.opendataTools; 
    $('.vote-result').each(function(){
      var container = $(this);
      var TopicNodeid = $(this).data('node');
      var TopicDepth = $(this).data('depth') + 1;
      var query = "subtree ["+TopicNodeid+"] and classes [dimmi_forum_reply] and raw[meta_depth_si] = "+TopicDepth+" sort [published=>asc] limit 1 facets [vote]";
      tools.find(query, function (response) { 
          var renderResponse = response.facets[0].data;
          if (!renderResponse.SI){
              renderResponse.SI = 0;
          }
          if (!renderResponse.NO){
              renderResponse.NO = 0;
          }
          renderResponse.TOTAL = renderResponse.SI + renderResponse.NO;
          if (renderResponse.TOTAL > 0){
              renderResponse.SI_perc = renderResponse.SI > 0 ? (renderResponse.SI * 100 / renderResponse.TOTAL).toFixed(2) : 0;
              renderResponse.NO_perc = 100 - renderResponse.SI_perc;
          }
          container.html(CommentIsVoteTemplate.render(renderResponse));
      });
    });  
});
{/literal}
</script>