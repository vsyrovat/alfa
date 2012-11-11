<!DOCTYPE html>
<html>
<head>
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