{% require_jquery %}

{{ name }}<br>
{{ items }}
{% for item in items %}
{#{ item }#}
{% endfor %}

<br>
String from template / Строка из шаблона
<div> link_to_admin: <a href="{{link_to_admin}}">{{link_to_admin}}</a> </div>
