<div id="vote-result" class="text-center"></div>
<div class="row">
    <div class="col-md-10 col-md-offset-1">        
        <ul class="list-unstyled" id="post_comments">
        </ul>
    </div>
</div>

<div class="row">
    <div class="col-md-10 col-md-offset-1">
        {if fetch(user, current_user).is_logged_in}
          {include uri='design:dimmi/forum/ratings.tpl' mode=user}
        {/if}

        <div id="reply-form" class="well"></div>
    </div>
</div>


{ezscript_require(array(
    'ezjsc::jquery','ezjsc::jqueryUI',
    'handlebars.min.js',
    'jquery.opendataTools.js',
    'moment-with-locales.min.js',
    'jsrender.js',
    'bootstrap-datetimepicker.min.js',
    'jquery.fileupload.js',
    'jquery.fileupload-process.js',
    'jquery.fileupload-ui.js',
    'alpaca.js',
    'jquery.opendataform.js'
) )}
{ezcss_require( array(
    'alpaca.min.css',
    'jquery.fileupload.css',
    'alpaca-custom.css'
) )}

<script type="text/javascript" language="javascript">
    
    var TopicNodeid = {$node.node_id};
    var TopicDepth = {$node.depth} + 1;
    var pageLimit = {$reply_limit};  
    var CurrentUserID = {fetch(user, current_user).contentobject_id};
    var CurrentUserIsRegistered = {cond(fetch(user, current_user).is_logged_in, 'true', 'false')};
    var CommentIsVote = {cond($node.data_map.comment_and_vote.data_int|eq(1),'true', 'false')};
    var EnableAttachments = {cond($node.data_map.enable_attachments.data_int|eq(1),'true', 'false')};
    var EnableLinks = {cond($node.data_map.enable_links.data_int|eq(1),'true', 'false')};
    var AlreadyVoted = {cond(fetch(content, object, hash(remote_id, concat('vote_',$node.node_id,'_', fetch(user, current_user).contentobject_id))), 'true', 'false')};

    var STRING_ReplyTo = "{'Rispondi a'|i18n('dimmi/forum')}";

    var STRING_Store = "{'Salva'|i18n('dimmi/forum')}";

    var CurrentLanguage = "{ezini('RegionalSettings', 'Locale')}";

    {literal}

    $(document).ready(function () {

        var UrlPrefix = '/';
        if ($.isFunction($.ez)){
            UrlPrefix = $.ez.root_url;
        }

        var showForm = CurrentUserIsRegistered;
        if (CommentIsVote && AlreadyVoted){
            showForm = false;            
        }
        if (showForm){
            $('#reply-form').opendataFormCreate({
                "class": 'dimmi_forum_reply',
                "parent": TopicNodeid
            },{
                "onSuccess": function(data){
                    loadContents();     
                    if (CommentIsVote){
                       $('#reply-form').alpaca('destroy');
                       $('#reply-form').hide();
                    }else{
                        $('#reply-form').alpaca('get').clear();
                    }         
                },
                "alpaca": {
                    "options": {
                        "form": {
                            "buttons": {
                                "submit": {
                                    "value": STRING_Store
                                }
                            }
                        }
                    }
                }
            });
        }else{
            $('#reply-form').hide();
        }

        var tools = $.opendataTools;        
        tools.settings('endpoint', {
            search: UrlPrefix+'opendata/api/dimmi/search/'                
        })
        $.views.helpers(tools.helpers);

        var ReplyCurrentPage = 0;
        var ReplyQueryPerPage = [];        
        var ReplyListContainer = $('#post_comments');
        var ReplyListTemplate = $.templates('#tpl-replies');        
        
        var ResponseQueryPerPage = [];        
        var ResponseListTemplate = $.templates('#tpl-comments');        

        var CommentIsVoteTemplate = $.templates('#tpl-vote-result');    
    
        var decorateContent = function(content, context){
            var decoratedContent = content;
            var mainLanguage = content.metadata.languages[0];
            var canEditLanguage = false;
            if ($.inArray(CurrentLanguage, content.metadata.languages) > -1){
                mainLanguage = CurrentLanguage;
                canEditLanguage = true;
            }            
            
            decoratedContent.data = content.data[mainLanguage];
            decoratedContent.metadata.name = content.metadata.name[mainLanguage];
            if (content.metadata.ownerName)
                if (content.metadata.ownerName[mainLanguage])
                    decoratedContent.metadata.ownerName = content.metadata.ownerName[mainLanguage];
                else
                    decoratedContent.metadata.ownerName = content.metadata.ownerName[Object.keys(content.metadata.ownerName)[0]];
            else
                decoratedContent.metadata.ownerName = '?';
            decoratedContent.context = context;
            decoratedContent.metadata.currentUserID = CurrentUserID;            
            decoratedContent.is_vote = CommentIsVote;
            decoratedContent.enableAttachments = EnableAttachments;
            decoratedContent.enableLinks = EnableLinks;
            decoratedContent.currentUserIsRegistered = CurrentUserIsRegistered;
            decoratedContent.canEditLanguage = canEditLanguage;
            return decoratedContent;
        };

        function _rate(e) {
            e.preventDefault();
            var args = $(this).attr('id').split('_');
            var id = args[1];
            var version = args[2];
            var value = args[3];
            
            var div = $('#ezsr_userrating_percent_' + id).data('div');
            var current = $('#ezsr_userrating_percent_' + id).data('current');

            $('#ezsr_rating_' + id).removeClass('ezsr-star-rating-enabled');
            $('li a', '#ezsr_rating_' + id).unbind('click');        
            jQuery.ez('ezstarrating::rate::' + id + '::' + version + '::' + value, {}, _callBack);                
            $('#ezsr_userrating_percent_' + id).css('width', (( value / div ) * 100 ) + '%');        
            return false;
        }

        function _callBack(data) {
            if (data && data.content !== '') {
                if (data.content.rated) {
                    if (data.content.already_rated){
                        $('#ezsr_changed_rating_' + data.content.id).removeClass('hide');
                        $('#ezsr_just_rated_' + data.content.id).addClass('hide');
                    }else{
                        $('#ezsr_just_rated_' + data.content.id).removeClass('hide');
                    }                
                    var div = $('#ezsr_rating_percent_' + data.content.id).data('div');
                    $('#ezsr_rating_percent_' + data.content.id).css('width', (( data.content.stats.rounded_average / div ) * 100 ) + '%');
                    $('#ezsr_average_' + data.content.id).text(data.content.stats.rating_average);
                    $('#ezsr_total_' + data.content.id).text(data.content.stats.rating_count);
                }
                else if (data.content.already_rated)
                    $('#ezsr_has_rated_' + data.content.id).removeClass('hide');
                //else alert('Invalid input variables, could not rate!');
            }
            else {
                // This shouldn't happen as we have already checked access in the template..
                // Unless this is inside a aggressive cache-block of course.
                alert(data.content.error_text);
            }
        }

        var runQuery = function (query, subtree, container, template, context) {                    
            tools.find(query, function (response) {            
                                
                var renderResponse = $.extend({}, response);
                renderResponse.subtree = subtree;                
                if (context == 'topic'){
                    renderResponse.currentPage = ReplyCurrentPage;
                    ReplyQueryPerPage[ReplyCurrentPage] = query;                    
                    renderResponse.prevPageQuery = jQuery.type(ReplyQueryPerPage[ReplyCurrentPage - 1]) === "undefined" ? null : ReplyQueryPerPage[ReplyCurrentPage - 1];
                }else{
                    if (jQuery.type(ResponseQueryPerPage[subtree]) === "undefined" ){
                        ResponseQueryPerPage[subtree] = {
                            currentPage: 0,
                            queries: []
                        }
                    }
                    var current = ResponseQueryPerPage[subtree].currentPage;
                    ResponseQueryPerPage[subtree].queries[current] = query;                    
                    var queries = ResponseQueryPerPage[subtree].queries;
                    renderResponse.currentPage = current;
                    renderResponse.prevPageQuery = jQuery.type(queries[current - 1]) === "undefined" ? null : queries[current - 1];
                }

                renderResponse.searchHits = []
                $.each(response.searchHits, function(){                    
                    renderResponse.searchHits.push(decorateContent(this, context));
                });
                
                var renderData = $(template.render(renderResponse));

                container.html(renderData);

                if (context == 'topic'){                    
                    container.find('.reply_comments').each(function(){
                        loadReplyComments($(this));
                    });
                    if (CurrentUserIsRegistered){
                        container.find('.add-reply').each(function(){
                            var subtree = $(this).data('subtree');
                            var placeholder = $(this).data('owner');
                            var container = $($(this).data('container'));
                            var tokenNode = document.getElementById('ezxform_token_js');
                            if ( tokenNode ){
                                Alpaca.CSRF_TOKEN = tokenNode.getAttribute('title');
                            }
                            var $that = $(this);
                            $that.alpaca({
                                "schema": {
                                    "type":"object",
                                    "properties": {
                                        'message':{
                                            "type":"string"
                                        }
                                    }
                                },
                                "options":{
                                    "fields": {
                                        'message':{
                                            "placeholder": STRING_ReplyTo+" "+placeholder,
                                            "fieldClass": 'col-xs-12',
                                            "required": true
                                        }
                                    },
                                    "focus": null,
                                    "form":{
                                        "attributes":{
                                            "action":UrlPrefix+"forms/connector/default/action?class=dimmi_forum_reply&parent="+subtree,
                                            "method":"post"
                                        },
                                        "buttons":{
                                            "submit":{
                                                "click": function() {
                                                    this.refreshValidationState(true);
                                                    if (this.isValid(true)) {
                                                        var promise = this.ajaxSubmit();
                                                        promise.done(function(data) {
                                                            if (data.error) {
                                                                alert(data.error);
                                                            } else {
                                                                $that.alpaca('get').clear();
                                                                loadReplyComments(container);
                                                            }
                                                        });
                                                        promise.fail(function(error) {
                                                            alert(error);
                                                        });
                                                    }
                                                },                                            
                                                "value": "<i class='fa fa-comments-o fa-lg fa-3x'></i>",
                                                "styles": "btn btn-sm btn-link pull-left hide"
                                            }
                                        }                                    
                                    }                                
                                },
                                "view" : {
                                    "parent": "bootstrap-create"
                                    
                                }
                            });
                        });
                    }
                }

                container.find('.edit-object').on('click', function (e) {
                    var objectId = $(this).data('object');
                    $('#edit-form').opendataFormEdit({
                        "object": objectId
                    },{
                        onBeforeCreate: function(){
                            $('#modal').modal('show')
                        },
                        "onSuccess": function(data){
                            loadContents();
                            $('#modal').modal('hide');
                        }
                    });
                    e.preventDefault();
                });

                container.find('ul.do-rate li a').on('click',_rate);

                container.find('.nextPage').on('click', function (e) {
                    if (context == 'topic'){
                        ReplyCurrentPage++;
                    }else{
                        ResponseQueryPerPage[subtree].currentPage++;
                    }
                    runQuery($(this).data('query'), $(this).data('subtree'), container, template, context);
                    e.preventDefault();
                });

                container.find('.prevPage').on('click', function (e) {
                    if (context == 'topic'){
                        ReplyCurrentPage--;
                    }else{
                        ResponseQueryPerPage[subtree].currentPage--;
                    }
                    runQuery($(this).data('query'), $(this).data('subtree'), container, template, context);
                    e.preventDefault();
                });
                
                
            });
        };

        var loadReplyComments = function(container){
            var subtree = container.data('reply_node');
            var depth = TopicDepth + 1;
            var query = "subtree ["+subtree+"] and classes [dimmi_forum_reply] and raw[meta_depth_si] = "+depth+" sort [published=>asc] limit " + pageLimit;
            runQuery(query, subtree, container, ResponseListTemplate, 'reply');
        }

        var loadContents = function () {             
            var query = "subtree ["+TopicNodeid+"] and classes [dimmi_forum_reply] and raw[meta_depth_si] = "+TopicDepth+" sort [published=>asc]";
            runQuery(query+" limit " + pageLimit, TopicNodeid, ReplyListContainer, ReplyListTemplate, 'topic');

            if (CommentIsVote){
                tools.find(query + ' limit 1 facets [vote]', function (response) { 
                    var renderResponse = response.facets[0].data;
                    if (!renderResponse.SI){
                        renderResponse.SI = 0;
                    }
                    if (!renderResponse.NO){
                        renderResponse.NO = 0;
                    }
                    renderResponse.TOTAL = renderResponse.SI + renderResponse.NO;
                    if (renderResponse.TOTAL > 0){
                        renderResponse.SI_perc = renderResponse.SI > 0 ? (renderResponse.SI * 100 / renderResponse.TOTAL).toFixed(2) : 0;
                        renderResponse.NO_perc = 100 - renderResponse.SI_perc;
                    }
                    $('#vote-result').html(CommentIsVoteTemplate.render(renderResponse));
                });
            }
        };

        loadContents();
    });
    {/literal}
</script>

{literal}

<script id="tpl-vote-result" type="text/x-jsrender">   
    {{if TOTAL > 0}}
    <div class="row">
        <div class="col-md-6 col-md-offset-3 text-center">
            <h4>{/literal}{"La media dei voti"|i18n( 'dimmi/forum' )}{literal} <small style="color:#000">(<span>{{:TOTAL}} {{if TOTAL > 1}}{/literal}{"votanti"|i18n( 'dimmi/forum' )}{literal} {{else}}{/literal}{"votante"|i18n( 'dimmi/forum' )}{literal}{{/if}}</span>)</small></h4>    
            <div class="row">
                <div class="col-md-6">
                    <div class="progress">
                      <div class="progress-bar progress-bar-success" role="progressbar" aria-valuenow="{{:SI_perc}}" aria-valuemin="0" aria-valuemax="100" style="width: {{:SI_perc}}%;"></div>
                    </div>        
                </div>
                <div class="col-md-6 text-left">
                    {/literal}{"il"|i18n( 'dimmi/forum' )}{literal} {{:SI_perc}}% {/literal}{"è d'accordo"|i18n( 'dimmi/forum' )}{literal} 
                    ({{:SI}} {{if SI > 1}}{/literal}{"utenti"|i18n( 'dimmi/forum' )}{literal} {{else}}{/literal}{"utente"|i18n( 'dimmi/forum' )}{literal}{{/if}})
                </div>
            </div>
            <div class="row">
                <div class="col-md-6">
                    <div class="progress">
                      <div class="progress-bar progress-bar-danger" role="progressbar" aria-valuenow="{{:NO_perc}}" aria-valuemin="0" aria-valuemax="100" style="width: {{:NO_perc}}%;"></div>
                    </div>        
                </div>
                <div class="col-md-6 text-left">
                    {/literal}{"il"|i18n( 'dimmi/forum' )}{literal} {{:NO_perc}}% {/literal}{"non è d'accordo"|i18n( 'dimmi/forum' )}{literal} 
                    ({{:NO}} {{if NO > 1}}{/literal}{"utenti"|i18n( 'dimmi/forum' )}{literal} {{else}}{/literal}{"utente"|i18n( 'dimmi/forum' )}{literal}{{/if}})
                </div>
            </div>            
        </div>
    </div>
    {{/if}}
</script>

<script id="tpl-replies" type="text/x-jsrender">    
{{for searchHits}}
    {{include tmpl="#tpl-reply"/}}
{{/for}}
<li class="clearfix">
    {{if prevPageQuery}}
        <div class="pull-left"><a class="btn btn-primary prevPage" href="#" data-subtree="{{:subtree}}" data-query="{{>prevPageQuery}}">Commenti precedenti</a></div>
    {{/if}}
    {{if nextPageQuery }}
        <div class="pull-right"><a class="btn btn-primary nextPage" href="#" data-subtree="{{:subtree}}" data-query="{{>nextPageQuery}}">Commenti successivi</a></div>       
    {{/if}}
</li>   
</script>

<script id="tpl-reply" type="text/x-jsrender">
<li class="row comment">
    <div class="clearfix {{if metadata.ownerId == metadata.currentUserID}} alert alert-info{{/if}}">
        <figure class="col-sm-1 col-md-1">        
            {{include tmpl="#tpl-author"/}}
        </figure>
        <div class="col-sm-11 col-md-11">        
            <div class="comment_date">
                <strong style="font-size: 1.2em">
                    {{:metadata.ownerName}}
                    {{if context == 'topic' && is_vote}}
                        {{if data.vote == 'SI'}}<span class="label label-success">{/literal}{"è d'accordo"|i18n( 'dimmi/forum' )}{literal}</span>{{else data.vote == 'NO'}}<span class="label label-danger">{/literal}{"non è d'accordo"|i18n( 'dimmi/forum' )}{literal}</span>{{/if}}
                    {{/if}}
                </strong>
                <i class="fa fa-clock-o"></i> {{:~formatDate(metadata.published, 'D/MM/YYYY H:mm')}}                         
                
                {{if metadata.moderation.identifier == 'waiting'}}
                <span class="btn btn-xs btn-warning" style="cursor: default;">
                    {{:metadata.moderation.name}}
                    {{if metadata.moderation.can_accept}}
                        <a href="{/literal}{'dimmi/moderate/'|ezurl(no)}{literal}/{{:metadata.id}}" style="color:#fff"><i class="fa fa-close"></i></a>
                    {{/if}}
                </span>
                {{/if}}

                {{if metadata.ownerId == metadata.currentUserID}} 
                    {{if context == 'topic' && is_vote}}                   
                    {{else canEditLanguage}}
                        <a href="#" class="btn btn-xs btn-success edit-object" data-object="{{:metadata.id}}"><i class="fa fa-pencil"></i></a>
                    {{/if}}
                {{/if}}
            </div>
            
                   
            <div class="clearfix">
                <div class="the_comment">   
                    <div class="hreview-aggregate like_rating pull-right" style="transform: scale(.7);padding: 0;margin: 0 10px 0 0">
                      <ul id="ezsr_rating_{{:data._like_rating.id}}" class="ezsr-star-rating do-rate" style="padding: 0;margin: 0">
                        <li id="ezsr_userrating_percent_{{:data._like_rating.id}}" class="ezsr-current-rating" data-div="1" data-current="{{if data._like_rating.user_rating}}{{:data._like_rating.user_rating}}{{/if}}" style="width:{{if data._like_rating.user_rating}}100{{else}}0{{/if}}%;"><span></span></li>            
                        <li><a href="#" id="ezsr_{{:data._like_rating.id}}_{{:data._like_rating.version}}_1" class="ezsr-stars-1" rel="nofollow">1</a></li>            
                      </ul>          
                      <span id="ezsr_total_{{:data._like_rating.id}}">{{:data._like_rating.rating_count}}</span>
                    </div>             
                </div>
                <p style="font-size: 1.2em;margin-bottom: 0">{{:data.message}}</p>
                <div class="text-left"> 
                    {{if metadata.currentVersion > 1}}<em><small>{/literal}{"Modificato"|i18n( 'dimmi/forum')}{literal}</em></small>{{/if}}
                    {{if metadata.authorArray.length > 1}}<small><em>Moderato</em></small>{{/if}}
                </div>
            </div>
            
            {{if (data.links && enableLinks) || (data.attachments && enableAttachments)}}
            <div class="row" style="margin-top:10px">
            {{if data.links && enableLinks}}        
            <div class="reply-attachments {{if data.attachments && enableAttachments}}col-md-6{{else}}col-md-12{{/if}}">
                <div class="well well-sm">
                    <strong>{/literal}{"Link utili"|i18n( 'dimmi/forum' )}{literal}</strong>            
                    <ul class="list-unstyled">
                    {{for data.links}}
                    <li><a class="truncate" href="{{>#data}}">{{>#data}}</a></li>
                    {{/for}}
                    </ul>                
                </div>
            </div>
            {{/if}}

            {{if data.attachments && enableAttachments}}
            <div class="reply-attachments {{if data.links && enableLinks}}col-md-6{{else}}col-md-12{{/if}}">
                <div class="well well-sm">
                    <strong>{/literal}{"Allegati"|i18n( 'dimmi/forum' )}{literal}</strong><br/>
                    <a class="truncate" href="{{:data.attachments.url}}"><i class="fa fa-download"></i> {{:data.attachments.filename}}</a>
                </div>
            </div>
            {{/if}}   
            </div>
            {{/if}}  

            <ul class="list-unstyled reply_comments" id="reply_comments-{{:metadata.mainNodeId}}" data-reply_node="{{:metadata.mainNodeId}}"></ul>        

            {{if context == 'topic'}}
                <div class="add-reply" style="margin-top:15px" data-container="#reply_comments-{{:metadata.mainNodeId}}" data-subtree="{{:metadata.mainNodeId}}" data-owner="{{:metadata.ownerName}}"></div>
            {{/if}}

        </div>
    </div>
</li>
</script>

<script id="tpl-author" type="text/x-jsrender">    
    <img src={/literal}{"user_placeholder.jpg"|ezimage()}{literal} title="{{:ownerName}}" class="img-circle" />
</script>

<script id="tpl-comments" type="text/x-jsrender">    
{{for searchHits}}
    {{include tmpl="#tpl-reply"/}}
{{/for}}
<li>
    {{if prevPageQuery}}
        <div class="pull-left"><a class="label label-primary prevPage" href="#" data-subtree="{{:subtree}}" data-query="{{>prevPageQuery}}">Risposte precedenti</a></div>
    {{/if}}
    {{if nextPageQuery }}
        <div class="pull-right"><a class="label label-primary nextPage" href="#" data-subtree="{{:subtree}}" data-query="{{>nextPageQuery}}">Risposte successive</a></div>       
    {{/if}}
</li>   
</script>
{/literal}

<div id="modal" class="modal fade">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-body">
                <div class="clearfix">
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                </div>
                <div id="edit-form"></div>
            </div>
        </div>
    </div>
</div>
