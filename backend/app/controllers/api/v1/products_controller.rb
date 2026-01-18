module Api
  module V1
    class ProductsController < BaseController
      before_action :authenticate_user!, except: [ :index, :show ]
      before_action :set_product, only: [ :show, :update, :destroy ]

      def index
        render json: Product.all
      end

      def show
        render json: @product
      end

    def create
      authorize Product
      @product = Product.new(product_params)
      if @product.save
        render json: @product, status: :created
      else
        render json: { errors: @product.errors.full_messages }, status: :unprocessable_content
      end
    end

      def update
        authorize @product

        if @product.update(product_params)
          render json: @product
        else
          render json: { errors: @product.errors.full_messages }, status: :unprocessable_content
        end
      end

      def destroy
        authorize @product
        @product.destroy
        head :no_content
      end

      private

      def set_product
        @product = Product.find(params[:id])
      end

      def product_params
        params.require(:product).permit(:name, :description, :price, :stock_quantity, :active)
      end
    end
  end
end
