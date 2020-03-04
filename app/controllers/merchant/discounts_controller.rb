class Merchant::DiscountsController < Merchant::BaseController

  def index
    @discounts = current_user.merchant.discounts
  end

  def show
    @discount = Discount.find(params[:discount_id])
  end

  def edit
    @discount = Discount.find(params[:discount_id])
  end

  def update

    if params.keys.include?("change_status")
      change_status
      redirect_to "/merchant/discounts/#{@discount.id}"
    else
      @discount = Discount.find(params[:discount_id])
      if (discount_params)[:percent_off].to_f > 100.0 || (discount_params)[:percent_off].to_f < 0.0
        flash[:failure] = "Percent off can't be greater than 100"
        redirect_to "/merchant/discounts/#{@discount.id}/edit"
      elsif @discount.update(discount_params)
        redirect_to "/merchant/discounts/#{@discount.id}"
      else
        generate_flash(@discount)
        redirect_to "/merchant/discounts/#{@discount.id}/edit"
      end
    end
  end

  def change_status
    @discount = Discount.find(params[:discount_id])
    if params[:change_status] == "active"
      @discount.update(status: "active")
    else
      @discount.update(status: "inactive")
    end
  end

  def new
  end

  def create
    merchant = current_user.merchant
    discount = merchant.discounts.new(discount_params)
    if (discount_params)[:percent_off].to_f > 100.0 || (discount_params)[:percent_off].to_f < 0.0
      flash[:failure] = "Percent off can't be greater than 100"
      redirect_to "/merchant/discounts/new"
    elsif discount.save
      flash[:success] = "Discount Was Created!"
      redirect_to "/merchant/discounts"
    else
      generate_flash(discount)
      redirect_to "/merchant/discounts/new"
    end
  end

  def destroy
    discount = Discount.find(params[:discount_id])
    discount.destroy
    flash[:success] = "Discount Was Deleted"
    redirect_to '/merchant/discounts'
  end

  private
    def discount_params
      params.permit(:percent_off, :quantity_threshold, :status)
    end
end
