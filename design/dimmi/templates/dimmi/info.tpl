{cache-block ignore_content_expiry keys=array( $identifier )}
{def $dimmi = dimmi_root_handler()}
{if is_set( $dimmi[$identifier] )}

<section class="hgroup">
  <h1>
    {$dimmi[$identifier].contentclass_attribute_name|wash()}
  </h1>    
</section>

<div class="row">
  <div class="col-md-12">
    {attribute_view_gui attribute=$dimmi[$identifier]}
  </div>
</div>

{/if}
{/cache-block}