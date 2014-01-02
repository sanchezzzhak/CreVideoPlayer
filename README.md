CreVideoPlayer
==============

OpenSource VideoPlayer by create http://creatida.kz<br>
Support format `raw video`, `stream rtmp`, `youtube`, `vk ???` 
### Config FlashVars params: 
`file` true/false путь до файла или XML, который содержит плейлист. <br>
`tvmode`  true/false использовать тв режим , значение по умолчанию = false, также плейлист должен иметь специальный формат в XML
```XML
<?xml version='1.0' encoding='UTF-8'?>
<VideoPlayer>
<server><datetime hour="03" minute="11" second="03" year="2013" month="11" day="26"/></server>
<videos>
<video url="http://www.youtube.com/watch?v=testKey" name="Вечерние новости 1" time="2:30" date="2013-11-26"/>
<video url="http://www.youtube.com/watch?v=testKey" name="Вечерние новости 2" time="03:04" date="2013-11-26"/>
</videos>
</VideoPlayer>
```
`autoplay` true/false использовать автоплей, значение по умолчанию = false<br>


