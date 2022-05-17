## Задание
С помощью x64dbg, IDA Freeware или других дизассемблеров/отладчиков определить пароль, необходимый для получения сообщения "congrats you cracked the password" в прикреплённой программе (https://crackmes.one/crackme/5fe8258333c5d4264e590114)

## Пароль: password123

## Как взломать (GUIDE IN PROGRESS):
1. Качаем дебаггер IDA с [их официального гитхаба](https://github.com/AngelKitty/IDA7.0);

2. Запускаем;

3. Выбираем новый файл:<br>
![image](https://user-images.githubusercontent.com/84042050/168800558-afde2666-ac1e-41cd-be90-bd7711705239.png)

4. Выбираем `crackme.exe`;

5. Нажимаем "OK":<br>
![image](https://user-images.githubusercontent.com/84042050/168800796-23c4a10a-920d-427b-80e1-738bdcca4927.png)

6. Нажимаем "Yes":<br>
![image](https://user-images.githubusercontent.com/84042050/168800877-5ee2b647-daed-409a-ba30-3498cbabfd76.png)

7. Нажимаем ПКМ, "Text view":<br>
![image](https://user-images.githubusercontent.com/84042050/168804613-3356cce0-d649-4bff-97b8-e9a6c0e7db78.png)

8. Ставим точку останова перед вызовом `strcmp` на моменте, где в стек кладутся аргументы функции (первый - то, что мы ввели, второй - пароль):<br> 
![image](https://user-images.githubusercontent.com/84042050/168804809-b400632d-90e3-4709-9f67-8742ffe60585.png)

9. Запускаем приложение:<br>
![image](https://user-images.githubusercontent.com/84042050/168805271-39831080-fe24-45c3-a649-01c9917486c4.png)
![image](https://user-images.githubusercontent.com/84042050/168805415-587e61fb-f0c1-49fa-8f92-6b0e77cdce91.png)
Нас просят ввести пароль, который мы пока не знаем. Сейчас будем его узнавать.

10. Вводим что-нибудь и нажимаем Enter:
![image](https://user-images.githubusercontent.com/84042050/168805522-2689d211-c274-4529-b178-3bb91fde6969.png)
<!-- 
10. Нажимаем ПКМ, "Text view":<br>
![image](https://user-images.githubusercontent.com/84042050/168803279-0de1477e-1a04-4a22-be4a-84e56dcd6044.png)

11. 
![image](https://user-images.githubusercontent.com/84042050/168803468-8c1822c8-abda-479d-839f-887734ffe9fd.png)

12. -->




14.
![image](https://user-images.githubusercontent.com/84042050/168805575-89f52745-6982-41ff-8d1a-279c2918d235.png)

15.
![image](https://user-images.githubusercontent.com/84042050/168805725-2e3fc162-6422-488d-8376-474d3274c9ac.png)

16. Видим искомый пароль.
![image](https://user-images.githubusercontent.com/84042050/168805763-bbd40191-083b-417b-8649-e3aee89003dc.png)
Осталось только убедиться в том, что этот пароль подходит.

