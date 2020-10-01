# LogStash Input Plugin for 1C Application Logs

* плагин для чтения с помощью LogStash журнала регистрации в формате sqlite для  [Платформы 1C:Предприятия](http://1c.ru) 

## Инсталяция

Вам понадобится

* исталировать logstash
* скачать плагин со страницы релизов [текущий релиз 0.1.4](https://github.com/silverbulleters/logstash-vanessa-sqlitelogs/releases)
* запустить команду в консоли `logstash-plugin install /srv/logstash-input-sqliteonec-0.1.4.gem`

## Настройка

* создайте ваш конфигурационный файл с секциями `input`, `filter` и `output`

примерная секция `input` выглядит так

```
input {

    sqliteonec {
		type => "1CLog"
		path_since => "IncrementalInputTable" # где хранить время последней синхронизированной записи
		onec_base_name => "MyVanessaERP" # человекочитаемое имя базы для отображения
		onec_base_guid => "9c1205e0-595b-4edd-9f70-6dda09b6f888" # GUID базы (обычно берется из файла 1CV8Clst.lst)
		onec_server_reg_path => "C:\srvinfo\reg_1541" # путь к каталогу хранения журналов на сервере
    }

}
```

* запустите `logstash -f your-config-file.conf` и если вы откроете рабочий стол kibana - вы увидите свои журналы регистрации

![simple logs](./simple-discover.png)

## Совместная доработка

* установите JDK
* установите jruby
* `git clone` для этого репозитория
  * `git remote add myfork` для Вашего форка
* запустите `gem install bunder && bundle install
* напишите проверки с помощью RSspec (или cucumber)
* прочитайте [этот документ](https://www.elastic.co/guide/en/logstash/5.0/_how_to_write_a_logstash_input_plugin.html#_how_to_write_a_logstash_input_plugin)
* улучшите плагин вашим кодом
* запустите `bundle exec rspec spec`
* запустите `bundle exec cucumber`
* используйте `docker-run50-uat.sh` для финальной проверки (или `docker-run50-uat.cmd` для Windows 10 с поддержкой docker и HyperV)
  * если обнаружили ошибку - запустите `docker-logstash-only` для отладки и исправления
* перейдите по адресу `http://localhost:5601` - вы увидите рабочий стол kibana c 2-мы журналами регистрации 1С от двух баз
* если всё хорошо и правильно - сделайте свой pull-request ;-). Будьте социальным !!!
