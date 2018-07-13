#Использовать json
#Использовать semver
#Использовать fs

Перем Лог;
Перем ТаблицаПакетов;
Перем КаталогХранения;

Процедура Инициализировать() Экспорт

	ТаблицаПакетов = Новый ТаблицаЗначений;
	ТаблицаПакетов.Колонки.Добавить("Название");
	ТаблицаПакетов.Колонки.Добавить("Описание");
	ТаблицаПакетов.Колонки.Добавить("Автор");
	ТаблицаПакетов.Колонки.Добавить("КлючевыеСлова");
	ТаблицаПакетов.Колонки.Добавить("ПутьХранения");
	ТаблицаПакетов.Колонки.Добавить("Версии");
	ТаблицаПакетов.Колонки.Добавить("АктуальнаяВерсия");
	ТаблицаПакетов.Колонки.Добавить("АдресРепозитория");

	Лог = ОбщегоНазначения.ПолучитьЛог();
	ОбновитьКешПакетов();
	
КонецПроцедуры

Процедура ЗагрузитьБазуПакетовИзФайловойСистемы()

	КаталогСтабильных = ОбъединитьПути(КаталогХраненияПакетов(),"download");
	
	Лог.Информация("Начинаю загрузку данных по существующим пакетам");

	КаталогиПакетов = НайтиФайлы(КаталогСтабильных, ПолучитьМаскуВсеФайлы());
	Для Каждого КаталогПакета Из КаталогиПакетов Цикл
		Если Не КаталогПакета.ЭтоКаталог() Тогда
			Продолжить;
		КонецЕсли;

		ОбработатьКаталогПакета(КаталогПакета);

	КонецЦикла;


КонецПроцедуры

Процедура ОбработатьКаталогПакета(Знач КаталогПакета)
	Лог.Информация("Загружаю данные по пакету %1", КаталогПакета.Имя);

	ФайлКешаДанных = Новый Файл(ОбъединитьПути(КаталогПакета.ПолноеИмя, "meta.json"));
	Если ФайлКешаДанных.Существует() Тогда
		ИнфоПакета = ПрочитатьКеш(ФайлКешаДанных.ПолноеИмя);
		Если КешАктуален(ИнфоПакета, КаталогПакета) Тогда
			Лог.Отладка("Кеш актуален");
			СтрПакета = ТаблицаПакетов.Добавить();
			ЗаполнитьЗначенияСвойств(СтрПакета, ИнфоПакета);
			Возврат;
		КонецЕсли;
	КонецЕсли;

	СтрокаПакета = ТаблицаПакетов.Добавить();
	СтрокаПакета.Название     = КаталогПакета.Имя;
	СтрокаПакета.ПутьХранения = КаталогПакета.ПолноеИмя;
	СтрокаПакета.Версии       = СобратьДанныеВерсий(СтрокаПакета.ПутьХранения);
	Если СтрокаПакета.Версии.Количество() Тогда
		СтрокаПакета.АктуальнаяВерсия = СтрокаПакета.Версии[0]; // отсортировано от новых к старым
	КонецЕсли;
	
	Мета = МетаданныеПакета(ОбъединитьПути(КаталогПакета.ПолноеИмя,КаталогПакета.Имя + ".ospx"));
	Мета.Свойство("Описание",СтрокаПакета.Описание);
	Мета.Свойство("Автор"   ,СтрокаПакета.Автор);
	Лог.Информация("Пакет обработан");

КонецПроцедуры

Функция СобратьДанныеВерсий(Знач КаталогХранения)
	Лог.Отладка("Собираю файлы версий");
	ФайлыВерсий = НайтиФайлы(КаталогХранения, "*.ospx");
	МассивВерсий = Новый Массив;
	Для Каждого ФайлВерсии Из ФайлыВерсий Цикл

		ВерсияФайла = ВыделитьВерсию(ФайлВерсии.ИмяБезРасширения);
		Если ВерсияФайла = Неопределено Тогда
			// это файл "последней" версии. Пока непонятно что с ним делать
			// наверное можно что-то придумать полезное.
			Продолжить;
		КонецЕсли;

		Лог.Отладка("Найдена версия %1", ВерсияФайла);
		Версия = Версии.ВерсияИзСтроки(ВерсияФайла);
		МассивВерсий.Добавить(Версия);
		
	КонецЦикла;

	СортироватьВерсии(МассивВерсий);

	Возврат МассивВерсий;
КонецФункции

Функция ВыделитьВерсию(Знач ИмяФайла)
	
	Лог.Отладка("Применяю регулярку к %1", ИмяФайла);
	РЕ = Новый РегулярноеВыражение("-(\d{1,3}\.(\d{1,3}\.)*\d{1,3})$");
	Совпадения = РЕ.НайтиСовпадения(ИмяФайла);
	Если Совпадения.Количество() = 0 Тогда
		Возврат Неопределено;
	КонецЕсли;

	Совпадение = Совпадения[0].Группы[1];
	Возврат Совпадение.Значение;

КонецФункции

Функция МетаданныеПакета(Знач ФайлПакета)
	ЧтениеПакета = Новый РаботаСФайламиПакетов;
	Возврат ЧтениеПакета.ПрочитатьМетаданныеПакета(ФайлПакета).Свойства();
КонецФункции

Процедура СортироватьВерсии(Знач МассивВерсий)

	Если МассивВерсий.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	// сортировка вставками. Украдена с википедии
	// но я принцип и так помнил, есличо

	Для i = 1 По МассивВерсий.Количество()-1 Цикл
		Тек = МассивВерсий[i];
		j = i;
		Пока j > 0 И МассивВерсий[j-1].Меньше(Тек) Цикл
			МассивВерсий[j] = МассивВерсий[j-1];
			j = j-1;
		КонецЦикла;
		МассивВерсий[j] = Тек;
	КонецЦикла;

	Лог.Отладка("Максимальная версия %1", МассивВерсий[0]);

КонецПроцедуры

Функция ПрочитатьКеш(Знач ПутьФайла)
	Лог.Отладка("Читаю кеш из файла %1", ПутьФайла);
	СтруктураДанных = ОбщегоНазначения.ПрочитатьJson(ПутьФайла,Истина);
	МассивВерсий = Новый Массив;
	Для Каждого СтрокаВерсии Из СтруктураДанных.Версии Цикл
		МассивВерсий.Добавить(Версии.ВерсияИзСтроки(СтрокаВерсии));
	КонецЦикла;
	СтруктураДанных.Версии = МассивВерсий;
	Если Не ПустаяСтрока(СтруктураДанных.АктуальнаяВерсия) Тогда
		СтруктураДанных.АктуальнаяВерсия = Версии.ВерсияИзСтроки(СтруктураДанных.АктуальнаяВерсия);
	Иначе
		СтруктураДанных.АктуальнаяВерсия = Неопределено;
	КонецЕсли;
	Возврат СтруктураДанных;
КонецФункции

Функция КешАктуален(Знач ИнфоПакета, Знач КаталогХранения)
	ВерсииВКаталоге = НайтиФайлы(КаталогХранения.ПолноеИмя, "*.ospx").Количество()-1;
	ВерсииВКеше = ИнфоПакета.Версии.Количество();
	Лог.Отладка("Версий в каталоге %3: %1
	|Версий в файле кеша: %2",ВерсииВКаталоге,ВерсииВКеше,КаталогХранения);

	Возврат ВерсииВКаталоге = ВерсииВКеше;
КонецФункции

Функция ПолучитьПакеты() Экспорт
	Возврат ТаблицаПакетов;
КонецФункции

Процедура ОбновитьКешПакетов() Экспорт

	ЗагрузитьБазуПакетовИзФайловойСистемы();

	Скачиватель = Новый ОбновлятельОписаний();
	Скачиватель.Инициализация(ОбъединитьПути(КаталогХраненияПакетов(),"download"));
	Скачиватель.СоздатьФайлыОписаний();
	Скачиватель.ОбновитьКешПакетов();

КонецПроцедуры

Функция КаталогХраненияПакетов() Экспорт
	Возврат КаталогХранения;
КонецФункции

КаталогХраненияСреда = ПолучитьПеременнуюСреды("OSHUB_BINARY_ROOT");
Каталог = Новый Файл(КаталогХраненияСреда);
КаталогХранения = Каталог.ПолноеИмя;