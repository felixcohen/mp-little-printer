get '/admin/ingredient_index' do
  @ingredients = Ingredient.all
  haml :'ingredient_index'
end

get '/admin/cocktail_index' do
  @cocktails = Cocktail.all
  haml :'cocktail_index'
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
  @ingredient = Ingredient.get!(id)
  haml :'edit_ingredient'
end

post '/cocktails' do
  cocktail = Cocktail.new(params[:cocktail])
  
  if cocktail.save
    redirect '/admin/cocktail_index'
  else
    redirect '/admin/create_cocktail'
  end
end

put '/cocktails/:id' do |id|
  Cocktail = Cocktail.get!(id)
  success = article.update!(params[:article])
  
  if success
    redirect "/admin/cocktail_index"
  else
    redirect "/articles/#{id}/edit"
  end
end

put '/ingredients/:id' do |id|
  ingredient = Ingredient.get!(id)
  success = ingredient.update!(params[:ingredient])
  
  if success
    redirect "/admin/ingredient_index"
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