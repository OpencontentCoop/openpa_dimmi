{def $dimmi = dimmi_root_handler()}
{def $locales = fetch( 'content', 'translation_list' )}
{ezscript_require( array( 'ezjsc::jquery', 'jquery.quicksearch.min.js' ) )}
{literal}
    <script type="text/javascript">
        $(document).ready(function(){
            $('input.quick_search').quicksearch('table tr');
        });
    </script>
{/literal}
<section class="hgroup">
    <h1>{'Settings'|i18n('dimmi/menu')}</h1>
</section>

{if $dimmi.moderation_is_enabled}
    <div class="alert alert-warning">
        {'Moderazione attivata'|i18n('dimmi/config')}
    </div>
{/if}

<div class="row">
<div class="col-md-12">

<ul class="list-unstyled">
    <li>{'Modifica impostazioni generali'|i18n('dimmi/config')} {include name=edit uri='design:parts/toolbar/node_edit.tpl' current_node=$root redirect_if_discarded='/dimmi/config' redirect_after_publish='/dimmi/config'}</li>
    <li>{'Modifica informazioni Dimmi'|i18n('dimmi/config')} {include name=edit uri='design:parts/toolbar/node_edit.tpl' current_node=$dimmi.forum_container_node redirect_if_discarded='/dimmi/config' redirect_after_publish='/dimmi/config'}</li>
</ul>

<hr />

<div class="row">

    <div class="col-md-3">
        <ul class="nav nav-pills nav-stacked">
            <li role="presentation" {if $current_part|eq('users')}class="active"{/if}><a href="{'dimmi/config/users'|ezurl(no)}">{'Utenti'|i18n('dimmi/config')}</a></li>
            <li role="presentation" {if $current_part|eq('dimmi')}class="active"{/if}><a href="{'dimmi/config/dimmi'|ezurl(no)}">{'Discussioni'|i18n('openpa_dimmi/config')}</a></li>
            {if $data|count()|gt(0)}
                {foreach $data as $item}
                    <li role="presentation" {if $current_part|eq(concat('data-',$item.contentobject_id))}class="active"{/if}><a href="{concat('dimmi/config/data-',$item.contentobject_id)|ezurl(no)}">{$item.name|wash()}</a></li>
                {/foreach}
            {/if}
        </ul>
    </div>

    <div class="col-md-9">

        {if $current_part|eq('dimmi')}
            <div class="tab-pane active" id="dimmi">
                <form action="#">
                    <fieldset>
                        <input type="text" name="search" value="" class="quick_search form-control" placeholder="{'Cerca'|i18n('openpa_dimmi/config')}" autofocus />
                    </fieldset>
                </form>
                <table class="table table-hover">
                    {foreach $forums as $forum}
                        {include name=forumtree uri='design:tools/walk_item_table.tpl' item=$forum recursion=0 insert_child_class=true() redirect_if_discarded='/dimmi/config/dimmi' redirect_after_publish='/dimmi/config/dimmi'  redirect_if_cancel='/dimmi/config/dimmi' redirect_after_remove='/dimmi/config/dimmi'}
                    {/foreach}
                </table>
                <div class="pull-left"><a class="btn btn-info" href="{concat('exportas/csv/dimmi_forum/',$dimmi.forum_container_node.node_id)|ezurl(no)}">{'Esporta in CSV'|i18n('openpa_dimmi/config')}</a></div>
                <div class="pull-right"><a class="btn btn-danger" href="{concat('openpa/add/dimmi_forum/?parent=',$dimmi.forum_container_node.node_id)|ezurl(no)}"><i class="fa fa-plus"></i> {'Aggiungi discussione'|i18n('openpa_dimmi/config')}</a></div>
            </div>
        {/if}

        {if $current_part|eq('users')}
            <div class="tab-pane active" id="users">
                <form action="#">
                    <fieldset>
                        <input type="text" name="search" value="" class="quick_search form-control" placeholder="{'Cerca'|i18n('dimmi/config')}" autofocus />
                    </fieldset>
                </form>
                <table class="table table-hover">
                    {def $users_count = fetch( content, list_count, hash( parent_node_id, $user_parent_node.node_id ) )
                    $users = fetch( content, list, hash( parent_node_id, $user_parent_node.node_id, limit, 30, offset, $view_parameters.offset, sort_by, array( 'name', 'asc' ) ) )}
                    {foreach $users as $user}
                        {def $userSetting = $user|user_settings()}
                        <tr>
                            <td>
                                {if $userSetting.is_enabled|not()}<span style="text-decoration: line-through">{/if}
                                    {*<a href="{$user.url_alias|ezurl(no)}">{$user.name|wash()}</a>*}{$user.name|wash()} <small><em>{$user.data_map.user_account.content.email|wash()}</em></small>
                                    {if $userSetting.is_enabled|not()}</span>{/if}
                            </td>
                            <td width="1">
                                {*include name=edit uri='design:parts/toolbar/node_edit.tpl' current_node=$user*}
                                <a href="{concat('social_user/setting/',$user.contentobject_id)|ezurl(no)}"><i class="fa fa-user"></i></a>
                            </td>
                            <td width="1">{include name=trash uri='design:parts/toolbar/node_trash.tpl' current_node=$user redirect_if_cancel='/dimmi/config/users' redirect_after_remove='/dimmi/config/users'}</td>
                        </tr>
                        {undef $userSetting}
                    {/foreach}

                </table>

                <div class="pull-left"><a class="btn btn-info" href="{concat('exportas/csv/user/',ezini("UserSettings", "DefaultUserPlacement"))|ezurl(no)}">{'Esporta in CSV'|i18n('dimmi/config')}</a></div>

                {include name=navigator
                uri='design:navigator/google.tpl'
                page_uri='dimmi/config/users'
                item_count=$users_count
                view_parameters=$view_parameters
                item_limit=30}
                {undef $users $users_count}
            </div>
        {/if}

        {if $data|count()|gt(0)}
            {foreach $data as $item}
                {if $current_part|eq(concat('data-',$item.contentobject_id))}
                    <div class="tab-pane active" id="{$item.name|slugize()}">
                        {if $item.children_count|gt(0)}
                            <form action="#">
                                <fieldset>
                                    <input type="text" name="search" value="" class="quick_search form-control" placeholder="{'Cerca'|i18n('dimmi/config')}" autofocus />
                                </fieldset>
                            </form>
                            <table class="table table-hover">
                                {foreach $item.children as $child}
                                    <tr>
                                        <td>
                                            {*<a href="{$child.url_alias|ezurl(no)}">{$child.name|wash()}</a>*}{$child.name|wash()}
                                        </td>
                                        <td>
                                            {foreach $child.object.available_languages as $language}
                                                {foreach $locales as $locale}
                                                    {if $locale.locale_code|eq($language)}
                                                        <img src="{$locale.locale_code|flag_icon()}" />
                                                    {/if}
                                                {/foreach}
                                            {/foreach}
                                        </td>
                                        <td width="1">{include name=edit uri='design:parts/toolbar/node_edit.tpl' current_node=$child redirect_if_discarded=concat('/dimmi/config/data-',$item.contentobject_id) redirect_after_publish=concat('/dimmi/config/data-',$item.contentobject_id)}</td>
                                        <td width="1">{include name=trash uri='design:parts/toolbar/node_trash.tpl' current_node=$child redirect_if_cancel=concat('/dimmi/config/data-',$item.contentobject_id) redirect_after_remove=concat('/dimmi/config/data-',$item.contentobject_id)}</td>
                                    </tr>
                                {/foreach}
                            </table>
                            <div class="pull-left"><a class="btn btn-info" href="{concat('exportas/csv/', $item.children[0].class_identifier, '/',$item.node_id)|ezurl(no)}">{'Esporta in CSV'|i18n('dimmi/config')}</a></div>
                            <div class="pull-right"><a class="btn btn-danger"<a href="{concat('add/new/', $item.children[0].class_identifier, '/?parent=',$item.node_id)|ezurl(no)}"><i class="fa fa-plus"></i> {'Aggiungi %classname'|i18n('dimmi/config',, hash( '%classname', $item.children[0].class_name ))}</a></div>
                        {/if}
                    </div>
                {/if}
            {/foreach}
        {/if}
    </div>

</div>

</div>
</div>