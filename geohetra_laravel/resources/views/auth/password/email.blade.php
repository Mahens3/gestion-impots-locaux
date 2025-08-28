<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Réinitialisation de mot de passe</title>
</head>
<body>
    <h1>Réinitialisation de mot de passe</h1>
    <p>Bonjour,</p>
    <p>Vous avez demandé à réinitialiser votre mot de passe.</p>
    <p>Veuillez cliquer sur le lien ci-dessous pour réinitialiser votre mot de passe :</p>
    <a href="{{ $actionUrl }}">{{ $actionUrl }}</a>
    <p>Ce lien de réinitialisation de mot de passe expirera dans {{ $expires }} minutes.</p>
    <p>Si vous n'avez pas demandé à réinitialiser votre mot de passe, veuillez ignorer cet e-mail.</p>
    <p>Merci,</p>
    <p>L'équipe de {{ config('app.name') }}</p>
</body>
</html>
