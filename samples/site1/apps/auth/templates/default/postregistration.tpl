{% if was_registration %}
  {% if is_success %}
    Регистрация Ок ({{ message }})
  {% else %}
    Ошибка регистрации ({{ message }})
    <a href="{% href registration %}">Try again</a> | <a href="{% href @frontend %}">Go to index</a>
  {% endif %}
{% endif %}
