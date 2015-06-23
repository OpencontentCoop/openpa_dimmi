{if is_set( $sensor )|not()}{def $sensor = sensor_root_handler()}{/if}
{if $sensor.forum_container_node|has_attribute( 'image' )}
<section id="slider_wrapper" class="slider_wrapper full_page_photo hidden-xs hidden-sm">
  <div id="main_flexslider" class="flexslider">
    <ul class="slides list-unstyled">
      <li class="item" style="background-image: url({$sensor.forum_container_node.data_map.image.content.original.full_path|ezroot(no)})">
        <div class="container">
          <div class="carousel-caption">
            <h1>{attribute_view_gui attribute=$sensor.forum_container_node.data_map.title}</h1>
            <p class="lead skincolored">{attribute_view_gui attribute=$sensor.forum_container_node.data_map.subtitle}</p>
        </div>
      </li>
    </ul>
  </div>
</section>
{/if}