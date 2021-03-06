#Использовать yadisk
#Использовать logos
#Использовать cmdline

Перем мЛог;

Процедура ВыполнитьРаботу()

	Если АргументыКоманднойСтроки.Количество() = 0 Тогда
		ВывестиСправку();
		ЗавершитьРаботу(0);
	КонецЕсли;

	мЛог = Логирование.ПолучитьЛог("oscript.yadisk.uploader");
	мЛог.УстановитьУровень(УровниЛога.Предупреждение);

    мЛог.ДобавитьСпособВывода(ПолучитьФайлЖурнала());

	ПарсерКомСтроки = Новый ПарсерАргументовКоманднойСтроки();
	ПарсерКомСтроки.ДобавитьПараметрФлаг("-publish", "сделать файл публичным и вывести в консоль публичную ссылку на файл");
	ПарсерКомСтроки.ДобавитьПараметрФлаг("-debug", "выводить отладочную информацию");
	ПарсерКомСтроки.ДобавитьПараметр("ПутьКФайлу", "путь к файлу на вашем компьютере, который вы хотите загрузить на Яндекс.Диск");
	Параметры = ПарсерКомСтроки.Разобрать(АргументыКоманднойСтроки);

	Если ПустаяСтрока(Параметры["ПутьКФайлу"]) Тогда
		Сообщить("Не указан путь к файлу!");
		ВывестиСправку();
		ЗавершитьРаботуСкрипта(1);
	КонецЕсли;

	ЗагружаемыйФайл = Новый Файл(Параметры["ПутьКФайлу"]);
	Если НЕ ЗагружаемыйФайл.Существует() Тогда
		мЛог.Ошибка(СтрШаблон("Файл %1 не найден!", Параметры["ПутьКФайлу"]));
		Сообщить(СтрШаблон("Файл %1 не найден!", Параметры["ПутьКФайлу"]));
		ЗавершитьРаботуСкрипта(1);
	КонецЕсли;

	Если Параметры["-debug"] Тогда
		мЛог.УстановитьУровень(УровниЛога.Отладка);
	КонецЕсли;

	ЗагрузитьФайлНаЯндексДиск(Параметры["ПутьКФайлу"], Параметры["-publish"]);

	мЛог.Закрыть();

КонецПроцедуры

Процедура ВывестиСправку()
	Сообщить(
		"Использование: oscript yadisk-uploader.os [-publish|-p] [-debug|-d] path/to/local/file
		|	path/to/local/file 	путь к файлу на вашем компьютере, который вы хотите загрузить на Яндекс.Диск
		|	-publish, -p 	сделать файл публичным и вывести в консоль публичную ссылку на файл
		|	-debug, -d 		вывести отладочную информацию"
	);
КонецПроцедуры

Процедура ЗагрузитьФайлНаЯндексДиск(ПутьКФайлу, Публиковать)

	ЯндексДиск = Новый ЯндексДиск;
	ЯндексДиск.УстановитьРежимОтладки(мЛог.Уровень() = УровниЛога.Отладка);

	ИсходныйФайл = Новый Файл(ПутьКФайлу);
	ПутьКФайлуНаДиске = "app:/" + ИсходныйФайл.Имя; // Загружаем в корень папки приложения.

	ЯндексДиск.УстановитьТокенАвторизации(ПолучитьТокенАвторизации());
	ЯндексДиск.ЗагрузитьНаДиск(ПутьКФайлу, ПутьКФайлуНаДиске);

	Если Публиковать Тогда
		ПубличныйUrl = ЯндексДиск.Опубликовать(ПутьКФайлуНаДиске);
		Сообщить(ПубличныйUrl);
	КонецЕсли;

КонецПроцедуры

Функция ПолучитьПеременнуюСреды(ИмяПеременной)
    СистемнаяИнформация = Новый СистемнаяИнформация;
    Возврат СистемнаяИнформация.ПолучитьПеременнуюСреды(ИмяПеременной);
КонецФункции

Функция ПолучитьТокенАвторизации()
	ПутьКФайлуСТокеном = ОбъединитьПути(Новый Файл(ТекущийСценарий().Источник).Путь, "oauth_token.txt");
	Если (Новый Файл(ПутьКФайлуСТокеном)).Существует() Тогда
		ЧтениеТекста = Новый ЧтениеТекста(ПутьКФайлуСТокеном);
		Токен = СокрЛП(ЧтениеТекста.Прочитать());
		ЧтениеТекста.Закрыть();
		мЛог.Отладка("Токен получен из файла " + ПутьКФайлуСТокеном);
	КонецЕсли;
	Если ПустаяСтрока(Токен) Тогда
		мЛог.Предупреждение("Не найден токен авторизации!");
		мЛог.Информация("Токен авторизации необходимо расположить в файле oauth_token.txt в папке скрипта yadisk-uploader.os");
		мЛог.Отладка("Не найден токен авторизации: " + ПутьКФайлуСТокеном);
		ЗавершитьРаботуСкрипта(1);
	КонецЕсли;
	Возврат Токен;
КонецФункции

Процедура ЗавершитьРаботуСкрипта(КодВозврата)
	мЛог.Закрыть();
	ЗавершитьРаботу(КодВозврата);
КонецПроцедуры

Функция ПолучитьФайлЖурнала()

	ПутьКЛогу = ОбъединитьПути(ТекущийСценарий().Каталог, "uploader.log");

	ФайлЖурнала = Новый ВыводЛогаВФайл;
	ФайлЖурнала.ОткрытьФайл(ПутьКЛогу);
	
	Возврат ФайлЖурнала;

КонецФункции

///////////////////////////////////////////////////////////////////////////////

ВыполнитьРаботу();