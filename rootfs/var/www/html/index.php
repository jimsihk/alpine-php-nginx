<?php
phpinfo();

//ini_set('display_errors', '1');
//error_reporting(E_ALL);

// Below for testing iconv issue of alpine
$text = "This is the Euro symbol '€'.";
$result = iconv("UTF-8", "ASCII//TRANSLIT//IGNORE", $text);
if ($result === false) {
    echo "iconv failed: " . error_get_last()['message'] . "\n";
} else {
    echo "iconv succeeded: $result\n";
}
