{def $replies = fetch('content','list', hash( 'parent_node_id', $node.node_id, 'limit', $reply_limit|sum($view_parameters.offset), 'sort_by', array( published, true() ) ) )}

<div class="row">
    <div class="col-md-10 col-md-offset-1">
        <div id="post_comments">

            {include name=navigator
                    uri='design:navigator/google.tpl'
                    page_uri=concat( 'dimmi/forums/', $node.node_id )
                    item_count=$reply_count
                    view_parameters=$view_parameters
                    item_limit=$reply_limit}

            <div class="comment">
                {foreach $replies as $reply}
                    {include name=forum_reply uri='design:dimmi/forum/reply.tpl' reply=$reply recursion=0 comment_form=$comment_form current_reply=$current_reply offset=$view_parameters.offset}
                {/foreach}
            </div>

            {include name=navigator
                    uri='design:navigator/google.tpl'
                    page_uri=concat( 'dimmi/forums/', $node.node_id )
                    item_count=$reply_count
                    view_parameters=$view_parameters
                    item_limit=$reply_limit}
        </div>
    </div>
</div>