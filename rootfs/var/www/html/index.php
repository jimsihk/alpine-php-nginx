<?php
ini_set('display_errors', '1');
error_reporting(E_ALL);

// Below for testing iconv issue of alpine
$text = "This is the Euro symbol '€'.";
$result = iconv("UTF-8", "ASCII//TRANSLIT//IGNORE", $text);

// Output PHP version if all test passed
if ($result === true) {
    phpinfo();
}
