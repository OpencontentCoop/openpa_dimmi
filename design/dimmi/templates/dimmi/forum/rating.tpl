{def $rating = $attribute.content}
{if is_set}

{if and( eq($attribute.contentclass_attribute_identifier, 'like_rating'), $attribute.data_int|not() )}
    
    {def $user_rating = $rating|dimmi_user_rating()}
    <div class="hreview-aggregate like_rating well well-sm">
      <ul id="ezsr_rating_{$attribute.id}" class="ezsr-star-rating do-rate">
        <li id="ezsr_userrating_percent_{$attribute.id}" class="ezsr-current-rating" data-div="1" data-current="{if $user_rating}{$user_rating.rating}{/if}" style="width:{if $user_rating}{$user_rating.rating|div(1)|mul(100)}{else}0{/if}%;"><span>{if $user_rating}1{else}0{/if}</span></li>
        {for 1 to 1 as $num}
          <li><a href="JavaScript:void(0);" id="ezsr_{$attribute.id}_{$attribute.version}_{$num}" class="ezsr-stars-{$num}" rel="nofollow" onfocus="this.blur();">{$num}</a></li>
        {/for}
      </ul>
      <span id="ezsr_total_{$attribute.id}">{$rating.rating_count|wash}</span>
      {*<p id="ezsr_just_rated_{$attribute.id}" class="ezsr-just-rated hide">{'Thank you for rating!'|i18n('extension/ezstarrating/datatype', 'When rating')}</p>
      <p id="ezsr_has_rated_{$attribute.id}" class="ezsr-has-rated hide">Hai già votato!</p>*}
    </div>
    {undef $user_rating}

{elseif $attribute.data_int|not()}
    
    <div class="row">
    
    {if or($mode|eq('all'), $mode|eq('user'))}
    {def $user_rating = $rating|dimmi_user_rating()}
    <div class="hreview-aggregate col-md-{if $mode|eq('all')}6{else}12{/if}">
      
      <h4>{"Il tuo voto"|i18n( 'dimmi/forum' )}</h4>
      <p><strong>{$title}</strong></p>
      {if is_set($min_label)}
        <span class="ezsr-star-rating-label"><small>{$min_label}</small></span>            
      {/if}

      <ul class="ezsr-star-rating do-rate">
        <li id="ezsr_userrating_percent_{$attribute.id}" class="ezsr-current-rating" data-div="4" style="width:{if $user_rating}{$user_rating.rating|div(4)|mul(100)}{else}1{/if}%;">Attualmente <span>{if $user_rating}{$user_rating.rating|wash}{else}0{/if}</span> su 4</li>
        {for 1 to 4 as $num}
          <li><a href="JavaScript:void(0);" id="ezsruser_{$attribute.id}_{$attribute.version}_{$num}" title="{$num}" class="ezsr-stars-{$num}" rel="nofollow" onfocus="this.blur();">{$num}</a></li>
        {/for}
      </ul>

      {if is_set($max_label)}
        <span class="ezsr-star-rating-label"><small>{$max_label}</small></span>
      {/if}

    </div>    
    {undef $user_rating}
    {/if}

    {if or($mode|eq('all'), $mode|eq('media'))}
    <div class="hreview-aggregate col-md-{if $mode|eq('all')}6{else}12{/if}">

      <div class="">
        <h4>{"La media dei voti"|i18n( 'dimmi/forum' )} <small style="color:#000">(<span id="ezsr_total_{$attribute.id}" class="votes">{$rating.rating_count|wash}</span> {"votanti"|i18n( 'dimmi/forum' )})</small></h4>
        <p><strong>{$title}</strong></p>
        {if is_set($min_label)}
          <span class="ezsr-star-rating-label"><small>{$min_label}</small></span>
        {/if}

        <ul class="ezsr-star-rating">
          <li id="ezsr_rating_percent_{$attribute.id}" class="ezsr-current-rating" data-div="4" style="width:{$rating.rounded_average|div(4)|mul(100)}%;">Attualmente <span>{$rating.rounded_average|wash}</span> su 4</li>
          {for 1 to 4 as $num}
            <li><a href="JavaScript:void(0);" id="ezsr_{$attribute.id}_{$attribute.version}_{$num}" title="{$num}" class="ezsr-stars-{$num}" rel="nofollow" onfocus="this.blur();">{$num}</a></li>
          {/for}
        </ul>

        {if is_set($max_label)}
          <span class="ezsr-star-rating-label"><small>{$max_label}</small></span>
        {/if}

      </div>      
    </div>
    {/if}

    {if or($mode|eq('all'), $mode|eq('user'))}
      <p style="text-align: center;" id="ezsr_just_rated_{$attribute.id}" class="ezsr-just-rated hide">{"Grazie per aver espresso il tuo parere!"|i18n( 'dimmi/forum' )}</p>
      <p style="text-align: center;" id="ezsr_has_rated_{$attribute.id}" class="ezsr-has-rated hide">{"Puoi esprimere il tuo parere una volta sola"|i18n( 'dimmi/forum' )}</p>
      <p style="text-align: center;" id="ezsr_changed_rating_{$attribute.id}" class="ezsr-changed-rating hide">{"Grazie per aver aggiornato il tuo parere!"|i18n( 'dimmi/forum' )}</p>
    {/if}

    </div>

{/if}

{undef $rating}
