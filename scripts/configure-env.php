<?php
// Compose is authoritative for local infrastructure settings.
$path = '/var/www/html/.env';
$text = file_get_contents($path);
foreach (['APP_URL','DB_CONNECTION','DB_HOST','DB_PORT','DB_DATABASE','DB_USERNAME','DB_PASSWORD','SESSION_DRIVER','CACHE_STORE','QUEUE_CONNECTION'] as $key) {
    $value = getenv($key);
    if ($value === false) continue;
    $line = $key . '=' . '"' . str_replace(['\\', '"', '$', "\n", "\r"], ['\\\\', '\"', '\$', '\n', '\r'], $value) . '"';
    $pattern = '/^' . preg_quote($key, '/') . '=.*$/m';
    $text = preg_match($pattern, $text) ? preg_replace_callback($pattern, fn () => $line, $text) : $text . "\n" . $line . "\n";
}
file_put_contents($path, $text);
