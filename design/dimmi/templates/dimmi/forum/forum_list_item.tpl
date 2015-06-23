<div class="row service_teaser">

  {if $node|has_attribute('image')}
  <div class="service_photo col-sm-4 col-md-4 hidden-xs hidden-sm">
    <figure style="background-image:url({$node|attribute('image').content.large.full_path|ezroot(no)})"></figure>

    <section class="call_to_action">
      <a href={concat( 'dimmi/forums/', $node.node_id )|ezurl()} class="btn btn-primary btn-lg btn-block">Partecipa</a>
    </section>

  </div>
  {/if}

  <div class="service_details {if $node|has_attribute('image')}col-sm-8 col-md-8{else}col-sm-12 col-md-12{/if}">      
      <h2 class="section_header skincolored noborder">
        <a href={concat( 'dimmi/forums/', $node.node_id )|ezurl()} class="dark">{$node.name|wash()|bracket_to_strong}</a>
        <a href={concat( 'dimmi/forums/', $node.node_id )|ezurl()} class="btn btn-primary btn-lg pull-right"><strong>Clicca qui per partecipare</strong></a>
        {if $node|has_attribute( 'subtitle' )}
        <small>{$node.object.data_map.subtitle.content|wash|bracket_to_strong}</small>
        {/if}
      </h2>                        
      {if $node|has_attribute( 'call_to_action' )}
        <div class="alert alert-warning">
          {attribute_view_gui attribute=$node.object.data_map.call_to_action}
        </div>
      {/if}      
  </div>
</div>