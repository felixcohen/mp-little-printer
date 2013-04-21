DataMapper.setup(:default, 'mysql://root:root@localhost/manhattans')

class Cocktail
  include DataMapper::Resource

  property :id, Serial
  property :name, String
  property :content, Text
  property :instructions, Text

  has n, :cocktail_ingredients
  has n, :ingredients, :through => :cocktail_ingredients
end

class Ingredient
  include DataMapper::Resource

  property :id, Serial
  property :name, String
  property :description, Text

  has n, :cocktail_ingredients
  has n, :cocktails, :through => :cocktail_ingredients

end

class CocktailIngredient
  include DataMapper::Resource

  property :id, Serial
  property :created_at, DateTime
  property :amount, Integer

  belongs_to :ingredient
  belongs_to :cocktail
end 


DataMapper.finalize.auto_upgrade!