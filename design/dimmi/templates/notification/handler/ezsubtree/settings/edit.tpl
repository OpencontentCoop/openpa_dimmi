{let subscribed_nodes=$handler.rules}

{if count($subscribed_nodes)|gt(0)}
    <div class="panel panel-default">
        <div class="panel-heading">
            <h4 class="panel-title">
                {"Notifiche aggiornamento discussioni"|i18n('openpa_sensor/settings')}
            </h4>
        </div>
        <table class="table table-striped">

            {section name=Rules loop=$subscribed_nodes sequence=array(bgdark,bglight)}
                <tr>
                    <td width="1">
                        <input type="checkbox" name="SelectedRuleIDArray_{$handler.id_string}[]"
                               value="{$Rules:item.id}"/>
                    </td>
                    <td>
                        {$Rules:item.node.name|wash}
                    </td>
                </tr>
            {/section}
        </table>
        <div class="panel-footer">
            <input class="btn btn-xs btn-danger" type="submit"
                   name="RemoveRule_{$handler.id_string}" value="Rimuovi selezionati"/>
        </div>
    </div>
{/if}

{/let}


