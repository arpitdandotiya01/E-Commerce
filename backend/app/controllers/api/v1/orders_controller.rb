module Api
  module V1
    class OrdersController < BaseController
      before_action :authenticate_user!
      before_action :set_order, only: [ :show, :update_status ]

      def create
        order = current_user.orders.new(status: "pending")

        if order.save
          render json: order, status: :created
        else
          render json: { errors: order.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def index
        if current_user.admin?
          orders = Order.all
        else
          orders = current_user.orders
        end
        render json: orders, status: :ok
      end

      def update_status
        authorize @order, :update?

        @order.update!(status: params[:status])
        render json: @order, status: :ok
      end

      def show
        authorize @order
        render json: @order, status: :ok
      end

      def add_item
        order = current_user.orders.find_or_create_by!(status: "pending")

        product_id = params[:product_id]
        unless product_id.present?
          return render(json: { error: 'product_id is required' }, status: :bad_request)
        end

        product = Product.find_by(id: product_id)
        unless product
          return render(json: { error: "Product with id=#{product_id} not found" }, status: :not_found)
        end

        quantity = params[:quantity].to_i
        quantity = 1 if quantity <= 0

        item = order.order_items.find_or_initialize_by(product: product)
        item.quantity = item.quantity.to_i + quantity
        item.price = product.price

        ActiveRecord::Base.transaction do
          item.save!
          update_total(order)
        end

        render json: order, include: :order_items, status: :ok
      end

      def update_item
        order = current_user.orders.find_by!(status: "pending")
        item = order.order_items.find(params[:item_id])

        item.update!(quantity: params[:quantity])
        update_total(order)

        render json: order, include: :order_items, status: :ok
      end

      def remove_item
        order = current_user.orders.find_by!(status: "pending")
        item = order.order_items.find(params[:item_id])

        item.destroy!
        update_total(order)

        render json: order, include: :order_items, status: :ok
      end

      def checkout
        order = current_user.orders.find(params[:id])
        authorize order, :checkout?

        ActiveRecord::Base.transaction do
          order.order_items.each do |item|
            product = item.product
            if product.stock_quantity < item.quantity
              raise ActiveRecord::Rollback, "Insufficient stock for product #{product.name}"
            end

            product.update!(stock_quantity: product.stock_quantity - item.quantity)
          end
          order.update!(status: "paid")
          OrderConfirmationJob.perform_later(order.id)

          render json: {
            message: "Order placed successfully",
            order_id: order.id,
            total_amount: order.total_amount,
            status: order.status
          }
          rescue => e
            render json: { error: e.message }, status: :unprocessable_entity
        end
      end

      private

      def set_order
        @order =
        if current_user.admin?
          Order.find(params[:id])
        else
          current_user.orders.find(params[:id])
        end
      end

      def update_total(order)
        total = order.order_items.sum("quantity * price")
        order.update!(total_amount: total)
      end
    end
  end
end
