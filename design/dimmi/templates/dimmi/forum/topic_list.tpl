{def $page_limit = 20
     $topic_count = fetch( 'content', 'list_count', hash( 'parent_node_id', $node.node_id ) )
     $related_objects = array()
     $topic_reply_count = 0
     $topic_reply_pages = 0
     $col-width=4
     $modulo=3
}

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
          <a href="{concat( 'dimmi/forums/', $topic.node_id )|ezurl(no)}" class="btn btn-primary">Partecipa</a>
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


{include name=navigator
        uri='design:navigator/google.tpl'
        page_uri=concat('/content/view','/full/',$node.node_id)
        item_count=$topic_count
        view_parameters=$view_parameters
        item_limit=$page_limit}
