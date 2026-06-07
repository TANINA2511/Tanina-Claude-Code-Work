[app]
title = EcoEcos de Jamaica
package.name = ecoecosjamaica
package.domain = org.tanina

source.dir = .
source.include_exts = py,png,jpg,kv,atlas,mp3

version = 0.1
requirements = python3,kivy,kivymd,pyjnius,sqlite3

orientation = portrait
fullscreen = 0

android.permissions = ACCESS_FINE_LOCATION,ACCESS_COARSE_LOCATION
android.api = 33
android.minapi = 21
android.archs = arm64-v8a, armeabi-v7a

[buildozer]
log_level = 2
warn_on_root = 1
