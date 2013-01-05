<!DOCTYPE html>
<html>
<head>
<title>{% block title %}{% endblock %}</title>
{% require_960gs24 full %}
{% styles %}
{% top_scripts %}
</head>
<body>
{% block body %}{{ body|raw }}{% endblock %}
{% scripts %}
</body>
</html>
