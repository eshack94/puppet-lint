---
layout: nomenu
usercards:
  -
    title: Checks
    icon: code
    path: /documentation/checks/
  -
    title: Control Comments
    icon: code
    path: /documentation/control_comments/
devcards:
  -
    title: Plugin Tutorial
    icon: code
    path: /documentation/developer/plugin_tutorial/
  -
    title: API Reference
    icon: code
    path: /documentation/api_reference/
  -
    title: Token Reference
    icon: code
    path: /documentation/token_reference/
---

{:.section-title}
## User Documentation
<div class="spacer">&nbsp;</div>
<div class="row">
{% for card in page.usercards %}
    <div class="col-md-4">
        <div class="promo-box text-center inner-space">
            <i class="md-icon dp36 box-icon">{{ card.icon }}</i>
            <h6 class="box-title">{{ card.title }}</h6>
            <p class="box-description">&nbsp;</p>
            <a class="link" href="{{ card.path }}"><span></span></a>
        </div>
    </div>
{% endfor %}
</div>

{:.section-title}
## Developer Documentation
<div class="spacer">&nbsp;</div>
<div class="row">
{% for card in page.devcards %}
    <div class="col-md-4">
        <div class="promo-box text-center inner-space">
            <i class="md-icon dp36 box-icon">{{ card.icon }}</i>
            <h6 class="box-title">{{ card.title }}</h6>
            <p class="box-description">&nbsp;</p>
            <a class="link" href="{{ card.path }}"><span></span></a>
        </div>
    </div>
{% endfor %}
</div>