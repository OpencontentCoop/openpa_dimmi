{* se si usano banner in forum/slideshow scommentare
<section class="call_to_action">
  <h3>{attribute_view_gui attribute=$node.data_map.title}</h3>
  <h4>{attribute_view_gui attribute=$node.data_map.subtitle}</h4>
  <a href="#" class="btn btn-primary btn-lg">{attribute_view_gui attribute=$node.data_map.button_title}</a></section>
</section>
*}

<section class="hgroup{if $node|has_attribute( 'image' )} hidden-lg hidden-md{/if}">
    <h1>
        {attribute_view_gui attribute=$node.data_map.title}
        <small>{attribute_view_gui attribute=$node.data_map.subtitle}</small>
    </h1>
</section>

{if $node|has_attribute('description')}
    <section class="hgroup">
        {attribute_view_gui attribute=$node.data_map.description}
    </section>
{/if}


<section class="service_teasers">

    {foreach $node.children as $item}
        {include name=dimmi_item uri='design:dimmi/forum/forum_list_item.tpl' node=$item total=$node.children_count}
    {/foreach}


</section>

