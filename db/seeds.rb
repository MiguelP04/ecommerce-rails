Faker::Config.locale = 'es'

puts "Limpiando base de datos..."
Product.destroy_all
Category.destroy_all

puts "Creando categorias..."

categorias = ["Electrónica", "Hogar", "Deportes",       "Belleza", "Libros"].map do|nombre| 
    Category.create!(name: nombre, slug: nombre.parameterize)
end

puts "Creando 50 productos aleatorios..."
50.times do
    nombre_producto = Faker::Commerce.product_name
    Product.create!(
        category: categorias.sample,
        title: nombre_producto,
        description: Faker::Lorem.paragraph(sentence_count: 3),
        price: Faker::Commerce.price(range: 10..2000.0),
        stock: rand(1..100),
        active: true,
        slug: "#{nombre_producto.parameterize}-#{rand(1000.9999)}",
        metadata: {
            brand: Faker::Company.name,
            material: Faker::Commerce.material
        }
    )
end

puts "Seeds terminados: Tenemos #{Category.count} categorías y #{Product.count} productos reales (Gracias a Faker)"

    

# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
