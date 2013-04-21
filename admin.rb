get '/admin/ingredient_index' do
  @ingredients = Ingredient.all
  haml :'ingredient_index'
end

get '/admin/create_ingredient' do
  haml :'create_ingredient'
end

get '/admin/create_cocktail' do 
  haml :'create_cocktail'
end

get '/admin/cocktail/:id/edit' do |id|
  @article = Cocktail.get!(id)
  haml :'edit_cocktail'
end

get '/admin/ingredient/:id/edit' do |id|
  @article = Ingredient.get!(id)
  haml :'edit_ingredient'
end

post '/cocktails' do
  article = Article.new(params[:article])
  
  if article.save
    redirect '/articles'
  else
    redirect '/articles/new'
  end
end

put '/cocktails' do |id|
  article = Article.get!(id)
  success = article.update!(params[:article])
  
  if success
    redirect "/articles/#{id}"
  else
    redirect "/articles/#{id}/edit"
  end
end

post '/ingredients' do
  ingredient = Ingredient.new(params[:ingredient])
  
  if ingredient.save
    redirect '/admin/ingredient_index'
  else
    redirect '/ingredient/new'
  end
end

put '/ingredients' do |id|
  article = Article.get!(id)
  success = article.update!(params[:article])
  
  if success
    redirect "/articles/#{id}"
  else
    redirect "/articles/#{id}/edit"
  end
end
