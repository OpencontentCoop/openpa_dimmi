{def $current_section = $item.node.object.section_identifier}

<tr>
  <td{if $current_section|ne('dimmi')} class="danger"{/if}>
    {if $recursion|eq(0)}
      {if $current_section|eq('dimmi')}
        <a href="{concat('dimmi/visibility/', $item.node.object.id, '/hide')|ezurl(no)}" class="btn btn-success btn-sm" 
           data-toggle="tooltip" data-placement="top"  
           title="Topic visibile al pubblico. Clicca per nascondere.">
            <i class="fa fa-check"></i>
        </a>
      {else}
        <a href="{concat('dimmi/visibility/', $item.node.object.id, '/show')|ezurl(no)}" class="btn btn-danger btn-sm"
           data-toggle="tooltip" data-placement="top"  
           title="Topic nascosto al pubblico. Clicca per rendere visibile.">
            <i class="fa fa-times"></i>
        </a>
      {/if}
    {/if}        
  </td>
  <td{if $current_section|ne('dimmi')} class="danger"{/if}>
    {*<a href="{$item.node.url_alias|ezurl(no)}">*}
      <span style="padding-left:{$recursion|mul(20)}px">
        {if $recursion|eq(0)}<strong>{/if}        
        {$item.node.name|wash()}
        {if $recursion|eq(0)}</strong>{/if}
      </span>
    {*</a>*}
  </td>
  <td{if $current_section|ne('dimmi')} class="danger"{/if} style="white-space: nowrap;">              
	{foreach $item.node.object.available_languages as $language}
	  {foreach fetch( 'content', 'translation_list' ) as $locale}
		{if $locale.locale_code|eq($language)}
		  <img src="{$locale.locale_code|flag_icon()}"/>
		{/if}
	  {/foreach}
	{/foreach}
  </td>
  <td{if $current_section|ne('dimmi')} class="danger"{/if} width="1">{include name=edit uri='design:parts/toolbar/node_edit.tpl' current_node=$item.node redirect_if_discarded=$redirect_if_discarded redirect_after_publish=$redirect_after_publish}</td>
  <td{if $current_section|ne('dimmi')} class="danger"{/if} width="1">{include name=trash uri='design:parts/toolbar/node_trash.tpl' current_node=$item.node}</td>
  <td{if $current_section|ne('dimmi')} class="danger"{/if} width="1">
    {if $item.children|count()|gt(0)}
      <a href={concat("/websitetoolbar/sort/",$item.node.node_id)|ezurl()}><i class="fa fa-sort-alpha-asc "></i>
    {/if}
  </td>

  <td{if $current_section|ne('dimmi')} class="danger"{/if} width="1">
    {if and( $item.children|count()|gt(0), is_set( $insert_child_class ) )}
      <a title="{'Aggiungi'|i18n('social_user/config')}  {$item.children[0].node.class_name} in {$item.node.name|wash()}" href="{concat('openpa/add/', $item.children[0].node.class_identifier, '/?parent=',$item.node.node_id)|ezurl(no)}"><i class="fa fa-plus"></i></a>
    {elseif and( is_set( $child_class ), is_set( $insert_child_class ) )}
      <a title="{'Aggiungi'|i18n('social_user/config')}  {$child_class.name} in {$item.node.name|wash()}" href="{concat('openpa/add/', $child_class.identifier, '/?parent=',$item.node.node_id)|ezurl(no)}"><i class="fa fa-plus"></i></a>
    {elseif is_set( $insert_child_class )|not()}
      <a title="{'Aggiungi'|i18n('social_user/config')} {$item.node.class_name} in {$item.node.name|wash()}" href="{concat('openpa/add/', $item.node.class_identifier, '/?parent=',$item.node.node_id)|ezurl(no)}"><i class="fa fa-plus"></i></a>
    {/if}
  </td>

</tr>
{if $item.children|count()|gt(0)}
  {set $recursion = $recursion|inc()}
  {foreach $item.children as $item_child}
  {include name=itemtree uri='design:dimmi/walk_item_table.tpl' redirect_if_discarded=$redirect_if_discarded redirect_after_publish=$redirect_after_publish item=$item_child recursion=$recursion insert_child_class=is_set( $insert_child_class )}
  {/foreach}
{/if}