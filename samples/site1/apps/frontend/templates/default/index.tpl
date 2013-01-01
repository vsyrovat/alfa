{% require_jquery %}

{{ name }}<br>
{{ items }}
{% for item in items %}
{#{ item }#}
{% endfor %}

<br>
String from template / Строка из шаблона
