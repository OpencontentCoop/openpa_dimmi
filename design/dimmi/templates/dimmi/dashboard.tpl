{def $page_limit = 30
      $all_latest_content_count = fetch( 'content', 'tree_count', hash( 'parent_node_id', dimmi_forum_container().node_id,
                                                                        'class_filter_type', 'include',
                                                                        'class_filter_array', array( 'dimmi_forum_reply' ),
                                                                        'attribute_filter', array( array( 'owner', '=', $current_user.contentobject_id ) ),
                                                                        'sort_by', array( 'published', false() ) ) )
      $all_latest_content = fetch( 'content', 'tree', hash( 'parent_node_id', dimmi_forum_container().node_id,
                                                                  'limit', $page_limit,
                                                                  'offset', $view_parameters.offset,
                                                                  'load_data_map', false(),
                                                                  'class_filter_type', 'include',
                                                                  'class_filter_array', array( 'dimmi_forum_reply' ),
                                                                  'attribute_filter', array( array( 'owner', '=', $current_user.contentobject_id ) ),
                                                                  'sort_by', array( 'published', false() ) ) )}



<section class="hgroup">
  <div class="row">
    <div class="col-md-12">
      <h1>
        {"Le mie discussioni"|i18n('openpa_dimmi/dashboard')}
      </h1>
    </div>
  </div>
</section>

{if $all_latest_content_count|gt(0)}
  <table class="table table-hover">
    <tr>
      <th>Discussione</th>
      <th>Data</th>
      <th>Anteprima</th>
      <th>Likes</th>
    </tr>
    {foreach $all_latest_content as $reply}
    <tr>
      {def $parent = $reply.parent}
      {if $parent.class_identifier|eq('dimmi_forum_reply')}
        {set $parent = $parent.parent}
      {/if}
      <td><a href="{$parent.url_alias|ezurl(no)}">{$parent.name|wash()|bracket_to_strong}</a></td>
      <td>{$reply.object.published|datetime( 'custom', '%d/%m/%Y %H:%i' )}</td>
      <td>{$reply.object.data_map.message.content|shorten(100)}</td>
      <td>{$reply.object.data_map.like_rating.content.rating_count}</td>
    </tr>
    {/foreach}
  </table>
{else}
  <em>Nessuna discussione trovata... Inizia da <a href={"dimmi/forums"|ezurl()}>qui</a></em>
{/if}

{include name=navigator
          uri='design:navigator/google.tpl'
          page_uri='dimmi/dashboard'
          item_count=$all_latest_content_count
          view_parameters=$view_parameters
          item_limit=$page_limit}