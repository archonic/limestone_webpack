# frozen_string_literal: false

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# This will create plans in your Stripe account. Check that you don't have duplicates
# or comment out/remove if you want to manage plans manually.
# https://stripe.com/docs/api/products
if !Rails.env.test?
  products = Product.create(
    [
      { name: "Basic" },
      { name: "Pro" }
    ]
  )
  products.each do |product|
    StripeProductService.new(product).create
  end
  puts "CREATED PRODUCTS #{products.map(&:name).join(', ')}."

  plans = Plan.create(
    [
      {
        product_id: products.first.id,
        name: "Basic Monthly",
        amount: 900,
        interval: "month",
        currency: "USD"
      },
      {
        product_id: products.first.id,
        name: "Basic Annual",
        amount: 9900,
        interval: "year",
        currency: "USD"
      },
      {
        product_id: products.second.id,
        name: "Pro Monthly",
        amount: 1500,
        interval: "month",
        currency: "USD"
      },
      {
        product_id: products.second.id,
        name: "Pro Annual",
        amount: 16500,
        interval: "year",
        currency: "USD"
      }
    ]
  )
  plans.each do |plan|
    StripePlanService.new(plan).create
  end
  puts "CREATED PLANS #{plans.map(&:name).join(', ')}."

  admin_user = CreateAdminService.call
  puts "CREATED ADMIN USER: #{admin_user.email}."
else
  puts "NOTE Skipped product/plan and admin creation because we're in the test ENV. Create your test product/plan and set their IDs in your .env file to have testing pass."
end
