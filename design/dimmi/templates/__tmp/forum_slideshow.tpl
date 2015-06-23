{def $forum = fetch( content, node, hash( node_id, $node_id ) )}
<section id="slider_wrapper" class="slider_wrapper full_page_photo hidden-xs hidden-sm">
  <div id="main_flexslider" class="flexslider">
    <ul class="slides list-unstyled">
      <li class="item" style="background-image: url({$forum.data_map.image.content.original.full_path|ezroot(no)})">
        <div class="container">
          <div class="carousel-caption">
            <h1>{$forum.name|wash()|bracket_to_strong}</h1>
          </div>
      </li>
    </ul>
  </div>
</section>
