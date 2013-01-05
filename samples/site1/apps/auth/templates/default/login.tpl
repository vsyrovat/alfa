Login form:
<form action="{% href login %}" method="post">
    <input type="hidden" name="return_to" value="{{return_to}}">
    <input type="text" name="login"/>
    <input type="password" name="password"/>
    <input type="submit"/>
</form>
<div><a href="{% href_to registration %}">Register</a></div>

{{ post }}