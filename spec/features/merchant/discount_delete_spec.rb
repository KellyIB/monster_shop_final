require 'rails_helper'

RSpec.describe 'Discount Deletion' do
  describe 'As an employee of a merchant' do
    before :each do
      @merchant_1 = Merchant.create!(name: 'Megans Marmalades', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218)
      @merchant_2 = Merchant.create!(name: 'Brians Bagels', address: '125 Main St', city: 'Denver', state: 'CO', zip: 80218)
      @m_user = @merchant_1.users.create(name: 'Megan', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218, email: 'megan@example.com', password: 'securepassword')
      @ogre = @merchant_1.items.create!(name: 'Ogre', description: "I'm an Ogre!", price: 20.25, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 80 )
      @giant = @merchant_1.items.create!(name: 'Giant', description: "I'm a Giant!", price: 50, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 80 )
      @hippo = @merchant_2.items.create!(name: 'Hippo', description: "I'm a Hippo!", price: 50, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 80 )
      @order_1 = @m_user.orders.create!(status: "pending")
      @order_2 = @m_user.orders.create!(status: "pending")
      @order_3 = @m_user.orders.create!(status: "pending")
      @discount1 = @merchant_1.discounts.create!(percent_off: 5, quantity_threshold: 20, status: "active")
      @discount2 = @merchant_1.discounts.create!(percent_off: 10, quantity_threshold: 40, status: "active")
      @discount3 = @merchant_1.discounts.create!(percent_off: 15, quantity_threshold: 50, status: "inactive")
      @order_item_1 = @order_1.order_items.create!(item: @hippo, price: @hippo.price, quantity: 2, fulfilled: false)
      @order_item_2 = @order_2.order_items.create!(item: @hippo, price: @hippo.price, quantity: 2, fulfilled: true)
      @order_item_3 = @order_2.order_items.create!(item: @ogre, price: @ogre.price, quantity: 2, fulfilled: false)
      @order_item_4 = @order_3.order_items.create!(item: @giant, price: @giant.price, quantity: 2, fulfilled: false)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@m_user)
    end

    it "can delete the discount from the index page" do
      visit "/merchant/discounts"

       within "#discount-#{@discount1.id}" do
        expect(page).to have_content(@discount1.percent_off)
        expect(page).to have_content(@discount1.quantity_threshold)
        expect(page).to have_content(@discount1.status)
        expect(page).to have_link(@discount1.id)
        expect(page).to have_button("Delete Discount")
      end

      within "#discount-#{@discount2.id}" do
        expect(page).to have_content(@discount2.percent_off)
        expect(page).to have_content(@discount2.quantity_threshold)
        expect(page).to have_content(@discount2.status)
        expect(page).to have_link(@discount2.id)
        click_button "Delete Discount"
      end
      @m_user.reload
      expect(current_path).to eq("/merchant/discounts")

      within "#discount-#{@discount3.id}" do
        expect(page).to have_content(@discount3.percent_off)
        expect(page).to have_content(@discount3.quantity_threshold)
        expect(page).to have_content(@discount3.status)
        expect(page).to have_link(@discount3.id)
        click_button "Delete Discount"
      end
      @m_user.reload
      expect(current_path).to eq("/merchant/discounts")

      within "#discount-#{@discount1.id}" do
        expect(page).to have_content(@discount1.percent_off)
        expect(page).to have_content(@discount1.quantity_threshold)
        expect(page).to have_content(@discount1.status)
        expect(page).to have_link(@discount1.id)
        expect(page).to have_button("Delete Discount")
      end

      expect(page).to_not have_link(@discount3.id)
      expect(page).to_not have_link(@discount2.id)
    end

    it "can't delete discount if it has been used" do
      discount4 = @merchant_1.discounts.create!(percent_off: 20, quantity_threshold: 30, status: "active")
      order_5 = @m_user.orders.create!(status: "pending")
      order_5.order_items.create!(item: @ogre, price: @ogre.price, quantity: 30, fulfilled: false, discount_id: discount4.id)
      order_5.order_items.create!(item: @giant, price: @giant.price, quantity: 20, fulfilled: true, discount_id: @discount1.id)

      visit "/merchant/discounts"

      within "#discount-#{@discount1.id}" do
        expect(page).to have_content(@discount1.percent_off)
        expect(page).to have_content(@discount1.quantity_threshold)
        expect(page).to have_content(@discount1.status)
        expect(page).to have_link(@discount1.id)
        expect(page).to_not have_button("Delete Discount")
      end

      within "#discount-#{@discount2.id}" do
        expect(page).to have_content(@discount2.percent_off)
        expect(page).to have_content(@discount2.quantity_threshold)
        expect(page).to have_content(@discount2.status)
        expect(page).to have_link(@discount2.id)
        expect(page).to have_button("Delete Discount")
      end

      within "#discount-#{@discount3.id}" do
        expect(page).to have_content(@discount3.percent_off)
        expect(page).to have_content(@discount3.quantity_threshold)
        expect(page).to have_content(@discount3.status)
        expect(page).to have_link(@discount3.id)
        expect(page).to have_button("Delete Discount")
      end

      within "#discount-#{discount4.id}" do
        expect(page).to have_content(discount4.percent_off)
        expect(page).to have_content(discount4.quantity_threshold)
        expect(page).to have_content(discount4.status)
        expect(page).to have_link(discount4.id)
        expect(page).to_not have_button("Delete Discount")
      end
    end
  end
end
