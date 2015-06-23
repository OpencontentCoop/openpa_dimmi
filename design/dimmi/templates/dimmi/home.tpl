{def $topic = dimmi_forum_container()}
<section class="hgroup noborder">
    <div class="row">
        <div class="col-sm-12">
            {foreach $topic.children as $child}
                {include uri='design:dimmi/forum/block_item.tpl' topic=$child}
            {/foreach}
        </div>
    </div>
</section>
{undef $topic}