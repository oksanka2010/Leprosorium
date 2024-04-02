require 'rubygems'
require 'sinatra'
require 'sqlite3'

def init_db
	@db = SQLite3::Database.new 'leprosorium.db'
	@db.results_as_hash = true
end

# before вызывается каждый раз при перезагрузке
# любой страницы

before do	
	# инициализация БД
	init_db
end

# configure вызывается каждый раз при конфигурации приложения:
# когда изменился код программы И перезагрузилась страница

configure do
	# инициализация БД
	init_db

	# создает таблицу если таблица не существует
	@db.execute 'CREATE TABLE IF NOT EXISTS "Posts"
	(
		"id" INTEGER PRIMARY KEY AUTOINCREMENT,
		"created_date" TEXT,
		"content" TEXT
	)'
end

get '/' do
	# выбираем список постов из БД 
	@results = @db.execute 'SELECT * FROM Posts ORDER BY id DESC'

	erb :index			
end

# обработчик get-запроса
# (браузер получает страницу ссервера)

get '/new' do
	erb :new
  end

# обработчик post-запроса
# (браузер отправляет данные на сервер)

post '/new' do
	# получаем переменную из post-запроса
	content = params[:content]

	if content.length <= 0
		@error = 'Type post text'
		return erb :new
	end

	# сохранение данных в БД
	@db.execute 'INSERT INTO Posts (content, created_date) values (?, datetime())', [content] 

	# перенаправление на главную страницу
	redirect to '/'
end

# вывод информации о посте

get '/post/:post_id' do
	post_id = params[:post_id]

	#выбираем пост по id
	results = @db.execute 'SELECT * FROM Posts WHERE id = ?', [post_id]
	@row = results[0]

	erb :post 
end