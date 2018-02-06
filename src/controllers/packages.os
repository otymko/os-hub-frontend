#Использовать markdown

Функция Index() Экспорт
	Ответ = Новый РезультатДействияСтраница();
	Ответ.ДанныеПредставления = Новый СловарьДанныхПредставления();
	Ответ.ДанныеПредставления["Selected"] = 2;
	
	Пакеты = ПереченьПакетов.ПолучитьПакеты();
	Пакеты.Сортировать("id");
	Если Пакеты <> Неопределено Тогда
		Ответ.ДанныеПредставления.Модель = Пакеты;
	КонецЕсли;

	Возврат Ответ;
КонецФункции

Функция Details() Экспорт
	
	Ответ = Новый РезультатДействияСтраница();
	Ответ.ДанныеПредставления = Новый СловарьДанныхПредставления;
	
	IDПакета = ЗначенияМаршрута["id"];
	Пакеты = ПереченьПакетов.ПолучитьПакеты();
	ДанныеПакета = Пакеты.Найти(IDПакета, "id");

	Модель = Новый Структура;
	Модель.Вставить("DescriptionPage", "<p>Raw html-rendered README should be here</p>");
	Модель.Вставить("PackageData", ДанныеПакета);

	Ответ.ДанныеПредставления.Модель = Модель;
	Возврат Ответ;

КонецФункции