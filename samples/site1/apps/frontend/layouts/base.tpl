<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8"/>
<title>{% block title %}{% endblock %}</title>
{% require_960gs24 full %}
{% styles %}
{% top_scripts %}
</head>
<body>
{% block body %}{% endblock %}
{% scripts %}
</body>
</html>