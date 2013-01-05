{% require_jquery %}

{{ name }}<br>
{{ items }}
{% for item in items %}
    {{ item }}
{% endfor %}

<br>
String from template / Строка из шаблона
<div> link_to_admin: <a href="{{link_to_admin}}">{{link_to_admin}}</a> </div>
<div>link to foo: <a href="{{link_to_foo}}">{{link_to_foo}}</a></div>
<div>link to admin foo: <a href="{{link_to_admin_foo}}">{{link_to_admin_foo}}</a></div>
<div>Ruty version: {{ ruty.version }}</div>