<?php
phpinfo();

ini_set('display_errors', '1');
error_reporting(E_ALL);

// Below for testing iconv issue of alpine
$text = "This is the Euro symbol '€'.";
$result = iconv("UTF-8", "ASCII//TRANSLIT//IGNORE", $text);
if ($result === false) {
    print_r("iconv test failed: " . error_get_last()['message'] . "\n");
} else {
    print_r("iconv test passed: $result\n");
}
