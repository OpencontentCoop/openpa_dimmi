<section>
    <h1>{$node.name|wash()|bracket_to_strong}</h1>
</section>

{if $node|has_attribute( 'call_to_action' )}    
  <div class="alert alert-warning">
      {attribute_view_gui attribute=$node.object.data_map.call_to_action}
  </div>
{/if}

<section class="hidden-xs hidden-sm noborder">
    {attribute_view_gui attribute=$node.data_map.description}
</section>

<div id="partecipa">
    {include uri='design:dimmi/forum/topic_list.tpl' node=$node}
</div>