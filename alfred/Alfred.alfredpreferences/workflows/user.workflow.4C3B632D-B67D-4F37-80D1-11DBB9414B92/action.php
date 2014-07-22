<?php

require 'workflow.php';

Workflow::init();

$query = trim($argv[1]);
$parts = explode(' ', $query);

switch ($parts[0]) {

    case '>':
        switch ($parts[1]) {
            case 'login':
                $password = exec('osascript <<END
tell application "Alfred 2"
  activate
  set alfredPath to (path to application "Alfred 2")
  set alfredIcon to path to resource "appicon.icns" in bundle (alfredPath as alias)
  display dialog "Password for \"' . escapeshellcmd($parts[2]) . '\":" with title "GitHub Login" buttons {"OK"} default button "OK" default answer "" with icon alfredIcon with hidden answer
  set answer to text returned of result
end tell
END');

                $content = Workflow::request('https://github.com/session', $status, $etag, true, null, array('authenticity_token' => Workflow::getToken(), 'login' => $parts[2], 'password' => $password));
                if ($status === 200 && false === strpos($content, '<title>Sign in · GitHub</title>')) {
                    $authCode = exec('osascript <<END
tell application "Alfred 2"
  activate
  set alfredPath to (path to application "Alfred 2")
  set alfredIcon to path to resource "appicon.icns" in bundle (alfredPath as alias)
  display dialog "Authentication code:" with title "GitHub two-factor authentication" buttons {"OK"} default button "OK" default answer "" with icon alfredIcon with hidden answer
  set answer to text returned of result
end tell
END');
                    $content = Workflow::request('https://github.com/sessions/two_factor', $status, $etag2, true, null, array('authenticity_token' => Workflow::getToken($content), 'otp' => $authCode));
                }
                if ($status === 302) {
                    Workflow::request('https://github.com/');
                    echo 'Successfully logged in';
                    Workflow::deleteCache();
                    Workflow::setConfig('user', $parts[2]);
                } else {
                    echo 'Login failed';
                }
                break;

            case 'logout':
                Workflow::deleteCookies();
                Workflow::deleteCache();
                echo 'Successfully logged out';
                break;

            case 'delete-cache':
                Workflow::deleteCache();
                echo 'Successfully deleted cache';
                break;

            case 'refresh-cache':
                Workflow::requestCache($parts[2], 0, false);
                break;

            case 'activate-autoupdate':
                Workflow::setConfig('autoupdate', 1);
                echo 'Activated auto updating';
                break;

            case 'deactivate-autoupdate':
                Workflow::setConfig('autoupdate', 0);
                echo 'Deactivated auto updating';
                break;

            case 'update':
                $c = Workflow::request('http://gh01.de/alfred/github/github.alfredworkflow', $status);
                if ($status != 200) {
                    echo 'Update failed';
                    exit;
                }
                $zip = __DIR__ . '/workflow.zip';
                file_put_contents($zip, $c);
                $phar = new PharData($zip);
                foreach ($phar as $path => $file) {
                    copy($path, __DIR__ . '/' . $file->getFilename());
                }
                unlink($zip);
                Workflow::deleteCache();
                echo 'Successfully updated the GitHub Workflow';
                break;
        }
        break;

    default:
        if ('.git' == substr($query, -4)) {
            $query = 'github-mac://openRepo/' . substr($query, 0, -4);
        }
        exec('osascript -e "open location \"' . $query . '\""');

}
