{def $show_star_rating = cond($node.data_map.star_rating.data_int|not(), true(), false())}
{def $show_star_rating_label = "Come valuti la chiarezza di questa proposta?"|i18n( 'dimmi/forum' )}
{if $node|has_attribute('star_rating_label')}
  {set $show_star_rating_label = $node|attribute('star_rating_label').data_text|wash( xhtml )}
{/if}
{def $show_star_rating_min_label = "Poco chiara"|i18n( 'dimmi/forum' )}
{if $node|has_attribute('star_rating_label_min')}
  {set $show_star_rating_min_label = $node|attribute('star_rating_label_min').data_text|wash( xhtml )}
{/if}
{def $show_star_rating_max_label = "Molto chiara"|i18n( 'dimmi/forum' )}
{if $node|has_attribute('star_rating_label_max')}
  {set $show_star_rating_max_label = $node|attribute('star_rating_label_max').data_text|wash( xhtml )}
{/if}

{def $show_usefull_rating = cond($node.data_map.usefull_rating.data_int|not(), true(), false())}
{def $show_usefull_rating_label = "Come valuti l'importanza di questa proposta?"|i18n( 'dimmi/forum' )}
{if $node|has_attribute('usefull_rating_label')}
  {set $show_usefull_rating_label = $node|attribute('usefull_rating_label').data_text|wash( xhtml )}
{/if}
{def $show_usefull_rating_min_label = "Poco utile"|i18n( 'dimmi/forum' )}
{if $node|has_attribute('usefull_rating_label_min')}
  {set $show_usefull_rating_min_label = $node|attribute('usefull_rating_label_min').data_text|wash( xhtml )}
{/if}
{def $show_usefull_rating_max_label = "Molto utile"|i18n( 'dimmi/forum' )}
{if $node|has_attribute('usefull_rating_label_max')}
  {set $show_usefull_rating_max_label = $node|attribute('usefull_rating_label_max').data_text|wash( xhtml )}
{/if}

{if is_set($mode)|not()}
  {def $mode = 'all'}
{/if}

{if is_set($wide)|not()}
  {def $wide = false()}
{/if}

{if or( $show_star_rating, $show_usefull_rating )}
<div class="row"{if $mode|eq('user')} style="margin-bottom: 20px"{/if}>
  {if $show_star_rating}
  <div class="{if $wide}col-md-12{else}col-md-6{if $show_usefull_rating|not} col-md-offset-3{/if}{/if} text-center">
      {include uri='design:dimmi/forum/rating.tpl' attribute=$node.data_map.star_rating title=$show_star_rating_label min_label=$show_star_rating_min_label max_label=$show_star_rating_max_label mode=$mode}
  </div>
  {/if}
  {if $show_usefull_rating}
  <div class="{*people_rating *}{if $wide}col-md-12{else}col-md-6{if $show_star_rating|not} col-md-offset-3{/if}{/if} text-center">
      {include uri='design:dimmi/forum/rating.tpl' attribute=$node.data_map.usefull_rating title=$show_usefull_rating_label min_label=$show_usefull_rating_min_label max_label=$show_usefull_rating_max_label mode=$mode}
  </div>
  {/if}
</div>
{/if}