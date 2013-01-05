<h1>Registration</h1>
<form action="{% href_to registration %}" method="post">
    <table>
        <tr><td>login:</td><td><input type="text" name="login"></td></tr>
        <tr><td>password:</td><td><input type="text" name="password"></td></tr>
        <tr><td colspan="2"><input type="submit"></td></tr>
    </table>
</form>